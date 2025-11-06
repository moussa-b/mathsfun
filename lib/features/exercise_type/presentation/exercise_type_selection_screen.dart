import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/avatar_options.dart';
import '../../../core/extensions/context_localizations.dart';
import '../../../core/routes/app_router.dart';
import '../../../data/models/exercise_metadata.dart';
import '../../../data/services/profile_service.dart';
import '../../exercise/models/exercise_config.dart';

/// Screen allowing learners to choose between addition and multiplication activities.
class ExerciseTypeSelectionScreen extends StatelessWidget {
  const ExerciseTypeSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(context.l10n.exerciseTypeTitle),
        actions: <Widget>[
          Consumer<ProfileService>(
            builder: (BuildContext context, ProfileService profileService, _) {
              final avatar = profileService.activeProfile != null
                  ? avatarOptionById(profileService.activeProfile!.avatarId)
                  : kAvatarOptions.first;
              
              return PopupMenuButton<String>(
                icon: CircleAvatar(
                  radius: 18,
                  backgroundColor: avatar.backgroundColor,
                  child: Icon(
                    avatar.icon,
                    color: avatar.iconColor,
                    size: 20,
                  ),
                ),
                onSelected: (String value) {
                  if (value == 'edit') {
                    context.push(AppRoutePath.profileEdit);
                  } else if (value == 'switch') {
                    context.push(AppRoutePath.profileSelector);
                  } else if (value == 'statistics') {
                    context.push(AppRoutePath.statistics);
                  }
                },
                itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                  PopupMenuItem<String>(
                    value: 'edit',
                    child: Row(
                      children: <Widget>[
                        const Icon(Icons.edit),
                        const SizedBox(width: 12),
                        Text(context.l10n.profileMenuEdit),
                      ],
                    ),
                  ),
                  PopupMenuItem<String>(
                    value: 'statistics',
                    child: Row(
                      children: <Widget>[
                        const Icon(Icons.bar_chart),
                        const SizedBox(width: 12),
                        Text(context.l10n.profileMenuStatistics),
                      ],
                    ),
                  ),
                  PopupMenuItem<String>(
                    value: 'switch',
                    child: Row(
                      children: <Widget>[
                        const Icon(Icons.swap_horiz),
                        const SizedBox(width: 12),
                        Text(context.l10n.profileMenuSwitch),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Consumer<ProfileService>(
            builder: (BuildContext context, ProfileService profileService, _) {
              final avatar = profileService.activeProfile != null
                  ? avatarOptionById(profileService.activeProfile!.avatarId)
                  : kAvatarOptions.first;
              final nickname =
                  profileService.activeProfile?.nickname ??
                  context.l10n.exerciseDefaultNickname;

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      CircleAvatar(
                        radius: 32,
                        backgroundColor: avatar.backgroundColor,
                        child: Icon(
                          avatar.icon,
                          color: avatar.iconColor,
                          size: 36,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              context.l10n.exerciseTypeWelcomeBack,
                              style: theme.textTheme.labelLarge,
                            ),
                            Text(
                              nickname,
                              style: theme.textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),
                  Text(
                    context.l10n.exerciseTypeSubtitle,
                    style: theme.textTheme.titleMedium,
                  ),
                  const SizedBox(height: 24),
                  Expanded(
                    child: Column(
                      children: <Widget>[
                        _ExerciseCard(
                          title: context.l10n.exerciseMultiplication,
                          description:
                              context.l10n.exerciseMultiplicationDescription,
                          color: Colors.blueAccent,
                          onTap: () {
                            final ExerciseConfig config = ExerciseConfig(
                              operation: OperationKind.multiplication,
                              mode: StudyMode.exercise,
                              format: ExerciseFormat.multipleChoice,
                              baseNumber: 2,
                              questionCount: 10,
                            );
                            context.push(
                              AppRoutePath.modeSelection,
                              extra: config,
                            );
                          },
                        ),
                        const SizedBox(height: 20),
                        _ExerciseCard(
                          title: context.l10n.exerciseAddition,
                          description: context.l10n.exerciseAdditionDescription,
                          color: Colors.redAccent,
                          onTap: () {
                            final ExerciseConfig config = ExerciseConfig(
                              operation: OperationKind.addition,
                              mode: StudyMode.exercise,
                              format: ExerciseFormat.multipleChoice,
                              baseNumber: 2,
                              questionCount: 10,
                            );
                            context.push(
                              AppRoutePath.modeSelection,
                              extra: config,
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

class _ExerciseCard extends StatelessWidget {
  const _ExerciseCard({
    required this.title,
    required this.description,
    required this.color,
    required this.onTap,
  });

  final String title;
  final String description;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(24),
      onTap: onTap,
      child: Ink(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: <Color>[color.withValues(alpha: 0.85), color],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(24),
          boxShadow: <BoxShadow>[
            BoxShadow(
              color: color.withValues(alpha: 0.3),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Row(
            children: <Widget>[
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      title,
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      description,
                      style: const TextStyle(color: Colors.white70),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios, color: Colors.white),
            ],
          ),
        ),
      ),
    );
  }
}
