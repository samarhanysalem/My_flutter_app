import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../l10n/app_localizations.dart';
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
    final loc = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: AppTheme.screenGround,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
          child: Center(
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
                        alignment: AlignmentDirectional.centerStart,
                        child: IconButton(
                          onPressed: () => Navigator.of(context).pop(),
                          icon: Icon(
                            Directionality.of(context) == TextDirection.rtl
                                ? Icons.chevron_right
                                : Icons.chevron_left,
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
                    Text(loc.createYourAccount, style: AppTheme.heading),
                    const SizedBox(height: AppTheme.spacing6),
                    Text(
                      loc.registerSubtitle,
                      style: AppTheme.subtitle,
                    ),
                    const SizedBox(height: AppTheme.spacing24),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        AuthTextField(
                          fieldKey: 'fullName',
                          label: loc.fullNameLabel,
                          controller: _fullNameController,
                          autofillHints: const [AutofillHints.name],
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return loc.enterYourFullName;
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: AppTheme.spacing14),
                        AuthTextField(
                          fieldKey: 'email',
                          label: loc.emailLabel,
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          autofillHints: const [AutofillHints.email],
                          validator: (value) =>
                              AuthValidators.email(value, loc),
                        ),
                        const SizedBox(height: AppTheme.spacing14),
                        AuthTextField(
                          fieldKey: 'phone',
                          label: loc.phoneLabel,
                          controller: _phoneController,
                          keyboardType: TextInputType.phone,
                          autofillHints: const [AutofillHints.telephoneNumber],
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return loc.enterYourPhoneNumber;
                            }
                            final digits = value.replaceAll(
                              RegExp(r'[^0-9]'),
                              '',
                            );
                            if (digits.length < 7) {
                              return loc.enterAValidPhoneNumber;
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: AppTheme.spacing14),
                        AuthTextField(
                          fieldKey: 'password',
                          label: loc.passwordLabel,
                          controller: _passwordController,
                          obscureText: true,
                          autofillHints: const [AutofillHints.newPassword],
                          validator: (value) {
                            if (value == null || value.length < 8) {
                              return loc.passwordTooShort;
                            }
                            if (!RegExp(r'[A-Za-z]').hasMatch(value) ||
                                !RegExp(r'[0-9]').hasMatch(value)) {
                              return loc.passwordNeedsLetterAndNumber;
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
                      label: loc.createAccount,
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
                          Text(
                            loc.alreadyRegisteredQuestion,
                            style: AppTheme.subtitle,
                          ),
                          GestureDetector(
                            onTap: () => Navigator.of(context).pop(),
                            child: Text(loc.signIn, style: AppTheme.linkAccent),
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
