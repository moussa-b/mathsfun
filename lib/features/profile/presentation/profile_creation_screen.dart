import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/avatar_options.dart';
import '../../../core/extensions/context_localizations.dart';
import '../../../core/routes/app_router.dart';
import '../../../data/models/profile.dart';
import '../../../data/services/profile_service.dart';

/// Screen allowing a parent to create a new learner profile.
class ProfileCreationScreen extends StatefulWidget {
  const ProfileCreationScreen({super.key});

  @override
  State<ProfileCreationScreen> createState() => _ProfileCreationScreenState();
}

class _ProfileCreationScreenState extends State<ProfileCreationScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _nicknameController = TextEditingController();
  SchoolClass _selectedClass = SchoolClass.cp;
  String _selectedAvatarId = kAvatarOptions.first.id;
  bool _isSaving = false;

  @override
  void dispose() {
    _nicknameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(context.l10n.profileCreationTitle)),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  context.l10n.profileCreationHeading,
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 12),
                Text(
                  context.l10n.profileCreationSubtitle,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 24),
                TextFormField(
                  controller: _nicknameController,
                  textCapitalization: TextCapitalization.words,
                  decoration: InputDecoration(
                    labelText: context.l10n.profileNicknameLabel,
                    hintText: context.l10n.profileNicknameHint,
                  ),
                  validator: (String? value) {
                    if (value == null || value.trim().isEmpty) {
                      return context.l10n.profileNicknameErrorEmpty;
                    }
                    if (value.trim().length < 3) {
                      return context.l10n.profileNicknameErrorShort;
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),
                DropdownButtonFormField<SchoolClass>(
                  decoration: InputDecoration(
                    labelText: context.l10n.profileClassLabel,
                  ),
                  value: _selectedClass,
                  items: SchoolClass.values
                      .map(
                        (SchoolClass schoolClass) =>
                            DropdownMenuItem<SchoolClass>(
                              value: schoolClass,
                              child: Text(schoolClass.label),
                            ),
                      )
                      .toList(),
                  onChanged: (SchoolClass? value) {
                    if (value != null) {
                      setState(() => _selectedClass = value);
                    }
                  },
                ),
                const SizedBox(height: 32),
                Text(
                  context.l10n.profileAvatarLabel,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 16,
                  runSpacing: 16,
                  children: kAvatarOptions
                      .map(
                        (AvatarOption option) => _AvatarChoiceChip(
                          option: option,
                          selected: option.id == _selectedAvatarId,
                          onTap: () =>
                              setState(() => _selectedAvatarId = option.id),
                        ),
                      )
                      .toList(),
                ),
                const SizedBox(height: 40),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: _isSaving ? null : _handleSubmit,
                    child: _isSaving
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : Text(context.l10n.profileSaveButton),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _handleSubmit() async {
    final bool isValid = _formKey.currentState?.validate() ?? false;
    if (!isValid) {
      return;
    }

    FocusScope.of(context).unfocus();
    setState(() => _isSaving = true);

    final ProfileService profileService = context.read<ProfileService>();

    try {
      await profileService.createProfile(
        nickname: _nicknameController.text.trim(),
        schoolClass: _selectedClass,
        avatarId: _selectedAvatarId,
      );
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.l10n.profileCreateSuccess)),
      );
      context.go(AppRoutePath.exerciseType);
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(context.l10n.profileCreateError(error.toString())),
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }
}

class _AvatarChoiceChip extends StatelessWidget {
  const _AvatarChoiceChip({
    required this.option,
    required this.selected,
    required this.onTap,
  });

  final AvatarOption option;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          color: selected
              ? option.backgroundColor.withValues(alpha: 0.15)
              : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected ? option.backgroundColor : Colors.grey.shade300,
            width: selected ? 2.5 : 1.5,
          ),
          boxShadow: selected
              ? <BoxShadow>[
                  BoxShadow(
                    color: option.backgroundColor.withValues(alpha: 0.25),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ]
              : const <BoxShadow>[],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            CircleAvatar(
              radius: 30,
              backgroundColor: option.backgroundColor,
              child: Icon(option.icon, size: 32, color: option.iconColor),
            ),
            const SizedBox(height: 8),
            Text(
              option.getLabel(context),
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
