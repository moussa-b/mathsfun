import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/avatar_options.dart';
import '../../../core/extensions/context_localizations.dart';
import '../../../core/routes/app_router.dart';
import '../../../data/models/profile.dart';
import '../../../data/services/profile_service.dart';
import '../../../data/services/settings_service.dart';
import '../widgets/parent_settings_sheet.dart';
import '../widgets/parental_gate.dart';

/// Screen to select an existing learner profile.
class ProfileSelectorScreen extends StatelessWidget {
  const ProfileSelectorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(context.l10n.profileSelectorTitle),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.admin_panel_settings),
            tooltip: context.l10n.profileSelectorParentSettings,
            onPressed: () => _openParentSettings(context),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push(AppRoutePath.profileCreate),
        icon: const Icon(Icons.add),
        label: Text(context.l10n.profileSelectorNewProfile),
      ),
      body: SafeArea(
        child: Consumer<ProfileService>(
          builder:
              (BuildContext context, ProfileService profileService, Widget? _) {
                final List<Profile> profiles = profileService.profiles;
                if (profiles.isEmpty) {
                  return _EmptyProfilesState(
                    onCreate: () {
                      context.push(AppRoutePath.profileCreate);
                    },
                  );
                }
                return ListView.separated(
                  padding: const EdgeInsets.all(24),
                  itemBuilder: (BuildContext context, int index) {
                    final Profile profile = profiles[index];
                    final AvatarOption avatar = avatarOptionById(
                      profile.avatarId,
                    );
                    return Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 12,
                        ),
                        leading: CircleAvatar(
                          radius: 28,
                          backgroundColor: avatar.backgroundColor,
                          child: Icon(
                            avatar.icon,
                            color: avatar.iconColor,
                            size: 30,
                          ),
                        ),
                        title: Text(
                          profile.nickname,
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        subtitle: Text(
                          '${context.l10n.profileClassLabel} ${profile.schoolClass.label}',
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            IconButton(
                              tooltip: context.l10n.profileMenuEdit,
                              icon: const Icon(Icons.edit_outlined),
                              onPressed: () async {
                                final ProfileService profileService = context
                                    .read<ProfileService>();
                                await profileService.setActiveProfile(profile.id);
                                if (!context.mounted) {
                                  return;
                                }
                                context.push(AppRoutePath.profileEdit);
                              },
                            ),
                            IconButton(
                              tooltip: context.l10n.profileSelectorDeleteConfirm,
                              icon: const Icon(Icons.delete_outline),
                              onPressed: () => _confirmDelete(context, profile),
                            ),
                          ],
                        ),
                        onTap: () async {
                          final ProfileService profileService = context
                              .read<ProfileService>();
                          await profileService.setActiveProfile(profile.id);
                          if (!context.mounted) {
                            return;
                          }
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                context.l10n.profileSelectorGreeting(
                                  profile.nickname,
                                ),
                              ),
                            ),
                          );
                          context.push(AppRoutePath.exerciseType);
                        },
                      ),
                    );
                  },
                  separatorBuilder: (_, _) => const SizedBox(height: 16),
                  itemCount: profiles.length,
                );
              },
        ),
      ),
    );
  }

  Future<void> _confirmDelete(BuildContext context, Profile profile) async {
    final bool approved = await requestParentApproval(context);
    if (!context.mounted || !approved) {
      return;
    }

    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(context.l10n.profileSelectorDeleteTitle),
          content: Text(
            context.l10n.profileSelectorDeleteMessage(profile.nickname),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(context.l10n.profileSelectorDeleteCancel),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: FilledButton.styleFrom(backgroundColor: Colors.redAccent),
              child: Text(context.l10n.profileSelectorDeleteConfirm),
            ),
          ],
        );
      },
    );

    if (!context.mounted) {
      return;
    }

    if (confirmed == true) {
      final ProfileService profileService = context.read<ProfileService>();
      await profileService.deleteProfile(profile.id);
      if (!context.mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            context.l10n.profileSelectorDeleteSuccess(profile.nickname),
          ),
        ),
      );
    }
  }

  Future<void> _openParentSettings(BuildContext context) async {
    final SettingsService settingsService = context.read<SettingsService>();
    if (!settingsService.hasParentPin) {
      await showModalBottomSheet<void>(
        context: context,
        isScrollControlled: true,
        builder: (_) => const ParentSettingsSheet(),
      );
      return;
    }

    final bool approved = await requestParentApproval(context);
    if (!context.mounted || !approved) {
      return;
    }
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (_) => const ParentSettingsSheet(),
    );
  }
}

class _EmptyProfilesState extends StatelessWidget {
  const _EmptyProfilesState({required this.onCreate});

  final VoidCallback onCreate;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            const Icon(
              Icons.face_retouching_natural,
              size: 72,
              color: Colors.grey,
            ),
            const SizedBox(height: 16),
            Text(
              context.l10n.profileSelectorEmptyTitle,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              context.l10n.profileSelectorEmptySubtitle,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: onCreate,
              icon: const Icon(Icons.add),
              label: Text(context.l10n.profileSelectorEmptyButton),
            ),
          ],
        ),
      ),
    );
  }
}
