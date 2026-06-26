import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_breakpoints.dart';
import '../../../../core/routing/app_route.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../domain/repositories/auth_repository.dart';
import '../controllers/auth_controller.dart';
import '../widgets/login_brand_header.dart';
import '../widgets/login_form_card.dart';
import '../widgets/temporary_admin_bootstrap_button.dart';

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  static const _logoAsset = 'assets/images/jce_logo.jpg';
  static const _coverLogoAsset = 'assets/images/jce_cover_logo.jpg';

  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _isSubmitting = false;
  bool _obscurePassword = true;
  String? _errorMessage;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final authState = ref.watch(authControllerProvider);
    final authError = authState.whenOrNull(
      error: (error, _) => error is AuthException
          ? error.message
          : 'Your account access could not be resolved.',
    );
    final session = authState.asData?.value;

    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          Opacity(
            opacity: 0.7,
            child: Image.asset(_coverLogoAsset, fit: BoxFit.cover),
          ),
          ColoredBox(
            color: theme.scaffoldBackgroundColor.withValues(
              alpha: isDark ? 0.68 : 0.52,
            ),
          ),
          SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final isCompact = constraints.maxWidth < AppBreakpoints.compact;

                return Center(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.symmetric(
                      horizontal: isCompact ? AppSpacing.lg : AppSpacing.xxl,
                      vertical: AppSpacing.xxl,
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const LoginBrandHeader(logoAsset: _logoAsset),
                        const SizedBox(height: AppSpacing.xl),
                        LoginFormCard(
                          formKey: _formKey,
                          emailController: _emailController,
                          passwordController: _passwordController,
                          isSubmitting: _isSubmitting,
                          obscurePassword: _obscurePassword,
                          errorMessage:
                              _errorMessage ??
                              authError ??
                              (session != null && session.permissions.isEmpty
                                  ? 'This account currently has no permissions.'
                                  : null),
                          isCompact: isCompact,
                          onSubmit: _submit,
                          onTogglePasswordVisibility: () {
                            setState(() {
                              _obscurePassword = !_obscurePassword;
                            });
                          },
                          onForgotPassword: _showForgotPasswordMessage,
                        ),
                        const SizedBox(height: AppSpacing.md),
                        TemporaryAdminBootstrapButton(
                          onCreated: (result) {
                            _emailController.text = result.email;
                            _passwordController.text = result.password;
                            ref.invalidate(authControllerProvider);
                            setState(() {
                              _errorMessage = null;
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate() || _isSubmitting) {
      return;
    }

    TextInput.finishAutofillContext();
    setState(() {
      _errorMessage = null;
      _isSubmitting = true;
    });

    try {
      await ref
          .read(authControllerProvider.notifier)
          .signIn(
            email: _emailController.text,
            password: _passwordController.text,
          );
      if (mounted) {
        context.go(AppRoute.dashboard.path);
      }
    } on AuthException catch (error) {
      if (mounted) {
        setState(() {
          _errorMessage = error.message;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Unable to login right now.';
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  Future<void> _showForgotPasswordMessage() async {
    try {
      await ref
          .read(authControllerProvider.notifier)
          .sendPasswordResetEmail(_emailController.text);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'If the account exists, a password reset email has been sent.',
            ),
          ),
        );
      }
    } on AuthException catch (error) {
      if (mounted) {
        setState(() {
          _errorMessage = error.message;
        });
      }
    }
  }
}
