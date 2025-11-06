import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';
import 'app_colors.dart';

class AvatarOption {
  const AvatarOption({
    required this.id,
    required this.icon,
    required this.backgroundColor,
    this.iconColor = Colors.white,
  });

  final String id;
  final IconData icon;
  final Color backgroundColor;
  final Color iconColor;

  /// Returns the localized label for this avatar option
  String getLabel(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    switch (id) {
      case 'lion':
        return l10n.avatarBraveLion;
      case 'dino':
        return l10n.avatarSparklyDino;
      case 'astronaut':
        return l10n.avatarSpaceExplorer;
      case 'robot':
        return l10n.avatarHappyRobot;
      case 'unicorn':
        return l10n.avatarMagicUnicorn;
      case 'painter':
        return l10n.avatarCreativePainter;
      default:
        return id;
    }
  }
}

const List<AvatarOption> kAvatarOptions = <AvatarOption>[
  AvatarOption(
    id: 'lion',
    icon: Icons.pets,
    backgroundColor: Color(0xFFF97316),
  ),
  AvatarOption(
    id: 'dino',
    icon: Icons.auto_awesome,
    backgroundColor: Color(0xFF06B6D4),
  ),
  AvatarOption(
    id: 'astronaut',
    icon: Icons.travel_explore,
    backgroundColor: Color(0xFF8B5CF6),
  ),
  AvatarOption(
    id: 'robot',
    icon: Icons.smart_toy,
    backgroundColor: Color(0xFF22C55E),
  ),
  AvatarOption(
    id: 'unicorn',
    icon: Icons.star,
    backgroundColor: AppColors.redPrimary,
  ),
  AvatarOption(
    id: 'painter',
    icon: Icons.palette,
    backgroundColor: AppColors.bluePrimary,
  ),
];

AvatarOption avatarOptionById(String id) {
  return kAvatarOptions.firstWhere(
    (AvatarOption option) => option.id == id,
    orElse: () => kAvatarOptions.first,
  );
}
