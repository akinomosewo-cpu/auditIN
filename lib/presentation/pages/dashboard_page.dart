import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:gap/gap.dart';
import '../../core/constants/app_constants.dart';
import '../../core/theme/app_theme.dart';
import '../../domain/entities/power_log.dart';
import '../blocs/dashboard/dashboard_bloc.dart';
import '../widgets/power_status_card.dart';
import '../widgets/stat_card.dart';
import '../widgets/mini_chart_widget.dart';
import '../widgets/complaint_banner.dart';
import '../widgets/section_header.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  @override
  void initState() {
    super.initState();
    context.read<DashboardBloc>().add(const DashboardInitialized());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: BlocBuilder<DashboardBloc, DashboardState>(
          builder: (context, state) {
            if (state is DashboardLoading) {
              return const _DashboardSkeleton();
            }

            if (state is DashboardError) {
              return _ErrorView(message: state.message);
            }

            if (state is DashboardLoaded) {
              return _DashboardContent(state: state);
            }

            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }
}

class _DashboardContent extends StatelessWidget {
  final DashboardLoaded state;

  const _DashboardContent({required this.state});

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () async {
        context.read<DashboardBloc>().add(const DashboardRefreshed());
      },
      color: AppColors.primary,
      backgroundColor: AppColors.surface,
      child: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          // App Bar
          SliverAppBar(
            backgroundColor: AppColors.background,
            floating: true,
            snap: true,
            title: Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    gradient: AppColors.primaryGradient,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.bolt_rounded,
                    color: Colors.white,
                    size: 18,
                  ),
                ),
                const Gap(10),
                Text(
                  'Band A Audit',
                  style: AppTextStyles.headlineMedium.copyWith(
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.notifications_outlined),
                color: AppColors.textPrimary,
                onPressed: () {},
              ),
              IconButton(
                icon: const Icon(Icons.person_outline_rounded),
                color: AppColors.textPrimary,
                onPressed: () {},
              ),
              const Gap(4),
            ],
          ),

          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                const Gap(8),

                // Complaint Banner (if applicable)
                if (state.complaintReady)
                  ComplaintBanner(
                    onTap: () {},
                  ).animate().fadeIn().slideY(begin: -0.2),

                if (state.complaintReady) const Gap(16),

                // Power Status Card (hero element)
                PowerStatusCard(
                  status: state.currentPowerStatus,
                  band: state.summary.userProfile?.band ?? ElectricityBand.a,
                  todayHoursOn: state.summary.todayStat?.hoursOn ?? 0,
                  promisedHours:
                      state.summary.userProfile?.band.promisedHours.toDouble() ?? 20,
                ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.1),

                const Gap(24),

                // Quick Stats Row
                const SectionHeader(
                  title: 'Last 30 Days',
                  subtitle: 'Supply performance overview',
                ),
                const Gap(12),

                Row(
                  children: [
                    Expanded(
                      child: StatCard(
                        label: 'Avg Hours/Day',
                        value: state.summary.averageHoursPerDay
                            .toStringAsFixed(1),
                        unit: 'hrs',
                        icon: Icons.access_time_rounded,
                        color: _getHoursColor(
                          state.summary.averageHoursPerDay,
                          state.summary.userProfile?.band.promisedHours
                                  .toDouble() ??
                              20,
                        ),
                        trend: state.summary.fulfillmentRate,
                      ).animate(delay: 100.ms).fadeIn().slideY(begin: 0.1),
                    ),
                    const Gap(12),
                    Expanded(
                      child: StatCard(
                        label: 'Deficit Hours',
                        value: state.summary.totalDeficitHours
                            .toStringAsFixed(0),
                        unit: 'hrs',
                        icon: Icons.battery_alert_rounded,
                        color: AppColors.danger,
                      ).animate(delay: 150.ms).fadeIn().slideY(begin: 0.1),
                    ),
                  ],
                ),

                const Gap(12),

                Row(
                  children: [
                    Expanded(
                      child: StatCard(
                        label: 'Outages',
                        value: state.summary.totalOutages.toString(),
                        unit: 'total',
                        icon: Icons.power_off_rounded,
                        color: AppColors.warning,
                      ).animate(delay: 200.ms).fadeIn().slideY(begin: 0.1),
                    ),
                    const Gap(12),
                    Expanded(
                      child: StatCard(
                        label: 'Est. Overcharge',
                        value:
                            '₦${_formatMoney(state.summary.estimatedOvercharge)}',
                        unit: '',
                        icon: Icons.payments_outlined,
                        color: AppColors.danger,
                      ).animate(delay: 250.ms).fadeIn().slideY(begin: 0.1),
                    ),
                  ],
                ),

                const Gap(24),

                // Mini Chart
                const SectionHeader(
                  title: 'Supply History',
                  subtitle: 'Daily hours on grid',
                  actionLabel: 'See all',
                ),
                const Gap(12),

                if (state.recentStats.isNotEmpty)
                  MiniChartWidget(
                    stats: state.recentStats,
                    promisedHours: state.summary.userProfile?.band.promisedHours
                            .toDouble() ??
                        20,
                  ).animate(delay: 300.ms).fadeIn(),

                const Gap(24),

                // Feeder Info
                if (state.summary.userProfile != null)
                  _FeederInfoCard(
                    userProfile: state.summary.userProfile!,
                  ).animate(delay: 350.ms).fadeIn().slideY(begin: 0.1),

                const Gap(32),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Color _getHoursColor(double actual, double promised) {
    final ratio = actual / promised;
    if (ratio >= 0.9) return AppColors.success;
    if (ratio >= 0.6) return AppColors.warning;
    return AppColors.danger;
  }

  String _formatMoney(double amount) {
    if (amount >= 1000) {
      return '${(amount / 1000).toStringAsFixed(1)}k';
    }
    return amount.toStringAsFixed(0);
  }
}

