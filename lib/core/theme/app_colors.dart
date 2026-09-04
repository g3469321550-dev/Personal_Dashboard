import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  static const Color warmWhite = Color(0xFFFAF9F6);
  static const Color warmGray = Color(0xFFE8E6E3);
  static const Color warmDark = Color(0xFF1A1A1A);

  static const Color primary = Color(0xFF8B7E74);
  static const Color primaryLight = Color(0xFFB5A99A);
  static const Color primaryDark = Color(0xFF6B5E54);

  static const Color accent = Color(0xFFC4A882);
  static const Color accentLight = Color(0xFFE8D5B7);

  static const Color textLight = Color(0xFF2D2D2D);
  static const Color textLightSecondary = Color(0xFF6B6B6B);
  static const Color textDark = Color(0xFFE0E0E0);
  static const Color textDarkSecondary = Color(0xFF9E9E9E);

  static const Color success = Color(0xFF7BAE7F);
  static const Color warning = Color(0xFFE8B86D);
  static const Color error = Color(0xFFD4837A);

  static const Color priorityHigh = Color(0xFFC62828);
  static const Color priorityMedium = Color(0xFFF9A825);
  static const Color priorityLow = Color(0xFF1565C0);

  static const List<Color> colorTags = [
    Color(0xFF8B7E74),
    Color(0xFF7BAE7F),
    Color(0xFF6B9EC4),
    Color(0xFFD4837A),
    Color(0xFFE8B86D),
    Color(0xFFB394C4),
    Color(0xFF6BBFB5),
    Color(0xFFC4887A),
  ];

  static Color parseColorTag(String? colorTag) {
    if (colorTag == null || colorTag.isEmpty) return primary;
    try {
      return Color(int.parse(colorTag));
    } catch (_) {
      return primary;
    }
  }
}
