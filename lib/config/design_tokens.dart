import 'package:flutter/material.dart';

/// Design tokens UI inspirés d’un style “emerald + bento/soft shadows”.
/// Note: Flutter ne supporte pas nativement `oklch`; on approxime via hex/opacity.
class DesignTokens {
  DesignTokens._();

  // Rounded: Tailwind `rounded-3xl` ~ 24px
  static const double rounded3xl = 24;
  static const double rounded2xl = 18;
  static const double roundedXl = 14;

  // Emerald palette (approx)
  static const Color emerald = Color(0xFF34D399); // #34D399
  static const Color emeraldDeep = Color(0xFF10B981);
  static const Color emeraldDark = Color(0xFF059669);

  // Surfaces
  static const Color glassSurface = Color(0x8012122D);
  static const Color border = Color(0xFF27324D);

  static LinearGradient emeraldGradient() {
    return const LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [Color(0xFF34D399), Color(0xFF10B981)],
    );
  }

  /// “shadow-soft” : légère profondeur.
  static List<BoxShadow> shadowSoft({double opacity = 0.28}) {
    return [
      BoxShadow(
        color: Colors.black.withOpacity(opacity),
        blurRadius: 14,
        offset: const Offset(0, 10),
      ),
    ];
  }

  /// “shadow-bento” : bords + glow subtils (approx Tailwind bento).
  static List<BoxShadow> shadowBento({double intensity = 0.55}) {
    return [
      // Outer
      BoxShadow(
        color: Colors.black.withOpacity(0.35),
        blurRadius: 18,
        offset: const Offset(0, 14),
      ),
      // Inner/glow-ish
      BoxShadow(
        color: emerald.withOpacity(0.18 * intensity),
        blurRadius: 26,
        offset: const Offset(0, 0),
      ),
      // Accent edge
      BoxShadow(
        color: emeraldDeep.withOpacity(0.12 * intensity),
        blurRadius: 10,
        offset: const Offset(0, 6),
      ),
    ];
  }
}

