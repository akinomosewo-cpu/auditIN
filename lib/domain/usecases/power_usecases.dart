import 'package:dartz/dartz.dart';
import '../entities/power_log.dart';
import '../repositories/power_repository.dart';
import '../../core/constants/app_constants.dart';

class WatchPowerStatusUseCase {
  final PowerRepository _repository;
  const WatchPowerStatusUseCase(this._repository);

  Stream<PowerStatus> call() => _repository.watchPowerStatus();
}

class GetDailyStatsUseCase {
  final PowerRepository _repository;
  const GetDailyStatsUseCase(this._repository);

  Future<Either<Failure, List<DailyStat>>> call({int days = 30}) {
    final from = DateTime.now().subtract(Duration(days: days));
    return _repository.getDailyStats(from: from, days: days);
  }
}

class GetDashboardSummaryUseCase {
  final PowerRepository _repository;
  const GetDashboardSummaryUseCase(this._repository);

  Future<Either<Failure, DashboardSummary>> call() async {
    final results = await Future.wait([
      _repository.getAverageHoursPerDay(days: 30),
      _repository.getTotalDeficitHours(days: 30),
      _repository.getTotalOutages(days: 30),
      _repository.getEstimatedOvercharge(days: 30),
      _repository.getTodayStat(),
      _repository.getUserProfile(),
    ]);

    final avgHours = results[0] as Either<Failure, double>;
    final deficit = results[1] as Either<Failure, double>;
    final outages = results[2] as Either<Failure, int>;
    final overcharge = results[3] as Either<Failure, double>;
    final today = results[4] as Either<Failure, DailyStat?>;
    final profile = results[5] as Either<Failure, UserProfile?>;

    if (avgHours.isLeft()) return left(const Failure(message: 'Failed to load dashboard'));

    return right(DashboardSummary(
      averageHoursPerDay: avgHours.getOrElse(() => 0),
      totalDeficitHours: deficit.getOrElse(() => 0),
      totalOutages: outages.getOrElse(() => 0),
      estimatedOvercharge: overcharge.getOrElse(() => 0),
      todayStat: today.getOrElse(() => null),
      userProfile: profile.getOrElse(() => null),
    ));
  }
}

class GenerateComplaintUseCase {
  final PowerRepository _repository;
  const GenerateComplaintUseCase(this._repository);

  Future<Either<Failure, Complaint>> call({int days = 30}) async {
    final profile = await _repository.getUserProfile();
    final avgHours = await _repository.getAverageHoursPerDay(days: days);
    final deficit = await _repository.getTotalDeficitHours(days: days);
    final outages = await _repository.getTotalOutages(days: days);
    final overcharge = await _repository.getEstimatedOvercharge(days: days);

    return profile.fold(
      (failure) => left(failure),
      (userProfile) {
        if (userProfile == null) {
          return left(const Failure(message: 'User profile not set up'));
        }

        final complaint = Complaint(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          createdAt: DateTime.now(),
          periodStart: DateTime.now().subtract(Duration(days: days)),
          periodEnd: DateTime.now(),
          averageHoursPerDay: avgHours.getOrElse(() => 0),
          promisedHoursPerDay: userProfile.band.promisedHours.toDouble(),
          totalOutages: outages.getOrElse(() => 0),
          totalDeficitHours: deficit.getOrElse(() => 0),
          estimatedOvercharge: overcharge.getOrElse(() => 0),
          band: userProfile.band,
          status: ComplaintStatus.draft,
        );

        return right(complaint);
      },
    );
  }
}

class SavePowerLogUseCase {
  final PowerRepository _repository;
  const SavePowerLogUseCase(this._repository);

  Future<Either<Failure, Unit>> call(PowerLog log) =>
      _repository.saveLog(log);
}

class GetLogsUseCase {
  final PowerRepository _repository;
  const GetLogsUseCase(this._repository);

  Future<Either<Failure, List<PowerLog>>> call({
    DateTime? from,
    DateTime? to,
  }) =>
      _repository.getLogs(from: from, to: to);
}

// Summary data class
class DashboardSummary {
  final double averageHoursPerDay;
  final double totalDeficitHours;
  final int totalOutages;
  final double estimatedOvercharge;
  final DailyStat? todayStat;
  final UserProfile? userProfile;

  const DashboardSummary({
    required this.averageHoursPerDay,
    required this.totalDeficitHours,
    required this.totalOutages,
    required this.estimatedOvercharge,
    this.todayStat,
    this.userProfile,
  });

  bool get isBelowThreshold {
    if (userProfile == null) return false;
    return averageHoursPerDay <
        (userProfile!.band.promisedHours * AppConstants.complaintThresholdPercent);
  }

  double get fulfillmentRate {
    if (userProfile == null) return 0;
    return (averageHoursPerDay / userProfile!.band.promisedHours) * 100;
  }
}
