import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'core/theme/app_theme.dart';
import 'core/constants/app_constants.dart';
import 'data/models/power_log_model.dart';
import 'data/datasources/power_local_datasource.dart';
import 'data/repositories/power_repository_impl.dart';
import 'domain/usecases/power_usecases.dart';
import 'presentation/blocs/dashboard/dashboard_bloc.dart';
import 'presentation/blocs/history/history_bloc.dart';
import 'presentation/pages/app_shell.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // System UI
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: AppColors.background,
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );

  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Init Hive
  await Hive.initFlutter();
  Hive.registerAdapter(PowerLogModelAdapter());
  Hive.registerAdapter(DailyStatModelAdapter());
  Hive.registerAdapter(UserProfileModelAdapter());
  Hive.registerAdapter(ComplaintModelAdapter());

  await Future.wait([
    Hive.openBox<PowerLogModel>(AppConstants.powerLogBox),
    Hive.openBox<DailyStatModel>(AppConstants.dailyStatsBox),
    Hive.openBox<UserProfileModel>('profile_box'),
    Hive.openBox<ComplaintModel>(AppConstants.complaintBox),
    Hive.openBox(AppConstants.settingsBox),
  ]);

  // Wire up dependencies
  final dataSource = PowerLocalDataSourceImpl();
  final repository = PowerRepositoryImpl(dataSource: dataSource);

  final getDashboardSummary = GetDashboardSummaryUseCase(repository);
  final getDailyStats = GetDailyStatsUseCase(repository);
  final watchPowerStatus = WatchPowerStatusUseCase(repository);
  final generateComplaint = GenerateComplaintUseCase(repository);
  final savePowerLog = SavePowerLogUseCase(repository);

  runApp(
    MultiRepositoryProvider(
      providers: [
        RepositoryProvider.value(value: repository),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (_) => DashboardBloc(
              getDashboardSummary: getDashboardSummary,
              getDailyStats: getDailyStats,
              watchPowerStatus: watchPowerStatus,
            ),
          ),
          BlocProvider(
            create: (_) => HistoryBloc(
              getDailyStats: getDailyStats,
            ),
          ),
        ],
        child: const BandAAuditApp(),
      ),
    ),
  );
}

class BandAAuditApp extends StatelessWidget {
  const BandAAuditApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: ThemeMode.dark,
      home: const AppShell(),
    );
  }
}
