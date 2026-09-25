import 'package:dartz/dartz.dart';
import '../../core/constants/app_constants.dart';
import '../../domain/entities/power_log.dart';
import '../../domain/repositories/power_repository.dart';
import '../datasources/power_local_datasource.dart';
import '../models/power_log_model.dart';

class PowerRepositoryImpl implements PowerRepository {
  final PowerLocalDataSource _dataSource;

  const PowerRepositoryImpl({required PowerLocalDataSource dataSource})
      : _dataSource = dataSource;

  @override
  Stream<PowerStatus> watchPowerStatus() => _dataSource.watchPowerStatus();

  @override
  Future<Either<Failure, List<PowerLog>>> getLogs({
    DateTime? from,
    DateTime? to,
  }) async {
    try {
      final models = await _dataSource.getLogs(from: from, to: to);
      return right(models.map((m) => m.toEntity()).toList());
    } catch (e) {
      return left(Failure(message: 'Failed to load logs: $e'));
    }
  }

  @override
  Future<Either<Failure, Unit>> saveLog(PowerLog log) async {
    try {
      await _dataSource.saveLog(PowerLogModel.fromEntity(log));
      return right(unit);
    } catch (e) {
      return left(Failure(message: 'Failed to save log: $e'));
    }
  }

  @override
  Future<Either<Failure, List<DailyStat>>> getDailyStats({
    DateTime? from,
    DateTime? to,
    int days = 30,
  }) async {
    try {
      final models = await _dataSource.getDailyStats(from: from, days: days);
      return right(models.map((m) => m.toEntity()).toList());
    } catch (e) {
      return left(Failure(message: 'Failed to load daily stats: $e'));
    }
  }

  @override
  Future<Either<Failure, DailyStat?>> getTodayStat() async {
    try {
      final model = await _dataSource.getTodayStat();
      return right(model?.toEntity());
    } catch (e) {
      return left(Failure(message: 'Failed to get today stat: $e'));
    }
  }

  @override
  Future<Either<Failure, Unit>> saveDailyStat(DailyStat stat) async {
    try {
      await _dataSource.saveDailyStat(DailyStatModel.fromEntity(stat));
      return right(unit);
    } catch (e) {
      return left(Failure(message: 'Failed to save daily stat: $e'));
    }
  }

  @override
  Future<Either<Failure, double>> getAverageHoursPerDay({int days = 30}) async {
    try {
      final stats = await _dataSource.getDailyStats(days: days);
      if (stats.isEmpty) return right(0);
      final total = stats.fold(0.0, (sum, s) => sum + s.hoursOn);
      return right(total / stats.length);
    } catch (e) {
      return left(Failure(message: 'Failed to get average: $e'));
    }
  }

  @override
  Future<Either<Failure, double>> getTotalDeficitHours({int days = 30}) async {
    try {
      final profile = await _dataSource.getUserProfile();
      final band = profile != null
          ? ElectricityBand.values[profile.bandIndex]
          : ElectricityBand.a;
      final stats = await _dataSource.getDailyStats(days: days);
      final deficit = stats.fold(0.0, (sum, s) {
        final d = band.promisedHours - s.hoursOn;
        return sum + (d > 0 ? d : 0);
      });
      return right(deficit);
    } catch (e) {
      return left(Failure(message: 'Failed to get deficit: $e'));
    }
  }

  @override
  Future<Either<Failure, int>> getTotalOutages({int days = 30}) async {
    try {
      final stats = await _dataSource.getDailyStats(days: days);
      final total = stats.fold(0, (sum, s) => sum + s.outageCount);
      return right(total);
    } catch (e) {
      return left(Failure(message: 'Failed to get outages: $e'));
    }
  }

  @override
  Future<Either<Failure, double>> getEstimatedOvercharge({int days = 30}) async {
    try {
      final stats = await _dataSource.getDailyStats(days: days);
      final overcharge = stats.fold(0.0, (sum, s) {
        return sum + s.toEntity().extraChargeEstimate;
      });
      return right(overcharge);
    } catch (e) {
      return left(Failure(message: 'Failed to get overcharge: $e'));
    }
  }

  @override
  Future<Either<Failure, UserProfile?>> getUserProfile() async {
    try {
      final model = await _dataSource.getUserProfile();
      return right(model?.toEntity());
    } catch (e) {
      return left(Failure(message: 'Failed to get profile: $e'));
    }
  }

  @override
  Future<Either<Failure, Unit>> saveUserProfile(UserProfile profile) async {
    try {
      await _dataSource.saveUserProfile(UserProfileModel.fromEntity(profile));
      return right(unit);
    } catch (e) {
      return left(Failure(message: 'Failed to save profile: $e'));
    }
  }

  @override
  Future<Either<Failure, List<Complaint>>> getComplaints() async {
    try {
      final models = await _dataSource.getComplaints();
      return right(models.map((m) => _complaintFromModel(m)).toList());
    } catch (e) {
      return left(Failure(message: 'Failed to load complaints: $e'));
    }
  }

  @override
  Future<Either<Failure, Unit>> saveComplaint(Complaint complaint) async {
    try {
      await _dataSource.saveComplaint(_complaintToModel(complaint));
      return right(unit);
    } catch (e) {
      return left(Failure(message: 'Failed to save complaint: $e'));
    }
  }

  @override
  Future<Either<Failure, Unit>> updateComplaintStatus(
    String id,
    ComplaintStatus status,
    String? referenceNumber,
  ) async {
    try {
      await _dataSource.updateComplaintStatus(id, status.index, referenceNumber);
      return right(unit);
    } catch (e) {
      return left(Failure(message: 'Failed to update complaint: $e'));
    }
  }

  Complaint _complaintFromModel(ComplaintModel m) => Complaint(
        id: m.id,
        createdAt: m.createdAt,
        periodStart: DateTime.fromMillisecondsSinceEpoch(m.periodStartMs),
        periodEnd: DateTime.fromMillisecondsSinceEpoch(m.periodEndMs),
        averageHoursPerDay: m.averageHoursPerDay,
        promisedHoursPerDay: m.promisedHoursPerDay,
        totalOutages: m.totalOutages,
        totalDeficitHours: m.totalDeficitHours,
        estimatedOvercharge: m.estimatedOvercharge,
        band: ElectricityBand.values[m.bandIndex],
        status: ComplaintStatus.values[m.statusIndex],
        referenceNumber: m.referenceNumber,
        sentAt: m.sentAtMs != null
            ? DateTime.fromMillisecondsSinceEpoch(m.sentAtMs!)
            : null,
      );

  ComplaintModel _complaintToModel(Complaint c) => ComplaintModel(
        id: c.id,
        createdAt: c.createdAt,
        periodStartMs: c.periodStart.millisecondsSinceEpoch,
        periodEndMs: c.periodEnd.millisecondsSinceEpoch,
        averageHoursPerDay: c.averageHoursPerDay,
        promisedHoursPerDay: c.promisedHoursPerDay,
        totalOutages: c.totalOutages,
        totalDeficitHours: c.totalDeficitHours,
        estimatedOvercharge: c.estimatedOvercharge,
        bandIndex: c.band.index,
        statusIndex: c.status.index,
        referenceNumber: c.referenceNumber,
        sentAtMs: c.sentAt?.millisecondsSinceEpoch,
      );
}
