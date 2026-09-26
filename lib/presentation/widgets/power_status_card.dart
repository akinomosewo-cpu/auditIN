import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:gap/gap.dart';
import '../../core/constants/app_constants.dart';
import '../../core/theme/app_theme.dart';

class PowerStatusCard extends StatelessWidget {
  final PowerStatus status;
  final ElectricityBand band;
  final double todayHoursOn;
  final double promisedHours;

  const PowerStatusCard({
    super.key,
    required this.status,
    required this.band,
    required this.todayHoursOn,
    required this.promisedHours,
  });

  @override
  Widget build(BuildContext context) {
    final isOn = status == PowerStatus.on;
    final progress = (todayHoursOn / promisedHours).clamp(0.0, 1.0);
    final progressPercent = (progress * 100).toStringAsFixed(0);
    final gradient = isOn ? AppColors.powerOnGradient : AppColors.powerOffGradient;
    final statusColor = isOn ? AppColors.success : AppColors.danger;
    final statusLabel = isOn ? 'POWER ON' : 'POWER OFF';

    final bandColor = AppColors.forBand(band.label.replaceAll('Band ', ''));

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: statusColor.withOpacity(0.14),
            blurRadius: 28,
            spreadRadius: 0,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Status indicator row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      color: statusColor,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: statusColor.withOpacity(0.5),
                          blurRadius: 6,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                  )
                      .animate(
                        onPlay: (controller) => controller.repeat(),
                      )
                      .scale(
                        begin: const Offset(1, 1),
                        end: const Offset(1.3, 1.3),
                        duration: 1000.ms,
                        curve: Curves.easeInOut,
                      )
                      .then()
                      .scale(
                        begin: const Offset(1.3, 1.3),
                        end: const Offset(1, 1),
                        duration: 1000.ms,
                      ),
                  const Gap(8),
                  Text(
                    statusLabel,
                    style: AppTextStyles.labelSmall.copyWith(
                      color: statusColor,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.2,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: bandColor.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(100),
                ),
                child: Text(
                  band.label,
                  style: AppTextStyles.labelSmall.copyWith(
                    color: bandColor,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),

          const Gap(20),

          // Hours display
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              ShaderMask(
                shaderCallback: (bounds) => gradient.createShader(bounds),
                child: Text(
                  todayHoursOn.toStringAsFixed(1),
                  style: AppTextStyles.monoLarge.copyWith(
                    color: Colors.white,
                    fontSize: 58,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              const Gap(6),
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'hrs today',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                    Text(
                      'of ${promisedHours.toInt()} promised',
                      style: AppTextStyles.labelSmall.copyWith(
                        color: AppColors.textTertiary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const Gap(20),

          // Progress bar
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Today\'s supply target',
                    style: AppTextStyles.labelMedium.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  Text(
                    '$progressPercent%',
                    style: AppTextStyles.labelMedium.copyWith(
                      color: statusColor,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              const Gap(8),
              ClipRRect(
                borderRadius: BorderRadius.circular(100),
                child: LinearProgressIndicator(
                  value: progress,
                  backgroundColor: AppColors.surfaceElevated,
                  valueColor: AlwaysStoppedAnimation<Color>(statusColor),
                  minHeight: 8,
                ),
              ),
            ],
          ),

          const Gap(20),

          // Quick action chips
          Row(
            children: [
              _ActionChip(
                label: 'Log Outage',
                icon: Icons.report_outlined,
                onTap: () {},
              ),
              const Gap(8),
              _ActionChip(
                label: 'View Logs',
                icon: Icons.list_alt_rounded,
                onTap: () {},
              ),
              const Gap(8),
              _ActionChip(
                label: 'Complain',
                icon: Icons.send_rounded,
                onTap: () {},
                highlight: true,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ActionChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;
  final bool highlight;

  const _ActionChip({
    required this.label,
    required this.icon,
    required this.onTap,
    this.highlight = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: highlight
              ? AppColors.primary.withOpacity(0.15)
              : AppColors.surfaceElevated,
          borderRadius: BorderRadius.circular(100),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 13,
              color: highlight ? AppColors.primary : AppColors.textSecondary,
            ),
            const Gap(4),
            Text(
              label,
              style: AppTextStyles.labelSmall.copyWith(
                color: highlight ? AppColors.primary : AppColors.textSecondary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
