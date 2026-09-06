import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../common/widgets/app_logo_mark.dart';
import '../../../config/app_config.dart';
import '../../../theme/app_theme.dart';
import '../auth_validators.dart';
import '../widgets/auth_error_text.dart';
import '../widgets/auth_primary_button.dart';
import '../widgets/auth_text_field.dart';
import 'auth_provider.dart';
import 'register_view.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit(AuthProvider authProvider) async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    await authProvider.signIn(
      email: _emailController.text.trim(),
      password: _passwordController.text,
    );
  }

  void _openRegister() {
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => const RegisterView()));
  }

  void _notAvailableYet(String feature) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('$feature isn\'t available yet.')));
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    return Scaffold(
      backgroundColor: AppTheme.screenGround,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 40, 24, 24),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 400),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const AppLogoMark(),
                    const SizedBox(height: AppTheme.spacing28),
                    Text('Welcome back', style: AppTheme.heading),
                    const SizedBox(height: AppTheme.spacing6),
                    Text(
                      'Sign in to book with the ${AppConfig.companyName} team.',
                      style: AppTheme.subtitle,
                    ),
                    const SizedBox(height: AppTheme.spacing28),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        AuthTextField(
                          label: 'Email',
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          autofillHints: const [AutofillHints.email],
                          validator: AuthValidators.email,
                        ),
                        const SizedBox(height: AppTheme.spacing14),
                        AuthTextField(
                          label: 'Password',
                          controller: _passwordController,
                          obscureText: true,
                          autofillHints: const [AutofillHints.password],
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Enter your password';
                            }
                            return null;
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: AppTheme.spacing8),
                    Align(
                      alignment: Alignment.centerRight,
                      child: GestureDetector(
                        onTap: () => _notAvailableYet('Password reset'),
                        child: Text(
                          'Forgot password?',
                          style: AppTheme.linkAccentSmall,
                        ),
                      ),
                    ),
                    if (authProvider.errorMessage != null) ...[
                      const SizedBox(height: AppTheme.spacing12),
                      AuthErrorText(message: authProvider.errorMessage!),
                    ],
                    const SizedBox(height: AppTheme.spacing24),
                    AuthPrimaryButton(
                      label: 'Sign in',
                      isLoading: authProvider.isLoading,
                      onPressed: () => _submit(authProvider),
                    ),
                    const SizedBox(height: AppTheme.spacing22),
                    Row(
                      children: [
                        const Expanded(
                          child: Divider(color: AppTheme.divider, height: 1),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          child: Text('or', style: AppTheme.caption),
                        ),
                        const Expanded(
                          child: Divider(color: AppTheme.divider, height: 1),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppTheme.spacing22),
                    SizedBox(
                      width: double.infinity,
                      height: 46,
                      child: OutlinedButton.icon(
                        onPressed: () => _notAvailableYet('Phone sign-in'),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: AppTheme.border),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                              AppTheme.radiusSmall,
                            ),
                          ),
                        ),
                        icon: const Icon(
                          Icons.phone,
                          size: 15,
                          color: AppTheme.textSecondary,
                        ),
                        label: Text(
                          'Continue with phone number',
                          style: AppTheme.body,
                        ),
                      ),
                    ),
                    const SizedBox(height: AppTheme.spacing20),
                    Center(
                      child: Wrap(
                        alignment: WrapAlignment.center,
                        children: [
                          Text('New here? ', style: AppTheme.subtitle),
                          GestureDetector(
                            onTap: _openRegister,
                            child: Text(
                              'Create an account',
                              style: AppTheme.linkAccent,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