class _FeederInfoCard extends StatelessWidget {
  final UserProfile userProfile;

  const _FeederInfoCard({required this.userProfile});

  @override
  Widget build(BuildContext context) {
    final bandColor =
        AppColors.forBand(userProfile.band.label.replaceAll('Band ', ''));

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: AppColors.cardShadow,
            blurRadius: 20,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(9),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.14),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.electrical_services_rounded,
                  color: AppColors.primary,
                  size: 16,
                ),
              ),
              const Gap(10),
              Text(
                'Your Feeder Info',
                style: AppTextStyles.headlineSmall.copyWith(
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const Gap(16),
          _InfoRow(label: 'Feeder', value: userProfile.feederName),
          const Gap(10),
          _InfoRow(label: 'District', value: userProfile.district),
          const Gap(10),
          _InfoRow.chip(
            label: 'Band',
            value: userProfile.band.label,
            chipColor: bandColor,
          ),
          const Gap(10),
          _InfoRow(
            label: 'Promised Hours',
            value: '${userProfile.band.promisedHours}+ hrs/day',
          ),
          const Gap(8),
          _InfoRow(
            label: 'Rate',
            value: '₦${userProfile.band.ratePerUnit}/kWh',
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  final Color? chipColor;

  const _InfoRow({required this.label, required this.value})
      : chipColor = null;

  const _InfoRow.chip({
    required this.label,
    required this.value,
    required Color this.chipColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: AppTextStyles.bodySmall.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        if (chipColor != null)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: chipColor!.withOpacity(0.15),
              borderRadius: BorderRadius.circular(100),
            ),
            child: Text(
              value,
              style: AppTextStyles.labelSmall.copyWith(
                color: chipColor,
                fontWeight: FontWeight.w700,
              ),
            ),
          )
        else
          Text(
            value,
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w500,
            ),
          ),
      ],
    );
  }
}

class _DashboardSkeleton extends StatelessWidget {
  const _DashboardSkeleton();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: CircularProgressIndicator(color: AppColors.primary),
    );
  }
}

class _ErrorView extends StatelessWidget {
  final String message;

  const _ErrorView({required this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline_rounded,
              color: AppColors.danger,
              size: 48,
            ),
            const Gap(16),
            Text(
              'Something went wrong',
              style: AppTextStyles.headlineMedium.copyWith(
                color: AppColors.textPrimary,
              ),
            ),
            const Gap(8),
            Text(
              message,
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const Gap(24),
            ElevatedButton(
              onPressed: () {
                context.read<DashboardBloc>().add(const DashboardRefreshed());
              },
              child: const Text('Try Again'),
            ),
          ],
        ),
      ),
    );
  }
}
