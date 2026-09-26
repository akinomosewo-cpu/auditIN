import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:gap/gap.dart';
import '../../core/theme/app_theme.dart';
import '../blocs/history/history_bloc.dart';
import '../widgets/section_header.dart';
import '../widgets/stat_card.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  final List<int> _periodOptions = [7, 14, 30, 90];
  int _selectedPeriod = 30;

  @override
  void initState() {
    super.initState();
    context.read<HistoryBloc>().add(HistoryLoaded(days: _selectedPeriod));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          'Supply History',
          style: AppTextStyles.headlineMedium.copyWith(
            color: AppColors.textPrimary,
          ),
        ),
        backgroundColor: AppColors.background,
        actions: [
          // Period Selector
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<int>(
                value: _selectedPeriod,
                dropdownColor: AppColors.surface,
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.primary,
                ),
                items: _periodOptions
                    .map(
                      (d) => DropdownMenuItem(
                        value: d,
                        child: Text('${d}d'),
                      ),
                    )
                    .toList(),
                onChanged: (val) {
                  if (val != null) {
                    setState(() => _selectedPeriod = val);
                    context
                        .read<HistoryBloc>()
                        .add(HistoryPeriodChanged(val));
                  }
                },
              ),
            ),
          ),
        ],
      ),
      body: BlocBuilder<HistoryBloc, HistoryState>(
        builder: (context, state) {
          if (state is HistoryLoading) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            );
          }

          if (state is HistoryDataLoaded) {
            return _HistoryContent(state: state);
          }

          if (state is HistoryError) {
            return Center(
              child: Text(
                state.message,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }
}

class _HistoryContent extends StatelessWidget {
  final HistoryDataLoaded state;

  const _HistoryContent({required this.state});

  @override
  Widget build(BuildContext context) {
    if (state.stats.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.bar_chart_rounded,
              color: AppColors.textTertiary,
              size: 48,
            ),
            const Gap(16),
            Text(
              'No data yet',
              style: AppTextStyles.headlineMedium.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            const Gap(8),
            Text(
              'The app will start tracking power supply automatically.',
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.textTertiary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    final agg = state.aggregates;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Summary stats
          Row(
            children: [
              Expanded(
                child: StatCard(
                  label: 'Avg Hours/Day',
                  value: agg.averageHoursOn.toStringAsFixed(1),
                  unit: 'hrs',
                  icon: Icons.access_time_rounded,
                  color: AppColors.primary,
                ).animate().fadeIn(delay: 50.ms),
              ),
              const Gap(12),
              Expanded(
                child: StatCard(
                  label: 'Reliability',
                  value: agg.reliabilityScore.toStringAsFixed(0),
                  unit: '%',
                  icon: Icons.verified_rounded,
                  color: agg.reliabilityScore >= 80
                      ? AppColors.success
                      : AppColors.danger,
                ).animate().fadeIn(delay: 100.ms),
              ),
            ],
          ),

          const Gap(12),

          Row(
            children: [
              Expanded(
                child: StatCard(
                  label: 'Days Passed',
                  value: agg.daysMetPromise.toString(),
                  unit: 'days',
                  icon: Icons.check_circle_outline_rounded,
                  color: AppColors.success,
                ).animate().fadeIn(delay: 150.ms),
              ),
              const Gap(12),
              Expanded(
                child: StatCard(
                  label: 'Days Failed',
                  value: agg.daysFailedPromise.toString(),
                  unit: 'days',
                  icon: Icons.cancel_outlined,
                  color: AppColors.danger,
                ).animate().fadeIn(delay: 200.ms),
              ),
            ],
          ),

          const Gap(24),

          // Bar chart
          const SectionHeader(
            title: 'Daily Hours On Grid',
            subtitle: 'Bar = actual supply. Line = promised.',
          ),
          const Gap(12),

          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.border),
            ),
            child: SizedBox(
              height: 200,
              child: BarChart(
                BarChartData(
                  maxY: 24,
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: false,
                    horizontalInterval: 6,
                    getDrawingHorizontalLine: (v) => FlLine(
                      color: AppColors.border.withOpacity(0.5),
                      strokeWidth: 0.5,
                    ),
                  ),
                  borderData: FlBorderData(show: false),
                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 28,
                        interval: 6,
                        getTitlesWidget: (v, _) => Text(
                          '${v.toInt()}h',
                          style: AppTextStyles.labelSmall.copyWith(
                            color: AppColors.textTertiary,
                          ),
                        ),
                      ),
                    ),
                    rightTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false)),
                    topTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false)),
                    bottomTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false)),
                  ),
                  barGroups: state.stats.asMap().entries.map((e) {
                    final stat = e.value;
                    final color = stat.meetsPromise
                        ? AppColors.success
                        : AppColors.danger;
                    return BarChartGroupData(
                      x: e.key,
                      barRods: [
                        BarChartRodData(
                          toY: stat.hoursOn,
                          color: color.withOpacity(0.8),
                          width: state.stats.length > 30 ? 4 : 8,
                          borderRadius: BorderRadius.circular(3),
                          backDrawRodData: BackgroundBarChartRodData(
                            show: true,
                            toY: 24,
                            color: AppColors.surfaceElevated,
                          ),
                        ),
                      ],
                    );
                  }).toList(),
                ),
              ),
            ),
          ).animate().fadeIn(delay: 250.ms),

          const Gap(32),
        ],
      ),
    );
  }
}
