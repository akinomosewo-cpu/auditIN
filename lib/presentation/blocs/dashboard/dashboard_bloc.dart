import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../core/constants/app_constants.dart';
import '../../../domain/entities/power_log.dart';
import '../../../domain/usecases/power_usecases.dart';

// Events
abstract class DashboardEvent extends Equatable {
  const DashboardEvent();
  @override
  List<Object?> get props => [];
}

class DashboardInitialized extends DashboardEvent {
  const DashboardInitialized();
}

class DashboardRefreshed extends DashboardEvent {
  const DashboardRefreshed();
}

class DashboardPowerStatusChanged extends DashboardEvent {
  final PowerStatus status;
  const DashboardPowerStatusChanged(this.status);
  @override
  List<Object?> get props => [status];
}

// States
abstract class DashboardState extends Equatable {
  const DashboardState();
  @override
  List<Object?> get props => [];
}

class DashboardInitial extends DashboardState {
  const DashboardInitial();
}

class DashboardLoading extends DashboardState {
  const DashboardLoading();
}

class DashboardLoaded extends DashboardState {
  final DashboardSummary summary;
  final PowerStatus currentPowerStatus;
  final List<DailyStat> recentStats;
  final bool complaintReady;

  const DashboardLoaded({
    required this.summary,
    required this.currentPowerStatus,
    required this.recentStats,
    required this.complaintReady,
  });

  DashboardLoaded copyWith({
    DashboardSummary? summary,
    PowerStatus? currentPowerStatus,
    List<DailyStat>? recentStats,
    bool? complaintReady,
  }) =>
      DashboardLoaded(
        summary: summary ?? this.summary,
        currentPowerStatus: currentPowerStatus ?? this.currentPowerStatus,
        recentStats: recentStats ?? this.recentStats,
        complaintReady: complaintReady ?? this.complaintReady,
      );

  @override
  List<Object?> get props => [
        summary,
        currentPowerStatus,
        recentStats,
        complaintReady,
      ];
}

class DashboardError extends DashboardState {
  final String message;
  const DashboardError(this.message);
  @override
  List<Object?> get props => [message];
}

// BLoC
class DashboardBloc extends Bloc<DashboardEvent, DashboardState> {
  final GetDashboardSummaryUseCase _getDashboardSummary;
  final GetDailyStatsUseCase _getDailyStats;
  final WatchPowerStatusUseCase _watchPowerStatus;

  StreamSubscription<PowerStatus>? _powerStatusSub;

  DashboardBloc({
    required GetDashboardSummaryUseCase getDashboardSummary,
    required GetDailyStatsUseCase getDailyStats,
    required WatchPowerStatusUseCase watchPowerStatus,
  })  : _getDashboardSummary = getDashboardSummary,
        _getDailyStats = getDailyStats,
        _watchPowerStatus = watchPowerStatus,
        super(const DashboardInitial()) {
    on<DashboardInitialized>(_onInitialized);
    on<DashboardRefreshed>(_onRefreshed);
    on<DashboardPowerStatusChanged>(_onPowerStatusChanged);
  }

  Future<void> _onInitialized(
    DashboardInitialized event,
    Emitter<DashboardState> emit,
  ) async {
    emit(const DashboardLoading());
    await _loadData(emit);

    // Start watching power status
    await _powerStatusSub?.cancel();
    _powerStatusSub = _watchPowerStatus().listen(
      (status) => add(DashboardPowerStatusChanged(status)),
    );
  }

  Future<void> _onRefreshed(
    DashboardRefreshed event,
    Emitter<DashboardState> emit,
  ) async {
    await _loadData(emit);
  }

  void _onPowerStatusChanged(
    DashboardPowerStatusChanged event,
    Emitter<DashboardState> emit,
  ) {
    if (state is DashboardLoaded) {
      emit((state as DashboardLoaded).copyWith(
        currentPowerStatus: event.status,
      ));
    }
  }

  Future<void> _loadData(Emitter<DashboardState> emit) async {
    final summaryResult = await _getDashboardSummary();
    final statsResult = await _getDailyStats(days: 30);

    summaryResult.fold(
      (failure) => emit(DashboardError(failure.message)),
      (summary) {
        final stats = statsResult.fold((_) => <DailyStat>[], (s) => s);
        final complaintReady = summary.isBelowThreshold &&
            stats.length >= AppConstants.complaintThresholdDays;

        emit(DashboardLoaded(
          summary: summary,
          currentPowerStatus: PowerStatus.unknown,
          recentStats: stats,
          complaintReady: complaintReady,
        ));
      },
    );
  }

  @override
  Future<void> close() {
    _powerStatusSub?.cancel();
    return super.close();
  }
}
