import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../core/extensions/context_localizations.dart';
import '../../../core/routes/app_router.dart';
import '../../../core/utils/pin_utils.dart';
import '../../../core/utils/formatters.dart';
import '../../../data/services/settings_service.dart';
import '../../../data/services/speech_model_service.dart';

class ParentSettingsSheet extends StatefulWidget {
  const ParentSettingsSheet({super.key});

  @override
  State<ParentSettingsSheet> createState() => _ParentSettingsSheetState();
}

class _ParentSettingsSheetState extends State<ParentSettingsSheet> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _pinController = TextEditingController();
  final TextEditingController _confirmController = TextEditingController();
  bool _showPin = false;
  bool _isSaving = false;

  @override
  void dispose() {
    _pinController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final SettingsService settingsService = context.watch<SettingsService>();
    final bool hasPin = settingsService.hasParentPin;
    final Locale currentLocale = settingsService.locale;

    return Padding(
      padding: MediaQuery.of(context).viewInsets,
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Row(
                children: <Widget>[
                  const Icon(Icons.lock),
                  const SizedBox(width: 12),
                  Text(
                    context.l10n.parentSettingsTitle,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                hasPin
                    ? context.l10n.parentSettingsDescriptionWithPin
                    : context.l10n.parentSettingsDescriptionNoPin,
              ),
              const SizedBox(height: 16),
              Text(
                context.l10n.parentSettingsLanguageLabel,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                initialValue: currentLocale.languageCode,
                decoration: const InputDecoration(border: OutlineInputBorder()),
                items: <DropdownMenuItem<String>>[
                  DropdownMenuItem<String>(
                    value: 'en',
                    child: Text(context.l10n.languageEnglish),
                  ),
                  DropdownMenuItem<String>(
                    value: 'fr',
                    child: Text(context.l10n.languageFrench),
                  ),
                ],
                onChanged: (String? value) async {
                  if (value == null || value == currentLocale.languageCode) {
                    return;
                  }
                  await settingsService.setLocale(Locale(value));
                },
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.of(context).pop();
                    context.push(AppRoutePath.parentDashboard);
                  },
                  icon: const Icon(Icons.analytics),
                  label: Text(context.l10n.parentDashboardAdvancedAnalytics),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              const _VoiceModelsSection(),
              const SizedBox(height: 24),
              const Divider(),
              const SizedBox(height: 16),
              Text(
                'PIN Security',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _pinController,
                keyboardType: TextInputType.number,
                obscureText: !_showPin,
                maxLength: 4,
                decoration: InputDecoration(
                  labelText: hasPin
                      ? context.l10n.parentSettingsPinLabelNew
                      : context.l10n.parentSettingsPinLabelCreate,
                  counterText: '',
                  suffixIcon: IconButton(
                    icon: Icon(
                      _showPin ? Icons.visibility_off : Icons.visibility,
                    ),
                    onPressed: () => setState(() => _showPin = !_showPin),
                  ),
                ),
                validator: (String? value) {
                  if (value == null || value.isEmpty) {
                    return context.l10n.parentSettingsPinValidationEmpty;
                  }
                  if (!isValidPin(value)) {
                    return context.l10n.parentSettingsPinValidationDigits;
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _confirmController,
                keyboardType: TextInputType.number,
                obscureText: !_showPin,
                maxLength: 4,
                decoration: InputDecoration(
                  labelText: context.l10n.parentSettingsPinConfirmLabel,
                  counterText: '',
                ),
                validator: (String? value) {
                  if (value == null || value.isEmpty) {
                    return context.l10n.parentSettingsPinConfirmValidationEmpty;
                  }
                  if (value != _pinController.text) {
                    return context
                        .l10n
                        .parentSettingsPinConfirmValidationMismatch;
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              Row(
                children: <Widget>[
                  Expanded(
                    child: ElevatedButton.icon(
                      icon: _isSaving
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.save),
                      label: Text(
                        _isSaving
                            ? context.l10n.parentSettingsSaving
                            : context.l10n.parentSettingsSaveButton,
                      ),
                      onPressed: _isSaving
                          ? null
                          : () async {
                              final bool isValid =
                                  _formKey.currentState?.validate() ?? false;
                              if (!isValid) {
                                return;
                              }
                              final NavigatorState navigator = Navigator.of(
                                context,
                              );
                              final ScaffoldMessengerState messenger =
                                  ScaffoldMessenger.of(context);
                              final l10n = context.l10n;
                              setState(() => _isSaving = true);
                              await settingsService.setParentPin(
                                _pinController.text,
                              );
                              if (!mounted) {
                                return;
                              }
                              setState(() => _isSaving = false);
                              navigator.pop();
                              messenger.showSnackBar(
                                SnackBar(
                                  content: Text(l10n.parentSettingsSaved),
                                ),
                              );
                            },
                    ),
                  ),
                ],
              ),
              if (hasPin) ...<Widget>[
                const SizedBox(height: 16),
                TextButton.icon(
                  onPressed: () async {
                    final NavigatorState navigator = Navigator.of(context);
                    final ScaffoldMessengerState messenger =
                        ScaffoldMessenger.of(context);
                    final l10n = context.l10n;
                    await settingsService.clearParentPin();
                    if (!mounted) {
                      return;
                    }
                    navigator.pop();
                    messenger.showSnackBar(
                      SnackBar(
                        content: Text(l10n.parentSettingsRemoved),
                      ),
                    );
                  },
                  icon: const Icon(Icons.lock_open),
                  label: Text(context.l10n.parentSettingsRemovePin),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// Installed voice models (size + delete) and the credits the CC-BY-SA
/// license of the French model requires.
class _VoiceModelsSection extends StatefulWidget {
  const _VoiceModelsSection();

  @override
  State<_VoiceModelsSection> createState() => _VoiceModelsSectionState();
}

class _VoiceModelsSectionState extends State<_VoiceModelsSection> {
  int? _installedBytes;
  SpeechModelService? _service;

  @override
  void initState() {
    super.initState();
    // Follow downloads and deletions made while the sheet is open.
    _service = context.read<SpeechModelService>()..addListener(_loadSize);
    _loadSize();
  }

  @override
  void dispose() {
    _service?.removeListener(_loadSize);
    super.dispose();
  }

  Future<void> _loadSize() async {
    final SpeechModelService? service = _service;
    if (service == null) {
      return;
    }
    final int bytes = await service.installedBytes();
    if (mounted) {
      setState(() => _installedBytes = bytes);
    }
  }

  Future<void> _confirmDelete() async {
    final SpeechModelService service = context.read<SpeechModelService>();
    final ScaffoldMessengerState messenger = ScaffoldMessenger.of(context);
    final String deleted = context.l10n.parentSettingsVoiceModelsDeleted;
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext dialogContext) => AlertDialog(
        content: Text(dialogContext.l10n.parentSettingsVoiceModelsDeleteConfirm),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text(dialogContext.l10n.parentGateCancel),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(dialogContext).colorScheme.error,
              foregroundColor: Theme.of(dialogContext).colorScheme.onError,
            ),
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: Text(dialogContext.l10n.parentSettingsVoiceModelsDelete),
          ),
        ],
      ),
    );
    if (confirmed != true) {
      return;
    }
    await service.deleteAll();
    messenger.showSnackBar(SnackBar(content: Text(deleted)));
    await _loadSize();
  }

  @override
  Widget build(BuildContext context) {
    final int bytes = _installedBytes ?? 0;
    final String languageCode = Localizations.localeOf(context).languageCode;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        if (bytes > 0)
          Row(
            children: <Widget>[
              const Icon(Icons.record_voice_over),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  context.l10n.parentSettingsVoiceModels(
                    formatMegabytes(bytes, languageCode),
                  ),
                ),
              ),
              TextButton(
                key: const ValueKey<String>('voice-models-delete'),
                onPressed: _confirmDelete,
                child: Text(context.l10n.parentSettingsVoiceModelsDelete),
              ),
            ],
          ),
        const SizedBox(height: 4),
        Text(
          '${context.l10n.parentSettingsVoiceCredits}\n'
          'huggingface.co/Banafo/Kroko-ASR',
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }
}
