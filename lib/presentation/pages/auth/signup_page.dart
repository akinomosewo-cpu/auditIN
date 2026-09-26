import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:gap/gap.dart';
import 'package:hive/hive.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/routing/app_page_route.dart';
import '../../../data/models/auth_credential_model.dart';
import '../../../domain/services/auth_service.dart';
import '../app_shell.dart';
import 'login_page.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _accountController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();
  bool _obscurePassword = true;
  bool _isSubmitting = false;
  String? _errorMessage;

  late final AuthService _authService = AuthService(
    authBox: Hive.box<AuthCredentialModel>(AuthService.authBoxName),
    settingsBox: Hive.box(AppConstants.settingsBox),
  );

  @override
  void dispose() {
    _nameController.dispose();
    _accountController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isSubmitting = true;
      _errorMessage = null;
    });

    try {
      await _authService.signUp(
        name: _nameController.text,
        accountNumber: _accountController.text,
        password: _passwordController.text,
      );
      if (!mounted) return;
      Navigator.of(context).pushAndRemoveUntil(
        AppPageRoute(builder: (_) => const AppShell()),
        (route) => false,
      );
    } on AuthException catch (e) {
      setState(() => _errorMessage = e.message);
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Gap(40),
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    gradient: AppColors.primaryGradient,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Icon(Icons.bolt_rounded,
                      color: Colors.white, size: 30),
                ).animate().fadeIn().scale(begin: const Offset(0.8, 0.8)),
                const Gap(24),
                Text(
                  'Create your account',
                  style: AppTextStyles.displaySmall.copyWith(
                    color: AppColors.textPrimary,
                  ),
                ).animate().fadeIn(delay: 80.ms).slideY(begin: 0.15),
                const Gap(6),
                Text(
                  'Set up local tracking for your AEDC meter.',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ).animate().fadeIn(delay: 120.ms).slideY(begin: 0.15),
                const Gap(28),

                _FieldLabel('Full name'),
                const Gap(8),
                TextFormField(
                  controller: _nameController,
                  textCapitalization: TextCapitalization.words,
                  decoration: const InputDecoration(hintText: 'e.g. Amaka Okafor'),
                  validator: (v) =>
                      (v == null || v.trim().isEmpty) ? 'Enter your name' : null,
                ).animate().fadeIn(delay: 150.ms).slideY(begin: 0.1),
                const Gap(16),

                _FieldLabel('AEDC account / meter number'),
                const Gap(8),
                TextFormField(
                  controller: _accountController,
                  decoration:
                      const InputDecoration(hintText: 'e.g. 04123456789'),
                  validator: (v) => (v == null || v.trim().isEmpty)
                      ? 'Enter your account/meter number'
                      : null,
                ).animate().fadeIn(delay: 180.ms).slideY(begin: 0.1),
                const Gap(16),

                _FieldLabel('Password'),
                const Gap(8),
                TextFormField(
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  decoration: InputDecoration(
                    hintText: 'At least 4 characters',
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined,
                        color: AppColors.textSecondary,
                      ),
                      onPressed: () => setState(
                          () => _obscurePassword = !_obscurePassword),
                    ),
                  ),
                  validator: (v) => (v == null || v.length < 4)
                      ? 'Password must be at least 4 characters'
                      : null,
                ).animate().fadeIn(delay: 210.ms).slideY(begin: 0.1),
                const Gap(16),

                _FieldLabel('Confirm password'),
                const Gap(8),
                TextFormField(
                  controller: _confirmController,
                  obscureText: _obscurePassword,
                  decoration: const InputDecoration(hintText: 'Repeat password'),
                  validator: (v) => (v != _passwordController.text)
                      ? 'Passwords do not match'
                      : null,
                  onFieldSubmitted: (_) => _submit(),
                ).animate().fadeIn(delay: 240.ms).slideY(begin: 0.1),

                if (_errorMessage != null) ...[
                  const Gap(14),
                  Text(
                    _errorMessage!,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.danger,
                    ),
                  ),
                ],

                const Gap(28),
                ElevatedButton(
                  onPressed: _isSubmitting ? null : _submit,
                  child: _isSubmitting
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.4,
                            color: Colors.white,
                          ),
                        )
                      : const Text('Sign Up'),
                ).animate().fadeIn(delay: 270.ms).slideY(begin: 0.1),
                const Gap(16),

                Center(
                  child: TextButton(
                    onPressed: _isSubmitting
                        ? null
                        : () {
                            Navigator.of(context).pushReplacement(
                              AppPageRoute(builder: (_) => const LoginPage()),
                            );
                          },
                    child: Text(
                      'Already have an account? Log in',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ).animate().fadeIn(delay: 300.ms),
                const Gap(24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _FieldLabel extends StatelessWidget {
  final String label;
  const _FieldLabel(this.label);

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: AppTextStyles.labelMedium.copyWith(
        color: AppColors.textSecondary,
        fontWeight: FontWeight.w600,
      ),
    );
  }
}
