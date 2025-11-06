import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/extensions/context_localizations.dart';
import '../../../core/utils/pin_utils.dart';
import '../../../data/services/settings_service.dart';

Future<bool> requestParentApproval(BuildContext context) async {
  final SettingsService settingsService = context.read<SettingsService>();
  if (!settingsService.hasParentPin) {
    return true;
  }

  final TextEditingController pinController = TextEditingController();
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  String? errorMessage;

  final bool? approved = await showDialog<bool>(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) {
      return StatefulBuilder(
        builder:
            (BuildContext context, void Function(void Function()) setState) {
              return AlertDialog(
                title: Text(context.l10n.parentGateTitle),
                content: Form(
                  key: formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Text(context.l10n.parentGateMessage),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: pinController,
                        keyboardType: TextInputType.number,
                        obscureText: true,
                        maxLength: 4,
                        decoration: InputDecoration(
                          labelText: context.l10n.parentGatePinLabel,
                          counterText: '',
                        ),
                        validator: (String? value) {
                          if (value == null || value.isEmpty) {
                            return context.l10n.parentGatePinEmpty;
                          }
                          if (!isValidPin(value)) {
                            return context.l10n.parentGatePinInvalid;
                          }
                          if (!settingsService.validatePin(value)) {
                            return context.l10n.parentGatePinIncorrect;
                          }
                          return null;
                        },
                      ),
                      if (errorMessage != null) ...<Widget>[
                        const SizedBox(height: 8),
                        Text(
                          errorMessage!,
                          style: const TextStyle(color: Colors.red),
                        ),
                      ],
                    ],
                  ),
                ),
                actions: <Widget>[
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(false),
                    child: Text(context.l10n.parentGateCancel),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      final bool isValid =
                          formKey.currentState?.validate() ?? false;
                      if (isValid) {
                        Navigator.of(context).pop(true);
                      } else {
                        setState(() {
                          errorMessage = context.l10n.parentGateErrorFix;
                        });
                      }
                    },
                    child: Text(context.l10n.parentGateUnlock),
                  ),
                ],
              );
            },
      );
    },
  );

  pinController.dispose();
  return approved ?? false;
}
