import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:band_a_audit/data/models/auth_credential_model.dart';
import 'package:band_a_audit/domain/services/auth_service.dart';

void main() {
  late Directory tempDir;
  late Box<AuthCredentialModel> authBox;
  late Box settingsBox;
  late AuthService authService;

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('auth_service_test');
    Hive.init(tempDir.path);
    if (!Hive.isAdapterRegistered(3)) {
      Hive.registerAdapter(AuthCredentialModelAdapter());
    }
    authBox = await Hive.openBox<AuthCredentialModel>('auth_box_test');
    settingsBox = await Hive.openBox('settings_box_test');
    authService = AuthService(authBox: authBox, settingsBox: settingsBox);
  });

  tearDown(() async {
    await authBox.close();
    await settingsBox.close();
    if (await tempDir.exists()) {
      await tempDir.delete(recursive: true);
    }
  });

  group('AuthService local sign up / login', () {
    test('signUp stores credentials and logs the user in', () async {
      expect(authService.hasAccount(), isFalse);
      expect(authService.isLoggedIn(), isFalse);

      await authService.signUp(
        name: 'Amaka Okafor',
        accountNumber: '04123456789',
        password: 'secret123',
      );

      expect(authService.hasAccount(), isTrue);
      expect(authService.isLoggedIn(), isTrue);
      expect(authService.currentUserName, 'Amaka Okafor');
      expect(authService.currentAccountNumber, '04123456789');
    });

    test('signUp rejects a second account on the same device', () async {
      await authService.signUp(
        name: 'Amaka Okafor',
        accountNumber: '04123456789',
        password: 'secret123',
      );

      expect(
        () => authService.signUp(
          name: 'Someone Else',
          accountNumber: '04199999999',
          password: 'other1234',
        ),
        throwsA(isA<AuthException>()),
      );
    });

    test('login succeeds with correct credentials and fails with wrong password',
        () async {
      await authService.signUp(
        name: 'Amaka Okafor',
        accountNumber: '04123456789',
        password: 'secret123',
      );
      await authService.logout();
      expect(authService.isLoggedIn(), isFalse);

      await authService.login(
        accountNumber: '04123456789',
        password: 'secret123',
      );
      expect(authService.isLoggedIn(), isTrue);

      await authService.logout();

      expect(
        () => authService.login(
          accountNumber: '04123456789',
          password: 'wrong-password',
        ),
        throwsA(isA<AuthException>()),
      );
      expect(authService.isLoggedIn(), isFalse);
    });

    test('login fails when no account exists yet', () async {
      expect(
        () => authService.login(
          accountNumber: '04123456789',
          password: 'secret123',
        ),
        throwsA(isA<AuthException>()),
      );
    });

    test('hashPassword is deterministic for the same password/salt and '
        'differs across salts', () {
      final hash1 = AuthService.hashPassword('secret123', 'salt-a');
      final hash2 = AuthService.hashPassword('secret123', 'salt-a');
      final hash3 = AuthService.hashPassword('secret123', 'salt-b');

      expect(hash1, hash2);
      expect(hash1, isNot(hash3));
    });
  });
}
