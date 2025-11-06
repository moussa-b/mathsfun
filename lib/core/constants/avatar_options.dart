import 'package:flutter/material.dart';

import 'app_colors.dart';

class AvatarOption {
  const AvatarOption({
    required this.id,
    required this.icon,
    required this.backgroundColor,
    this.iconColor = Colors.white,
    required this.label,
  });

  final String id;
  final IconData icon;
  final Color backgroundColor;
  final Color iconColor;
  final String label;
}

const List<AvatarOption> kAvatarOptions = <AvatarOption>[
  AvatarOption(
    id: 'lion',
    icon: Icons.pets,
    backgroundColor: Color(0xFFF97316),
    label: 'Brave Lion',
  ),
  AvatarOption(
    id: 'dino',
    icon: Icons.auto_awesome,
    backgroundColor: Color(0xFF06B6D4),
    label: 'Sparkly Dino',
  ),
  AvatarOption(
    id: 'astronaut',
    icon: Icons.travel_explore,
    backgroundColor: Color(0xFF8B5CF6),
    label: 'Space Explorer',
  ),
  AvatarOption(
    id: 'robot',
    icon: Icons.smart_toy,
    backgroundColor: Color(0xFF22C55E),
    label: 'Happy Robot',
  ),
  AvatarOption(
    id: 'unicorn',
    icon: Icons.star,
    backgroundColor: AppColors.redPrimary,
    label: 'Magic Unicorn',
  ),
  AvatarOption(
    id: 'painter',
    icon: Icons.palette,
    backgroundColor: AppColors.bluePrimary,
    label: 'Creative Painter',
  ),
];

AvatarOption avatarOptionById(String id) {
  return kAvatarOptions.firstWhere(
    (AvatarOption option) => option.id == id,
    orElse: () => kAvatarOptions.first,
  );
}
