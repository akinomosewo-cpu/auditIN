import 'package:dartz/dartz.dart';
import '../entities/power_log.dart';
import '../../core/constants/app_constants.dart';

abstract class PowerRepository {
  // Power Logs
  Future<Either<Failure, List<PowerLog>>> getLogs({
    DateTime? from,
    DateTime? to,
  });

  Future<Either<Failure, Unit>> saveLog(PowerLog log);

  Stream<PowerStatus> watchPowerStatus();

  // Daily Stats
  Future<Either<Failure, List<DailyStat>>> getDailyStats({
    DateTime? from,
    DateTime? to,
    int days = 30,
  });

  Future<Either<Failure, DailyStat?>> getTodayStat();

  Future<Either<Failure, Unit>> saveDailyStat(DailyStat stat);

  // Aggregates
  Future<Either<Failure, double>> getAverageHoursPerDay({int days = 30});

  Future<Either<Failure, double>> getTotalDeficitHours({int days = 30});

  Future<Either<Failure, int>> getTotalOutages({int days = 30});

  Future<Either<Failure, double>> getEstimatedOvercharge({int days = 30});

  // User Profile
  Future<Either<Failure, UserProfile?>> getUserProfile();

  Future<Either<Failure, Unit>> saveUserProfile(UserProfile profile);

  // Complaints
  Future<Either<Failure, List<Complaint>>> getComplaints();

  Future<Either<Failure, Unit>> saveComplaint(Complaint complaint);

  Future<Either<Failure, Unit>> updateComplaintStatus(
    String id,
    ComplaintStatus status,
    String? referenceNumber,
  );
}

class Failure {
  final String message;
  final int? code;

  const Failure({required this.message, this.code});

  @override
  String toString() => 'Failure(message: $message, code: $code)';
}
