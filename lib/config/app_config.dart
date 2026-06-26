import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Central configuration for the Objets Perdus du Campus app.
/// Set [useMockData] to false and configure Firebase to use real backend.
class AppConfig {
  AppConfig._();

  // ─── Mock Mode ───────────────────────────────────────────────────────────
  /// Set to false once Firebase is configured (add google-services.json).
  static bool useMockData = false;

  // ─── Campus Map Defaults ─────────────────────────────────────────────────
  static const double defaultLatitude = 36.7372; // Adjust to your campus
  static const double defaultLongitude = 3.0867;  // Algiers example
  static const String campusName = 'Campus Universitaire';

  // ─── Colors ──────────────────────────────────────────────────────────────
  static const Color primaryColor    = Color(0xFF6C3EF5);
  static const Color primaryDark     = Color(0xFF4527A0);
  static const Color primaryLight    = Color(0xFF9B72FF);
  static const Color accentLost      = Color(0xFFFF6B35); // orange – perdu
  static const Color accentFound     = Color(0xFF2ECC71); // green  – trouvé
  static const Color accentFoundDark = Color(0xFF27AE60);
  static const Color surfaceColor    = Color(0xFF0D0D1A);
  static const Color surfaceVariant  = Color(0xFF16163A);
  static const Color cardColor       = Color(0xFF1E1E4A);
  static const Color cardColorLight  = Color(0xFF252560);
  static const Color dividerColor    = Color(0xFF2A2A5A);

  // ─── Categories ──────────────────────────────────────────────────────────
  static const List<Map<String, dynamic>> categories = [
    {'id': 'phone',       'name': 'Téléphone',      'icon': Icons.phone_android},
    {'id': 'keys',        'name': 'Clés',            'icon': Icons.key},
    {'id': 'card',        'name': 'Carte / Badge',   'icon': Icons.credit_card},
    {'id': 'bag',         'name': 'Sac / Cartable',  'icon': Icons.backpack},
    {'id': 'computer',    'name': 'Ordinateur',      'icon': Icons.laptop_mac},
    {'id': 'clothing',    'name': 'Vêtements',       'icon': Icons.checkroom},
    {'id': 'glasses',     'name': 'Lunettes',        'icon': Icons.visibility},
    {'id': 'books',       'name': 'Livres / Docs',   'icon': Icons.menu_book},
    {'id': 'accessories', 'name': 'Accessoires',     'icon': Icons.watch},
    {'id': 'other',       'name': 'Autre',           'icon': Icons.category},
  ];

  static Map<String, dynamic>? getCategoryById(String id) {
    try {
      return categories.firstWhere((c) => c['id'] == id);
    } catch (_) {
      return categories.last;
    }
  }

  // ─── Theme ───────────────────────────────────────────────────────────────
  static ThemeData get theme {
    final base = ThemeData.dark();
    return base.copyWith(
      useMaterial3: true,
      colorScheme: const ColorScheme.dark(
        primary:         primaryColor,
        primaryContainer: primaryDark,
        secondary:       accentFound,
        secondaryContainer: accentFoundDark,
        surface:         surfaceColor,
        surfaceContainerHighest: surfaceVariant,
        error:           Color(0xFFCF6679),
        onPrimary:       Colors.white,
        onSecondary:     Colors.white,
        onSurface:       Colors.white,
      ),
      scaffoldBackgroundColor: surfaceColor,
      textTheme: GoogleFonts.poppinsTextTheme(base.textTheme).copyWith(
        displayLarge:  GoogleFonts.poppins(fontSize: 32, fontWeight: FontWeight.w700, color: Colors.white),
        displayMedium: GoogleFonts.poppins(fontSize: 28, fontWeight: FontWeight.w700, color: Colors.white),
        headlineLarge: GoogleFonts.poppins(fontSize: 24, fontWeight: FontWeight.w700, color: Colors.white),
        headlineMedium: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.w600, color: Colors.white),
        titleLarge:    GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.white),
        titleMedium:   GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.white),
        bodyLarge:     GoogleFonts.inter(fontSize: 16, color: Colors.white),
        bodyMedium:    GoogleFonts.inter(fontSize: 14, color: Colors.white70),
        bodySmall:     GoogleFonts.inter(fontSize: 12, color: Colors.white54),
      ),
      cardTheme: CardThemeData(
        color: cardColor,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: dividerColor, width: 1),
        ),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: surfaceColor,
        elevation: 0,
        centerTitle: false,
        iconTheme: const IconThemeData(color: Colors.white),
        titleTextStyle: GoogleFonts.poppins(
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: Colors.white,
          letterSpacing: -0.5,
        ),
        surfaceTintColor: Colors.transparent,
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: surfaceVariant,
        selectedItemColor: primaryColor,
        unselectedItemColor: Colors.white38,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
        selectedLabelStyle: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.w600),
        unselectedLabelStyle: GoogleFonts.poppins(fontSize: 11),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          elevation: 0,
          textStyle: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primaryLight,
          side: const BorderSide(color: primaryColor, width: 1.5),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          textStyle: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w500),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surfaceVariant,
        hintStyle: GoogleFonts.inter(color: Colors.white30, fontSize: 14),
        labelStyle: GoogleFonts.inter(color: Colors.white54, fontSize: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: dividerColor),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: dividerColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: primaryColor, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFFCF6679)),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: surfaceVariant,
        selectedColor: primaryColor,
        labelStyle: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w500),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: dividerColor),
        ),
      ),
      dividerTheme: const DividerThemeData(color: dividerColor, thickness: 1),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: cardColor,
        contentTextStyle: GoogleFonts.inter(color: Colors.white),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        behavior: SnackBarBehavior.floating,
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: surfaceVariant,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        titleTextStyle: GoogleFonts.poppins(
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: Colors.white,
        ),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        elevation: 4,
      ),
    );
  }
}
