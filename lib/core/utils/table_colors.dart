import 'package:flutter/material.dart';

/// Provides consistent pastel colour mappings for multiplication/addition tables.
class TableColors {
  const TableColors._();

  static const Map<int, Color> _backgroundMap = <int, Color>{
    1: Color(0xFFFFF4B8), // Pastel Sunshine Yellow
    2: Color(0xFFB3D9FF), // Pastel Blue
    3: Color(0xFFB8E6B8), // Pastel Green
    4: Color(0xFFFFD4B3), // Pastel Orange
    5: Color(0xFFE6B3FF), // Pastel Purple
    6: Color(0xFFFFB3B3), // Pastel Red
    7: Color(0xFFB3E6E6), // Pastel Teal
    8: Color(0xFFFFE6B3), // Pastel Amber
    9: Color(0xFFD4B3FF), // Pastel Indigo
    10: Color(0xFFFFB3E6), // Pastel Pink
    11: Color(0xFFE6FFB3), // Pastel Lime
    12: Color(0xFFCCF6E4), // Pastel Mint
  };

  /// Returns the background colour for the given [table].
  static Color getTableColor(int table) =>
      _backgroundMap[table] ?? const Color(0xFFE0E0E0);

  /// Returns a text colour that provides good contrast on the pastel background.
  static Color getTextColor(int table) => Colors.black87;

  /// Returns a slightly darker accent colour derived from the pastel background.
  static Color getAccentColor(int table) {
    final Color base = getTableColor(table);
    final HSLColor hsl = HSLColor.fromColor(base);
    final double newLightness = (hsl.lightness - 0.12).clamp(0.0, 1.0);
    return hsl.withLightness(newLightness).toColor();
  }
}
