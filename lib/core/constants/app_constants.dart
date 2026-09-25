class AppConstants {
  AppConstants._();

  // App Info
  static const String appName = 'Band A Audit';
  static const String appVersion = '1.0.0';

  // Storage Keys
  static const String keyUserBand = 'user_band';
  static const String keyUserFeeder = 'user_feeder';
  static const String keyUserLocation = 'user_location';
  static const String keyOnboardingComplete = 'onboarding_complete';
  static const String keyTrackingEnabled = 'tracking_enabled';
  static const String keyNotificationsEnabled = 'notifications_enabled';
  static const String keyThemeMode = 'theme_mode';
  static const String keyPowerLogs = 'power_logs';
  static const String keyDailyStats = 'daily_stats';
  static const String keyUserProfile = 'user_profile';

  // Hive Box Names
  static const String powerLogBox = 'power_log_box';
  static const String dailyStatsBox = 'daily_stats_box';
  static const String complaintBox = 'complaint_box';
  static const String settingsBox = 'settings_box';

  // Background Task
  static const String powerCheckTaskName = 'powerCheckTask';
  static const String dailySummaryTaskName = 'dailySummaryTask';
  static const Duration powerCheckInterval = Duration(minutes: 15);
  static const Duration dailySummaryInterval = Duration(hours: 24);

  // Electricity Tariff (AEDC rates as of Dec 2025)
  static const double bandARatePerUnit = 209.50;
  static const double bandBRatePerUnit = 62.48;
  static const double bandCRatePerUnit = 45.82;
  static const double bandDRatePerUnit = 35.56;
  static const double bandERatePerUnit = 4.00;

  // Band promised hours
  static const int bandAPromisedHours = 20;
  static const int bandBPromisedHours = 16;
  static const int bandCPromisedHours = 12;
  static const int bandDPromisedHours = 8;
  static const int bandEPromisedHours = 4;

  // Complaint thresholds
  static const int complaintThresholdDays = 7;
  static const double complaintThresholdPercent = 0.6; // 60% of promised hours

  // Notification IDs
  static const int notifPowerOn = 1001;
  static const int notifPowerOff = 1002;
  static const int notifDailySummary = 1003;
  static const int notifComplaintReady = 1004;
  static const int notifWeeklySummary = 1005;

  // AEDC Contact
  static const String aedcComplaintEmail = 'customercare@aedc.ng';
  static const String aedcPhone = '080 2320 0000';
  static const String nercPhone = '08043430000';
  static const String nercEmail = 'complaint@nerc.gov.ng';

  // Chart
  static const int chartDaysDefault = 30;
  static const int chartDaysMax = 90;
}

enum ElectricityBand {
  a('Band A', 20, 209.50),
  b('Band B', 16, 62.48),
  c('Band C', 12, 45.82),
  d('Band D', 8, 35.56),
  e('Band E', 4, 4.00);

  const ElectricityBand(this.label, this.promisedHours, this.ratePerUnit);

  final String label;
  final int promisedHours;
  final double ratePerUnit;
}

enum PowerStatus {
  on,
  off,
  unknown,
}

enum ComplaintStatus {
  draft,
  ready,
  sent,
  acknowledged,
}

enum AppPage {
  dashboard,
  history,
  map,
  complaints,
  settings,
}
