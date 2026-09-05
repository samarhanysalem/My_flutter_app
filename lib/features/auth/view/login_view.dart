import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../widgets/auth_colors.dart';
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
    if (!_formKey.currentState!.validate()) return;
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
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$feature isn\'t available yet.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    return Scaffold(
      backgroundColor: AuthColors.screenGround,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 40, 24, 24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 400),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 46,
                    height: 46,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: AuthColors.accent,
                      borderRadius: BorderRadius.circular(13),
                    ),
                    child: const Icon(
                      Icons.favorite,
                      color: Colors.white,
                      size: 22,
                    ),
                  ),
                  const SizedBox(height: 28),
                  Text(
                    'Welcome back',
                    style: GoogleFonts.dmSans(
                      fontSize: 24,
                      fontWeight: FontWeight.w500,
                      letterSpacing: -0.02 * 24,
                      color: AuthColors.ink,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Sign in to book with the Lakeside clinic team.',
                    style: GoogleFonts.dmSans(
                      fontSize: 13,
                      color: AuthColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 28),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AuthTextField(
                        label: 'Email',
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        autofillHints: const [AutofillHints.email],
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Enter your email';
                          }
                          if (!value.contains('@')) {
                            return 'Enter a valid email';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 14),
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
                  const SizedBox(height: 8),
                  Align(
                    alignment: Alignment.centerRight,
                    child: GestureDetector(
                      onTap: () => _notAvailableYet('Password reset'),
                      child: Text(
                        'Forgot password?',
                        style: GoogleFonts.dmSans(
                          fontSize: 12,
                          color: AuthColors.accent,
                        ),
                      ),
                    ),
                  ),
                  if (authProvider.errorMessage != null) ...[
                    const SizedBox(height: 12),
                    AuthErrorText(message: authProvider.errorMessage!),
                  ],
                  const SizedBox(height: 24),
                  AuthPrimaryButton(
                    label: 'Sign in',
                    isLoading: authProvider.isLoading,
                    onPressed: () => _submit(authProvider),
                  ),
                  const SizedBox(height: 22),
                  Row(
                    children: [
                      const Expanded(
                        child: Divider(color: AuthColors.divider, height: 1),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: Text(
                          'or',
                          style: GoogleFonts.dmSans(
                            fontSize: 11,
                            color: AuthColors.textPlaceholder,
                          ),
                        ),
                      ),
                      const Expanded(
                        child: Divider(color: AuthColors.divider, height: 1),
                      ),
                    ],
                  ),
                  const SizedBox(height: 22),
                  SizedBox(
                    width: double.infinity,
                    height: 46,
                    child: OutlinedButton.icon(
                      onPressed: () => _notAvailableYet('Phone sign-in'),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: AuthColors.border),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      icon: const Icon(
                        Icons.phone,
                        size: 15,
                        color: AuthColors.textSecondary,
                      ),
                      label: Text(
                        'Continue with phone number',
                        style: GoogleFonts.dmSans(
                          fontSize: 14,
                          color: AuthColors.ink,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Center(
                    child: Wrap(
                      alignment: WrapAlignment.center,
                      children: [
                        Text(
                          'New here? ',
                          style: GoogleFonts.dmSans(
                            fontSize: 13,
                            color: AuthColors.textSecondary,
                          ),
                        ),
                        GestureDetector(
                          onTap: _openRegister,
                          child: Text(
                            'Create an account',
                            style: GoogleFonts.dmSans(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              color: AuthColors.accent,
                            ),
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
    );
  }
}
