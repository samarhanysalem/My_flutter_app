import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../common/widgets/labeled_text_field.dart';
import '../../../common/widgets/primary_button.dart';
import '../../../l10n/app_localizations.dart';
import '../../../theme/app_theme.dart';
import '../../auth/auth_validators.dart';
import '../view/profile_provider.dart';

/// The editable name/phone fields plus a Save action, prefilled from the
/// already-loaded [initialFullName]/[initialPhone]. Owns its controllers as
/// local, ephemeral UI state (per CLAUDE.md) rather than in `ProfileProvider`
/// — that provider only needs the last *saved* values.
class ProfileEditForm extends StatefulWidget {
  const ProfileEditForm({
    super.key,
    required this.initialFullName,
    required this.initialPhone,
  });

  final String initialFullName;
  final String initialPhone;

  @override
  State<ProfileEditForm> createState() => _ProfileEditFormState();
}

class _ProfileEditFormState extends State<ProfileEditForm> {
  final _formKey = GlobalKey<FormState>();
  late final _fullNameController = TextEditingController(text: widget.initialFullName);
  late final _phoneController = TextEditingController(text: widget.initialPhone);

  @override
  void dispose() {
    _fullNameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    final loc = AppLocalizations.of(context)!;
    final provider = context.read<ProfileProvider>();
    final success = await provider.save(
      fullName: _fullNameController.text.trim(),
      phone: _phoneController.text.trim(),
    );
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(success ? loc.profileUpdated : loc.profileUpdateFailed)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final isSaving = context.watch<ProfileProvider>().isSaving;
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          LabeledTextField(
            fieldKey: 'profileFullName',
            label: loc.fullNameLabel,
            controller: _fullNameController,
            autofillHints: const [AutofillHints.name],
            validator: (value) => AuthValidators.fullName(value, loc),
          ),
          const SizedBox(height: AppTheme.spacing14),
          LabeledTextField(
            fieldKey: 'profilePhone',
            label: loc.phoneLabel,
            controller: _phoneController,
            keyboardType: TextInputType.phone,
            autofillHints: const [AutofillHints.telephoneNumber],
            validator: (value) => AuthValidators.phone(value, loc),
          ),
          const SizedBox(height: AppTheme.spacing18),
          PrimaryButton(
            label: loc.save,
            isLoading: isSaving,
            onPressed: _submit,
          ),
        ],
      ),
    );
  }
}
