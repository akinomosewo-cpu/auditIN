import 'package:hive/hive.dart';
import '../../domain/entities/power_log.dart';
import '../../core/constants/app_constants.dart';

part 'power_log_model.g.dart';

@HiveType(typeId: 0)
class PowerLogModel extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final DateTime timestamp;

  @HiveField(2)
  final int statusIndex; // PowerStatus enum index

  @HiveField(3)
  final double? batteryLevel;

  @HiveField(4)
  final bool isCharging;

  @HiveField(5)
  final String? feederId;

  @HiveField(6)
  final double? latitude;

  @HiveField(7)
  final double? longitude;

  PowerLogModel({
    required this.id,
    required this.timestamp,
    required this.statusIndex,
    this.batteryLevel,
    required this.isCharging,
    this.feederId,
    this.latitude,
    this.longitude,
  });

  factory PowerLogModel.fromEntity(PowerLog entity) => PowerLogModel(
        id: entity.id,
        timestamp: entity.timestamp,
        statusIndex: entity.status.index,
        batteryLevel: entity.batteryLevel,
        isCharging: entity.isCharging,
        feederId: entity.feederId,
        latitude: entity.latitude,
        longitude: entity.longitude,
      );

  PowerLog toEntity() => PowerLog(
        id: id,
        timestamp: timestamp,
        status: PowerStatus.values[statusIndex],
        batteryLevel: batteryLevel,
        isCharging: isCharging,
        feederId: feederId,
        latitude: latitude,
        longitude: longitude,
      );
}

@HiveType(typeId: 1)
class DailyStatModel extends HiveObject {
  @HiveField(0)
  final String dateKey; // yyyy-MM-dd

  @HiveField(1)
  final double hoursOn;

  @HiveField(2)
  final double hoursOff;

  @HiveField(3)
  final int outageCount;

  @HiveField(4)
  final double longestOutage;

  @HiveField(5)
  final double longestUptime;

  @HiveField(6)
  final int bandIndex; // ElectricityBand enum index

  @HiveField(7)
  final bool meetsPromise;

  DailyStatModel({
    required this.dateKey,
    required this.hoursOn,
    required this.hoursOff,
    required this.outageCount,
    required this.longestOutage,
    required this.longestUptime,
    required this.bandIndex,
    required this.meetsPromise,
  });

  factory DailyStatModel.fromEntity(DailyStat entity) => DailyStatModel(
        dateKey:
            '${entity.date.year}-${entity.date.month.toString().padLeft(2, '0')}-${entity.date.day.toString().padLeft(2, '0')}',
        hoursOn: entity.hoursOn,
        hoursOff: entity.hoursOff,
        outageCount: entity.outageCount,
        longestOutage: entity.longestOutage,
        longestUptime: entity.longestUptime,
        bandIndex: entity.band.index,
        meetsPromise: entity.meetsPromise,
      );

  DailyStat toEntity() {
    final parts = dateKey.split('-');
    return DailyStat(
      date: DateTime(
        int.parse(parts[0]),
        int.parse(parts[1]),
        int.parse(parts[2]),
      ),
      hoursOn: hoursOn,
      hoursOff: hoursOff,
      outageCount: outageCount,
      longestOutage: longestOutage,
      longestUptime: longestUptime,
      band: ElectricityBand.values[bandIndex],
      meetsPromise: meetsPromise,
    );
  }
}

@HiveType(typeId: 2)
class UserProfileModel extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final String address;

  @HiveField(3)
  final String meterNumber;

  @HiveField(4)
  final String accountNumber;

  @HiveField(5)
  final int bandIndex;

  @HiveField(6)
  final String feederName;

  @HiveField(7)
  final String district;

  @HiveField(8)
  final double latitude;

  @HiveField(9)
  final double longitude;

  @HiveField(10)
  final DateTime registeredAt;

  UserProfileModel({
    required this.id,
    required this.name,
    required this.address,
    required this.meterNumber,
    required this.accountNumber,
    required this.bandIndex,
    required this.feederName,
    required this.district,
    required this.latitude,
    required this.longitude,
    required this.registeredAt,
  });

  factory UserProfileModel.fromEntity(UserProfile entity) => UserProfileModel(
        id: entity.id,
        name: entity.name,
        address: entity.address,
        meterNumber: entity.meterNumber,
        accountNumber: entity.accountNumber,
        bandIndex: entity.band.index,
        feederName: entity.feederName,
        district: entity.district,
        latitude: entity.latitude,
        longitude: entity.longitude,
        registeredAt: entity.registeredAt,
      );

  UserProfile toEntity() => UserProfile(
        id: id,
        name: name,
        address: address,
        meterNumber: meterNumber,
        accountNumber: accountNumber,
        band: ElectricityBand.values[bandIndex],
        feederName: feederName,
        district: district,
        latitude: latitude,
        longitude: longitude,
        registeredAt: registeredAt,
      );
}
