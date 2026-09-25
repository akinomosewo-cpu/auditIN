import 'package:equatable/equatable.dart';
import '../../core/constants/app_constants.dart';

class PowerLog extends Equatable {
  final String id;
  final DateTime timestamp;
  final PowerStatus status;
  final double? batteryLevel;
  final bool isCharging;
  final String? feederId;
  final double? latitude;
  final double? longitude;

  const PowerLog({
    required this.id,
    required this.timestamp,
    required this.status,
    this.batteryLevel,
    required this.isCharging,
    this.feederId,
    this.latitude,
    this.longitude,
  });

  @override
  List<Object?> get props => [
        id,
        timestamp,
        status,
        batteryLevel,
        isCharging,
        feederId,
        latitude,
        longitude,
      ];
}

class DailyStat extends Equatable {
  final DateTime date;
  final double hoursOn;
  final double hoursOff;
  final int outageCount;
  final double longestOutage; // hours
  final double longestUptime; // hours
  final ElectricityBand band;
  final bool meetsPromise;

  const DailyStat({
    required this.date,
    required this.hoursOn,
    required this.hoursOff,
    required this.outageCount,
    required this.longestOutage,
    required this.longestUptime,
    required this.band,
    required this.meetsPromise,
  });

  double get supplyPercentage => (hoursOn / 24) * 100;

  double get promisedHours => band.promisedHours.toDouble();

  double get deficitHours => (promisedHours - hoursOn).clamp(0, 24);

  double get extraChargeEstimate {
    final bandBRate = AppConstants.bandBRatePerUnit;
    final actualRate = band.ratePerUnit;
    final avgDailyUnits = 10.0; // avg household consumption per hour
    return (actualRate - bandBRate) * avgDailyUnits * hoursOn / 1000;
  }

  @override
  List<Object?> get props => [
        date,
        hoursOn,
        hoursOff,
        outageCount,
        longestOutage,
        longestUptime,
        band,
        meetsPromise,
      ];
}

class UserProfile extends Equatable {
  final String id;
  final String name;
  final String address;
  final String meterNumber;
  final String accountNumber;
  final ElectricityBand band;
  final String feederName;
  final String district;
  final double latitude;
  final double longitude;
  final DateTime registeredAt;

  const UserProfile({
    required this.id,
    required this.name,
    required this.address,
    required this.meterNumber,
    required this.accountNumber,
    required this.band,
    required this.feederName,
    required this.district,
    required this.latitude,
    required this.longitude,
    required this.registeredAt,
  });

  @override
  List<Object?> get props => [
        id,
        name,
        address,
        meterNumber,
        accountNumber,
        band,
        feederName,
        district,
        latitude,
        longitude,
        registeredAt,
      ];
}

class Complaint extends Equatable {
  final String id;
  final DateTime createdAt;
  final DateTime periodStart;
  final DateTime periodEnd;
  final double averageHoursPerDay;
  final double promisedHoursPerDay;
  final int totalOutages;
  final double totalDeficitHours;
  final double estimatedOvercharge;
  final ElectricityBand band;
  final ComplaintStatus status;
  final String? referenceNumber;
  final DateTime? sentAt;

  const Complaint({
    required this.id,
    required this.createdAt,
    required this.periodStart,
    required this.periodEnd,
    required this.averageHoursPerDay,
    required this.promisedHoursPerDay,
    required this.totalOutages,
    required this.totalDeficitHours,
    required this.estimatedOvercharge,
    required this.band,
    required this.status,
    this.referenceNumber,
    this.sentAt,
  });

  double get fulfillmentPercentage =>
      (averageHoursPerDay / promisedHoursPerDay) * 100;

  @override
  List<Object?> get props => [
        id,
        createdAt,
        periodStart,
        periodEnd,
        averageHoursPerDay,
        promisedHoursPerDay,
        totalOutages,
        totalDeficitHours,
        estimatedOvercharge,
        band,
        status,
        referenceNumber,
        sentAt,
      ];
}
