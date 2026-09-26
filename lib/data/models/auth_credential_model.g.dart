// GENERATED CODE - DO NOT MODIFY BY HAND
// Hand-authored to match hive_generator output (build_runner unavailable in
// this environment). Regenerate with `flutter pub run build_runner build`
// once tooling is available and this file may be replaced.

part of 'auth_credential_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class AuthCredentialModelAdapter extends TypeAdapter<AuthCredentialModel> {
  @override
  final int typeId = 3;

  @override
  AuthCredentialModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return AuthCredentialModel(
      name: fields[0] as String,
      accountNumber: fields[1] as String,
      passwordHash: fields[2] as String,
      salt: fields[3] as String,
      createdAt: fields[4] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, AuthCredentialModel obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.name)
      ..writeByte(1)
      ..write(obj.accountNumber)
      ..writeByte(2)
      ..write(obj.passwordHash)
      ..writeByte(3)
      ..write(obj.salt)
      ..writeByte(4)
      ..write(obj.createdAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AuthCredentialModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
