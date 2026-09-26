import 'dart:convert';
import 'dart:math';
import 'package:hive/hive.dart';
import '../../data/models/auth_credential_model.dart';

/// Local-only authentication. `band_a_audit` has no backend, so there is
/// nothing to authenticate *against* except the credentials the user set up
/// on this same device. Sign-up writes a salted password hash into Hive;
/// login checks the entered password against it; a simple boolean flag in
/// the settings box tracks whether the current app session is "logged in"
/// so returning users can skip straight to the dashboard.
///
/// This is intentionally simple (not a cryptographic hardening exercise) —
/// its only job is to gate access to data the user already owns on their
/// own device.
class AuthService {
  static const String authBoxName = 'auth_box';
  static const String credentialKey = 'primary';
  static const String loggedInKey = 'is_logged_in';

  final Box<AuthCredentialModel> _authBox;
  final Box _settingsBox;

  AuthService({
    Box<AuthCredentialModel>? authBox,
    Box? settingsBox,
  })  : _authBox = authBox ?? Hive.box<AuthCredentialModel>(authBoxName),
        _settingsBox = settingsBox ?? Hive.box('settings_box');

  /// Whether a local account has ever been created on this device.
  bool hasAccount() => _authBox.containsKey(credentialKey);

  /// Whether the current session is authenticated.
  bool isLoggedIn() =>
      hasAccount() && (_settingsBox.get(loggedInKey, defaultValue: false) as bool);

  /// The signed-up user's display name, if any.
  String? get currentUserName => _authBox.get(credentialKey)?.name;

  /// The signed-up user's AEDC account/meter number, if any.
  String? get currentAccountNumber => _authBox.get(credentialKey)?.accountNumber;

  /// Creates the local account and immediately logs the user in.
  ///
  /// Throws an [AuthException] if inputs are invalid or an account already
  /// exists on this device.
  Future<void> signUp({
    required String name,
    required String accountNumber,
    required String password,
  }) async {
    final trimmedName = name.trim();
    final trimmedAccount = accountNumber.trim();

    if (trimmedName.isEmpty) {
      throw AuthException('Please enter your name.');
    }
    if (trimmedAccount.isEmpty) {
      throw AuthException('Please enter your AEDC account or meter number.');
    }
    if (password.length < 4) {
      throw AuthException('Password must be at least 4 characters.');
    }
    if (hasAccount()) {
      throw AuthException(
        'An account already exists on this device. Please log in instead.',
      );
    }

    final salt = _generateSalt();
    final hash = hashPassword(password, salt);

    await _authBox.put(
      credentialKey,
      AuthCredentialModel(
        name: trimmedName,
        accountNumber: trimmedAccount,
        passwordHash: hash,
        salt: salt,
        createdAt: DateTime.now(),
      ),
    );

    await _settingsBox.put(loggedInKey, true);
  }

  /// Validates the entered credentials against what was stored at sign-up.
  ///
  /// Throws an [AuthException] on any mismatch or missing account.
  Future<void> login({
    required String accountNumber,
    required String password,
  }) async {
    final credential = _authBox.get(credentialKey);
    if (credential == null) {
      throw AuthException('No account found on this device. Please sign up.');
    }

    if (credential.accountNumber.trim().toLowerCase() !=
        accountNumber.trim().toLowerCase()) {
      throw AuthException('Account/meter number or password is incorrect.');
    }

    final attemptHash = hashPassword(password, credential.salt);
    if (attemptHash != credential.passwordHash) {
      throw AuthException('Account/meter number or password is incorrect.');
    }

    await _settingsBox.put(loggedInKey, true);
  }

  /// Logs the current session out. Stored credentials remain untouched so
  /// the user can log back in.
  Future<void> logout() async {
    await _settingsBox.put(loggedInKey, false);
  }

  static String _generateSalt() {
    final random = Random.secure();
    final bytes = List<int>.generate(16, (_) => random.nextInt(256));
    return base64UrlEncode(bytes);
  }

  /// A deterministic, salted hash of [password]. Not a substitute for a
  /// real KMS-backed hashing scheme, but sufficient for gating an
  /// on-device-only local session with no network component.
  static String hashPassword(String password, String salt) {
    final bytes = utf8.encode('$salt::$password');
    int h1 = 0x811c9dc5; // FNV-1a offset basis
    int h2 = 0x1000193;
    for (final b in bytes) {
      h1 = (h1 ^ b) & 0xFFFFFFFF;
      h1 = (h1 * 0x01000193) & 0xFFFFFFFF;
      h2 = (h2 + b) & 0xFFFFFFFF;
      h2 = ((h2 << 5) | (h2 >> 27)) & 0xFFFFFFFF;
      h2 = (h2 ^ b) & 0xFFFFFFFF;
    }
    // Run a second pass over the digest bytes so the output space is wide
    // enough to make casual collisions impractical for this purpose.
    final combined = '$h1-$h2-${bytes.length}';
    int h3 = 0;
    for (final unit in combined.codeUnits) {
      h3 = (h3 * 31 + unit) & 0xFFFFFFFFFFFFFF;
    }
    return '$h1$h2$h3'.padLeft(32, '0');
  }
}

class AuthException implements Exception {
  final String message;
  AuthException(this.message);

  @override
  String toString() => message;
}
