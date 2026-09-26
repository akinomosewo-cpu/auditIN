import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/routing/app_page_route.dart';
import '../../../data/models/auth_credential_model.dart';
import '../../../domain/services/auth_service.dart';
import '../app_shell.dart';
import 'login_page.dart';
import 'signup_page.dart';

/// The very first screen the app shows: a brief animated brand reveal that
/// then routes to the dashboard (already logged in), the login screen
/// (an account exists on this device but the session is logged out), or
/// sign-up (first launch).
class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scale;
  late final Animation<double> _opacity;

  static const _minSplashDuration = Duration(milliseconds: 1400);

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _scale = Tween<double>(begin: 0.7, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.elasticOut),
    );
    _opacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
      ),
    );
    _controller.forward();
    _navigateWhenReady();
  }

  Future<void> _navigateWhenReady() async {
    final stopwatch = Stopwatch()..start();
    final authService = AuthService(
      authBox: Hive.box<AuthCredentialModel>(AuthService.authBoxName),
      settingsBox: Hive.box(AppConstants.settingsBox),
    );

    // Give the reveal animation room to breathe even if everything else
    // resolves instantly.
    final remaining = _minSplashDuration - stopwatch.elapsed;
    if (remaining > Duration.zero) {
      await Future.delayed(remaining);
    }

    if (!mounted) return;

    Widget destination;
    if (authService.isLoggedIn()) {
      destination = const AppShell();
    } else if (authService.hasAccount()) {
      destination = const LoginPage();
    } else {
      destination = const SignUpPage();
    }

    Navigator.of(context).pushReplacement(
      AppPageRoute(builder: (_) => destination),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return Opacity(
              opacity: _opacity.value,
              child: Transform.scale(
                scale: _scale.value,
                child: child,
              ),
            );
          },
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 88,
                height: 88,
                decoration: BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withOpacity(0.35),
                      blurRadius: 32,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.bolt_rounded,
                  color: Colors.white,
                  size: 48,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                AppConstants.appName,
                style: AppTextStyles.headlineLarge.copyWith(
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Track it. Prove it. Complain smarter.',
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
