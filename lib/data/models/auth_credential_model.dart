import 'package:hive/hive.dart';

part 'auth_credential_model.g.dart';

/// Local-only credential record. There is no backend for this app, so
/// sign-up simply persists a salted password hash in Hive and login
/// validates against it. This is NOT meant to be cryptographically
/// bullet-proof — it only needs to gate access to the on-device data the
/// user themselves already owns.
@HiveType(typeId: 3)
class AuthCredentialModel extends HiveObject {
  @HiveField(0)
  final String name;

  @HiveField(1)
  final String accountNumber; // AEDC account / meter number, used as login id

  @HiveField(2)
  final String passwordHash;

  @HiveField(3)
  final String salt;

  @HiveField(4)
  final DateTime createdAt;

  AuthCredentialModel({
    required this.name,
    required this.accountNumber,
    required this.passwordHash,
    required this.salt,
    required this.createdAt,
  });
}
