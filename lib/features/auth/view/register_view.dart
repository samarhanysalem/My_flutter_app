import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../theme/app_theme.dart';
import '../auth_validators.dart';
import '../widgets/auth_error_text.dart';
import '../widgets/auth_primary_button.dart';
import '../widgets/auth_text_field.dart';
import '../widgets/terms_checkbox.dart';
import 'auth_provider.dart';

class RegisterView extends StatefulWidget {
  const RegisterView({super.key});

  @override
  State<RegisterView> createState() => _RegisterViewState();
}

class _RegisterViewState extends State<RegisterView> {
  final _formKey = GlobalKey<FormState>();
  final _fullNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _termsAccepted = false;

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit(AuthProvider authProvider) async {
    if (!_termsAccepted) return;
    if (!(_formKey.currentState?.validate() ?? false)) return;
    await authProvider.signUp(
      email: _emailController.text.trim(),
      password: _passwordController.text,
      fullName: _fullNameController.text.trim(),
      phone: _phoneController.text.trim(),
    );
    // A successful sign-up also signs the user in, which flips AuthGate
    // (sitting on the route below this one) over to the home screen. Pop
    // back to it so that screen becomes visible instead of staying hidden
    // behind this pushed route.
    if (authProvider.errorMessage == null && mounted) {
      Navigator.of(context).popUntil((route) => route.isFirst);
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    return Scaffold(
      backgroundColor: AppTheme.screenGround,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 400),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    height: 44,
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: IconButton(
                        onPressed: () => Navigator.of(context).pop(),
                        icon: const Icon(
                          Icons.chevron_left,
                          color: AppTheme.ink,
                          size: 28,
                        ),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(
                          minWidth: 28,
                          minHeight: 28,
                        ),
                      ),
                    ),
                  ),
                  Text('Create your account', style: AppTheme.heading),
                  const SizedBox(height: AppTheme.spacing6),
                  Text(
                    'Takes a minute. You will pay at the clinic, so no card needed.',
                    style: AppTheme.subtitle,
                  ),
                  const SizedBox(height: AppTheme.spacing24),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AuthTextField(
                        label: 'Full name',
                        controller: _fullNameController,
                        autofillHints: const [AutofillHints.name],
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Enter your full name';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: AppTheme.spacing14),
                      AuthTextField(
                        label: 'Email',
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        autofillHints: const [AutofillHints.email],
                        validator: AuthValidators.email,
                      ),
                      const SizedBox(height: AppTheme.spacing14),
                      AuthTextField(
                        label: 'Phone',
                        controller: _phoneController,
                        keyboardType: TextInputType.phone,
                        autofillHints: const [AutofillHints.telephoneNumber],
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Enter your phone number';
                          }
                          final digits = value.replaceAll(
                            RegExp(r'[^0-9]'),
                            '',
                          );
                          if (digits.length < 7) {
                            return 'Enter a valid phone number';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: AppTheme.spacing14),
                      AuthTextField(
                        label: 'Password',
                        controller: _passwordController,
                        obscureText: true,
                        autofillHints: const [AutofillHints.newPassword],
                        validator: (value) {
                          if (value == null || value.length < 8) {
                            return 'Password must be at least 8 characters';
                          }
                          if (!RegExp(r'[A-Za-z]').hasMatch(value) ||
                              !RegExp(r'[0-9]').hasMatch(value)) {
                            return 'Include at least one letter and one number';
                          }
                          return null;
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: AppTheme.spacing18),
                  TermsCheckbox(
                    value: _termsAccepted,
                    onChanged: (value) =>
                        setState(() => _termsAccepted = value),
                  ),
                  if (authProvider.errorMessage != null) ...[
                    const SizedBox(height: AppTheme.spacing12),
                    AuthErrorText(message: authProvider.errorMessage!),
                  ],
                  const SizedBox(height: AppTheme.spacing22),
                  AuthPrimaryButton(
                    label: 'Create account',
                    isLoading: authProvider.isLoading,
                    onPressed: _termsAccepted
                        ? () => _submit(authProvider)
                        : null,
                  ),
                  const SizedBox(height: AppTheme.spacing20),
                  Center(
                    child: Wrap(
                      alignment: WrapAlignment.center,
                      children: [
                        Text('Already registered? ', style: AppTheme.subtitle),
                        GestureDetector(
                          onTap: () => Navigator.of(context).pop(),
                          child: Text('Sign in', style: AppTheme.linkAccent),
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
    );
  }
}
