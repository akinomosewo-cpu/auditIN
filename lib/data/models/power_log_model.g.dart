// GENERATED CODE - DO NOT MODIFY BY HAND
// Hand-authored to match hive_generator output (build_runner unavailable in
// this environment). Regenerate with `flutter pub run build_runner build`
// once tooling is available and this file may be replaced.

part of 'power_log_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class PowerLogModelAdapter extends TypeAdapter<PowerLogModel> {
  @override
  final int typeId = 0;

  @override
  PowerLogModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return PowerLogModel(
      id: fields[0] as String,
      timestamp: fields[1] as DateTime,
      statusIndex: fields[2] as int,
      batteryLevel: fields[3] as double?,
      isCharging: fields[4] as bool,
      feederId: fields[5] as String?,
      latitude: fields[6] as double?,
      longitude: fields[7] as double?,
    );
  }

  @override
  void write(BinaryWriter writer, PowerLogModel obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.timestamp)
      ..writeByte(2)
      ..write(obj.statusIndex)
      ..writeByte(3)
      ..write(obj.batteryLevel)
      ..writeByte(4)
      ..write(obj.isCharging)
      ..writeByte(5)
      ..write(obj.feederId)
      ..writeByte(6)
      ..write(obj.latitude)
      ..writeByte(7)
      ..write(obj.longitude);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PowerLogModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class DailyStatModelAdapter extends TypeAdapter<DailyStatModel> {
  @override
  final int typeId = 1;

  @override
  DailyStatModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return DailyStatModel(
      dateKey: fields[0] as String,
      hoursOn: fields[1] as double,
      hoursOff: fields[2] as double,
      outageCount: fields[3] as int,
      longestOutage: fields[4] as double,
      longestUptime: fields[5] as double,
      bandIndex: fields[6] as int,
      meetsPromise: fields[7] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, DailyStatModel obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.dateKey)
      ..writeByte(1)
      ..write(obj.hoursOn)
      ..writeByte(2)
      ..write(obj.hoursOff)
      ..writeByte(3)
      ..write(obj.outageCount)
      ..writeByte(4)
      ..write(obj.longestOutage)
      ..writeByte(5)
      ..write(obj.longestUptime)
      ..writeByte(6)
      ..write(obj.bandIndex)
      ..writeByte(7)
      ..write(obj.meetsPromise);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DailyStatModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class UserProfileModelAdapter extends TypeAdapter<UserProfileModel> {
  @override
  final int typeId = 2;

  @override
  UserProfileModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return UserProfileModel(
      id: fields[0] as String,
      name: fields[1] as String,
      address: fields[2] as String,
      meterNumber: fields[3] as String,
      accountNumber: fields[4] as String,
      bandIndex: fields[5] as int,
      feederName: fields[6] as String,
      district: fields[7] as String,
      latitude: fields[8] as double,
      longitude: fields[9] as double,
      registeredAt: fields[10] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, UserProfileModel obj) {
    writer
      ..writeByte(11)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.address)
      ..writeByte(3)
      ..write(obj.meterNumber)
      ..writeByte(4)
      ..write(obj.accountNumber)
      ..writeByte(5)
      ..write(obj.bandIndex)
      ..writeByte(6)
      ..write(obj.feederName)
      ..writeByte(7)
      ..write(obj.district)
      ..writeByte(8)
      ..write(obj.latitude)
      ..writeByte(9)
      ..write(obj.longitude)
      ..writeByte(10)
      ..write(obj.registeredAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserProfileModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
