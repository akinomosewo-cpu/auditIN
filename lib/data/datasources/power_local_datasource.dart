import 'dart:async';
import 'package:battery_plus/battery_plus.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:uuid/uuid.dart';
import '../models/power_log_model.dart';
import '../../core/constants/app_constants.dart';

abstract class PowerLocalDataSource {
  Stream<PowerStatus> watchPowerStatus();
  Future<void> saveLog(PowerLogModel log);
  Future<List<PowerLogModel>> getLogs({DateTime? from, DateTime? to});
  Future<List<DailyStatModel>> getDailyStats({DateTime? from, int days = 30});
  Future<DailyStatModel?> getTodayStat();
  Future<void> saveDailyStat(DailyStatModel stat);
  Future<UserProfileModel?> getUserProfile();
  Future<void> saveUserProfile(UserProfileModel profile);
  Future<List<ComplaintModel>> getComplaints();
  Future<void> saveComplaint(ComplaintModel complaint);
  Future<void> updateComplaintStatus(String id, int statusIndex, String? ref);
}

class PowerLocalDataSourceImpl implements PowerLocalDataSource {
  final Battery _battery;
  final Uuid _uuid;

  PowerLocalDataSourceImpl({
    Battery? battery,
    Uuid? uuid,
  })  : _battery = battery ?? Battery(),
        _uuid = uuid ?? const Uuid();

  Box<PowerLogModel> get _logBox => Hive.box(AppConstants.powerLogBox);
  Box<DailyStatModel> get _statsBox => Hive.box(AppConstants.dailyStatsBox);
  Box<UserProfileModel> get _profileBox => Hive.box('profile_box');
  Box<ComplaintModel> get _complaintBox => Hive.box(AppConstants.complaintBox);

  PowerStatus _lastStatus = PowerStatus.unknown;
  StreamController<PowerStatus>? _statusController;

  @override
  Stream<PowerStatus> watchPowerStatus() {
    _statusController ??= StreamController<PowerStatus>.broadcast();

    // Listen to battery state changes
    _battery.onBatteryStateChanged.listen((BatteryState state) {
      final isCharging = state == BatteryState.charging ||
          state == BatteryState.full ||
          state == BatteryState.connectedNotCharging;

      final newStatus = isCharging ? PowerStatus.on : PowerStatus.off;

      if (newStatus != _lastStatus) {
        _lastStatus = newStatus;
        _statusController!.add(newStatus);
        _logStatusChange(newStatus);
      }
    });

    return _statusController!.stream;
  }

  void _logStatusChange(PowerStatus status) {
    final log = PowerLogModel(
      id: _uuid.v4(),
      timestamp: DateTime.now(),
      statusIndex: status.index,
      isCharging: status == PowerStatus.on,
    );
    saveLog(log);
  }

  @override
  Future<void> saveLog(PowerLogModel log) async {
    await _logBox.put(log.id, log);
  }

  @override
  Future<List<PowerLogModel>> getLogs({DateTime? from, DateTime? to}) async {
    final all = _logBox.values.toList();
    return all.where((log) {
      if (from != null && log.timestamp.isBefore(from)) return false;
      if (to != null && log.timestamp.isAfter(to)) return false;
      return true;
    }).toList()
      ..sort((a, b) => a.timestamp.compareTo(b.timestamp));
  }

  @override
  Future<List<DailyStatModel>> getDailyStats({
    DateTime? from,
    int days = 30,
  }) async {
    final cutoff = from ?? DateTime.now().subtract(Duration(days: days));
    final all = _statsBox.values.toList();
    return all.where((stat) {
      final parts = stat.dateKey.split('-');
      final date = DateTime(
        int.parse(parts[0]),
        int.parse(parts[1]),
        int.parse(parts[2]),
      );
      return date.isAfter(cutoff.subtract(const Duration(days: 1)));
    }).toList()
      ..sort((a, b) => a.dateKey.compareTo(b.dateKey));
  }

  @override
  Future<DailyStatModel?> getTodayStat() async {
    final now = DateTime.now();
    final key =
        '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
    return _statsBox.get(key);
  }

  @override
  Future<void> saveDailyStat(DailyStatModel stat) async {
    await _statsBox.put(stat.dateKey, stat);
  }

  @override
  Future<UserProfileModel?> getUserProfile() async {
    return _profileBox.get('profile');
  }

  @override
  Future<void> saveUserProfile(UserProfileModel profile) async {
    await _profileBox.put('profile', profile);
  }

