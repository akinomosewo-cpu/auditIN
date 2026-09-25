import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../domain/entities/power_log.dart';
import '../../../domain/usecases/power_usecases.dart';

// Events
abstract class HistoryEvent extends Equatable {
  const HistoryEvent();
  @override
  List<Object?> get props => [];
}

class HistoryLoaded extends HistoryEvent {
  final int days;
  const HistoryLoaded({this.days = 30});
  @override
  List<Object?> get props => [days];
}

class HistoryPeriodChanged extends HistoryEvent {
  final int days;
  const HistoryPeriodChanged(this.days);
  @override
  List<Object?> get props => [days];
}

// States
abstract class HistoryState extends Equatable {
  const HistoryState();
  @override
  List<Object?> get props => [];
}

class HistoryInitial extends HistoryState {
  const HistoryInitial();
}

class HistoryLoading extends HistoryState {
  const HistoryLoading();
}

class HistoryDataLoaded extends HistoryState {
  final List<DailyStat> stats;
  final int selectedDays;
  final HistoryAggregates aggregates;

  const HistoryDataLoaded({
    required this.stats,
    required this.selectedDays,
    required this.aggregates,
  });

  @override
  List<Object?> get props => [stats, selectedDays, aggregates];
}

class HistoryError extends HistoryState {
  final String message;
  const HistoryError(this.message);
  @override
  List<Object?> get props => [message];
}

class HistoryAggregates extends Equatable {
  final double averageHoursOn;
  final double totalHoursOn;
  final double totalHoursOff;
  final int totalOutages;
  final int daysMetPromise;
  final int daysFailedPromise;
  final double worstDay;
  final double bestDay;

  const HistoryAggregates({
    required this.averageHoursOn,
    required this.totalHoursOn,
    required this.totalHoursOff,
    required this.totalOutages,
    required this.daysMetPromise,
    required this.daysFailedPromise,
    required this.worstDay,
    required this.bestDay,
  });

  double get reliabilityScore => daysMetPromise / (daysMetPromise + daysFailedPromise) * 100;

  @override
  List<Object?> get props => [
        averageHoursOn,
        totalHoursOn,
        totalHoursOff,
        totalOutages,
        daysMetPromise,
        daysFailedPromise,
        worstDay,
        bestDay,
      ];
}

// BLoC
class HistoryBloc extends Bloc<HistoryEvent, HistoryState> {
  final GetDailyStatsUseCase _getDailyStats;

  HistoryBloc({required GetDailyStatsUseCase getDailyStats})
      : _getDailyStats = getDailyStats,
        super(const HistoryInitial()) {
    on<HistoryLoaded>(_onLoaded);
    on<HistoryPeriodChanged>(_onPeriodChanged);
  }

  Future<void> _onLoaded(
    HistoryLoaded event,
    Emitter<HistoryState> emit,
  ) async {
    emit(const HistoryLoading());
    await _fetchStats(emit, event.days);
  }

  Future<void> _onPeriodChanged(
    HistoryPeriodChanged event,
    Emitter<HistoryState> emit,
  ) async {
    if (state is HistoryDataLoaded) {
      emit(HistoryLoading());
    }
    await _fetchStats(emit, event.days);
  }

  Future<void> _fetchStats(Emitter<HistoryState> emit, int days) async {
    final result = await _getDailyStats(days: days);
    result.fold(
      (failure) => emit(HistoryError(failure.message)),
      (stats) {
        if (stats.isEmpty) {
          emit(HistoryDataLoaded(
            stats: [],
            selectedDays: days,
            aggregates: const HistoryAggregates(
              averageHoursOn: 0,
              totalHoursOn: 0,
              totalHoursOff: 0,
              totalOutages: 0,
              daysMetPromise: 0,
              daysFailedPromise: 0,
              worstDay: 0,
              bestDay: 0,
            ),
          ));
          return;
        }

        final aggregates = HistoryAggregates(
          averageHoursOn: stats.map((s) => s.hoursOn).reduce((a, b) => a + b) / stats.length,
          totalHoursOn: stats.map((s) => s.hoursOn).reduce((a, b) => a + b),
          totalHoursOff: stats.map((s) => s.hoursOff).reduce((a, b) => a + b),
          totalOutages: stats.map((s) => s.outageCount).reduce((a, b) => a + b),
          daysMetPromise: stats.where((s) => s.meetsPromise).length,
          daysFailedPromise: stats.where((s) => !s.meetsPromise).length,
          worstDay: stats.map((s) => s.hoursOn).reduce((a, b) => a < b ? a : b),
          bestDay: stats.map((s) => s.hoursOn).reduce((a, b) => a > b ? a : b),
        );

        emit(HistoryDataLoaded(
          stats: stats,
          selectedDays: days,
          aggregates: aggregates,
        ));
      },
    );
  }
}
