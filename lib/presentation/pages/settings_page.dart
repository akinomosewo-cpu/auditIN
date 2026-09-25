import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import '../../core/theme/app_theme.dart';
import '../../core/constants/app_constants.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool _trackingEnabled = true;
  bool _notificationsEnabled = true;
  ElectricityBand _selectedBand = ElectricityBand.a;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          'Settings',
          style: AppTextStyles.headlineMedium.copyWith(
            color: AppColors.textPrimary,
          ),
        ),
        backgroundColor: AppColors.background,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Profile Section
            _SectionTitle(title: 'Your Profile'),
            const Gap(12),
            _SettingsTile(
              icon: Icons.badge_outlined,
              label: 'Meter Number',
              value: 'Not set',
              onTap: () {},
            ),
            _SettingsTile(
              icon: Icons.location_on_outlined,
              label: 'Your Feeder',
              value: 'Not set',
              onTap: () {},
            ),
            _SettingsTile(
              icon: Icons.home_outlined,
              label: 'Address',
              value: 'Not set',
              onTap: () {},
            ),

            const Gap(24),
            _SectionTitle(title: 'Electricity Band'),
            const Gap(12),

            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                children: ElectricityBand.values.map((band) {
                  final isSelected = band == _selectedBand;
                  return GestureDetector(
                    onTap: () => setState(() => _selectedBand = band),
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppColors.primary.withOpacity(0.12)
                            : AppColors.surfaceElevated,
                        borderRadius: BorderRadius.circular(10),
                        border: isSelected
                            ? Border.all(
                                color: AppColors.primary.withOpacity(0.4))
                            : null,
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  band.label,
                                  style: AppTextStyles.headlineSmall.copyWith(
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                                Text(
                                  '${band.promisedHours}+ hrs/day · ₦${band.ratePerUnit}/kWh',
                                  style: AppTextStyles.labelMedium.copyWith(
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (isSelected)
                            const Icon(
                              Icons.check_circle_rounded,
                              color: AppColors.primary,
                              size: 20,
                            ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),

            const Gap(24),
            _SectionTitle(title: 'Tracking'),
            const Gap(12),

            _ToggleTile(
              icon: Icons.track_changes_rounded,
              label: 'Background Tracking',
              subtitle: 'Automatically log power on/off events',
              value: _trackingEnabled,
              onChanged: (v) => setState(() => _trackingEnabled = v),
            ),

            const Gap(8),

            _ToggleTile(
              icon: Icons.notifications_outlined,
              label: 'Notifications',
              subtitle: 'Get alerts on outages and daily summaries',
              value: _notificationsEnabled,
              onChanged: (v) => setState(() => _notificationsEnabled = v),
            ),

            const Gap(24),
            _SectionTitle(title: 'Data'),
            const Gap(12),

            _SettingsTile(
              icon: Icons.download_outlined,
              label: 'Export My Data',
              value: 'CSV / PDF',
              onTap: () {},
            ),
            _SettingsTile(
              icon: Icons.delete_outline_rounded,
              label: 'Clear All Logs',
              value: '',
              onTap: () {},
              destructive: true,
            ),

            const Gap(40),
            Center(
              child: Text(
                '${AppConstants.appName} v${AppConstants.appVersion}',
                style: AppTextStyles.labelSmall.copyWith(
                  color: AppColors.textTertiary,
                ),
              ),
            ),
            const Gap(24),
          ],
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  const _SectionTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(
      title.toUpperCase(),
      style: AppTextStyles.labelSmall.copyWith(
        color: AppColors.textSecondary,
        letterSpacing: 1.0,
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final VoidCallback onTap;
  final bool destructive;

  const _SettingsTile({
    required this.icon,
    required this.label,
    required this.value,
    required this.onTap,
    this.destructive = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 18,
              color: destructive ? AppColors.danger : AppColors.textSecondary,
            ),
            const Gap(12),
            Expanded(
              child: Text(
                label,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: destructive
                      ? AppColors.danger
                      : AppColors.textPrimary,
                ),
              ),
            ),
            if (value.isNotEmpty)
              Text(
                value,
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            const Gap(6),
            Icon(
              Icons.chevron_right_rounded,
              size: 18,
              color: AppColors.textTertiary,
            ),
          ],
        ),
      ),
    );
  }
}

class _ToggleTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _ToggleTile({
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Icon(icon, size: 18, color: AppColors.textSecondary),
          const Gap(12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.textPrimary,
                  ),
                ),
                Text(
                  subtitle,
                  style: AppTextStyles.labelSmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: AppColors.primary,
          ),
        ],
      ),
    );
  }
}