  @override
  Future<List<ComplaintModel>> getComplaints() async {
    return _complaintBox.values.toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  @override
  Future<void> saveComplaint(ComplaintModel complaint) async {
    await _complaintBox.put(complaint.id, complaint);
  }

  @override
  Future<void> updateComplaintStatus(
    String id,
    int statusIndex,
    String? ref,
  ) async {
    final existing = _complaintBox.get(id);
    if (existing != null) {
      final updated = ComplaintModel(
        id: existing.id,
        createdAt: existing.createdAt,
        periodStartMs: existing.periodStartMs,
        periodEndMs: existing.periodEndMs,
        averageHoursPerDay: existing.averageHoursPerDay,
        promisedHoursPerDay: existing.promisedHoursPerDay,
        totalOutages: existing.totalOutages,
        totalDeficitHours: existing.totalDeficitHours,
        estimatedOvercharge: existing.estimatedOvercharge,
        bandIndex: existing.bandIndex,
        statusIndex: statusIndex,
        referenceNumber: ref,
        sentAtMs: DateTime.now().millisecondsSinceEpoch,
      );
      await _complaintBox.put(id, updated);
    }
  }

  /// Called by background worker to compute daily stats from logs
  Future<void> computeAndSaveTodayStat(int userBandIndex) async {
    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day);
    final logs = await getLogs(from: startOfDay, to: now);

    if (logs.isEmpty) return;

    double hoursOn = 0;
    double hoursOff = 0;
    int outageCount = 0;
    double longestOutage = 0;
    double longestUptime = 0;
    double currentSegment = 0;
    PowerStatus? lastStatus;

    for (int i = 0; i < logs.length - 1; i++) {
      final current = logs[i];
      final next = logs[i + 1];
      final duration =
          next.timestamp.difference(current.timestamp).inMinutes / 60.0;

      if (PowerStatus.values[current.statusIndex] == PowerStatus.on) {
        hoursOn += duration;
        currentSegment += duration;
        if (currentSegment > longestUptime) longestUptime = currentSegment;
      } else {
        hoursOff += duration;
        currentSegment += duration;
        if (currentSegment > longestOutage) longestOutage = currentSegment;
        if (lastStatus == PowerStatus.on) outageCount++;
      }

      if (lastStatus != null &&
          lastStatus != PowerStatus.values[current.statusIndex]) {
        currentSegment = 0;
      }

      lastStatus = PowerStatus.values[current.statusIndex];
    }

    final band = ElectricityBand.values[userBandIndex];
    final stat = DailyStatModel(
      dateKey:
          '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}',
      hoursOn: hoursOn,
      hoursOff: hoursOff,
      outageCount: outageCount,
      longestOutage: longestOutage,
      longestUptime: longestUptime,
      bandIndex: userBandIndex,
      meetsPromise: hoursOn >= band.promisedHours,
    );

    await saveDailyStat(stat);
  }
}

// Complaint Hive model (kept here to avoid circular deps)
@HiveType(typeId: 3)
class ComplaintModel extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final DateTime createdAt;

  @HiveField(2)
  final int periodStartMs;

  @HiveField(3)
  final int periodEndMs;

  @HiveField(4)
  final double averageHoursPerDay;

  @HiveField(5)
  final double promisedHoursPerDay;

  @HiveField(6)
  final int totalOutages;

  @HiveField(7)
  final double totalDeficitHours;

  @HiveField(8)
  final double estimatedOvercharge;

  @HiveField(9)
  final int bandIndex;

  @HiveField(10)
  final int statusIndex;

  @HiveField(11)
  final String? referenceNumber;

  @HiveField(12)
  final int? sentAtMs;

  ComplaintModel({
    required this.id,
    required this.createdAt,
    required this.periodStartMs,
    required this.periodEndMs,
    required this.averageHoursPerDay,
    required this.promisedHoursPerDay,
    required this.totalOutages,
    required this.totalDeficitHours,
    required this.estimatedOvercharge,
    required this.bandIndex,
    required this.statusIndex,
    this.referenceNumber,
    this.sentAtMs,
  });
}

/// Hand-authored Hive TypeAdapter for [ComplaintModel].
///
/// This is written by hand (rather than via `hive_generator`/`build_runner`)
/// because [ComplaintModel] lives outside a `part` file. It mirrors the
/// generated-adapter format exactly.
class ComplaintModelAdapter extends TypeAdapter<ComplaintModel> {
  @override
  final int typeId = 3;

  @override
  ComplaintModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ComplaintModel(
      id: fields[0] as String,
      createdAt: fields[1] as DateTime,
      periodStartMs: fields[2] as int,
      periodEndMs: fields[3] as int,
      averageHoursPerDay: fields[4] as double,
      promisedHoursPerDay: fields[5] as double,
      totalOutages: fields[6] as int,
      totalDeficitHours: fields[7] as double,
      estimatedOvercharge: fields[8] as double,
      bandIndex: fields[9] as int,
      statusIndex: fields[10] as int,
      referenceNumber: fields[11] as String?,
      sentAtMs: fields[12] as int?,
    );
  }

  @override
  void write(BinaryWriter writer, ComplaintModel obj) {
    writer
      ..writeByte(13)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.createdAt)
      ..writeByte(2)
      ..write(obj.periodStartMs)
      ..writeByte(3)
      ..write(obj.periodEndMs)
      ..writeByte(4)
      ..write(obj.averageHoursPerDay)
      ..writeByte(5)
      ..write(obj.promisedHoursPerDay)
      ..writeByte(6)
      ..write(obj.totalOutages)
      ..writeByte(7)
      ..write(obj.totalDeficitHours)
      ..writeByte(8)
      ..write(obj.estimatedOvercharge)
      ..writeByte(9)
      ..write(obj.bandIndex)
      ..writeByte(10)
      ..write(obj.statusIndex)
      ..writeByte(11)
      ..write(obj.referenceNumber)
      ..writeByte(12)
      ..write(obj.sentAtMs);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ComplaintModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
