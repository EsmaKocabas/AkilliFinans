import 'package:flutter/material.dart';

/// Uygulama geneli renk, tipografi ve boşluk standardı (grafik/bakiye kartları için tutarlılık).
abstract final class AppColors {
  static const Color canvas = Color(0xFFF5F5F5);
  static const Color surface = Colors.white;
  static const Color borderSubtle = Color(0x1F000000); // black12
  static const Color textPrimary = Color(0xFF000000);
  static const Color textSecondary = Color(0xFF616161);
  static const Color textMuted = Color(0xFF757575);
  static const Color chipBackground = Color(0xFFF1F1F1);
  static const Color heroDark = Color(0xFF000000);
}

abstract final class AppSpacing {
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 24;
  static const double xxl = 28;

  /// Ana gövde yatay boşluk: geniş / dar ekran.
  static double screenHorizontal(bool isWideLayout) => isWideLayout ? xxl : lg;

  static const double screenTop = lg;
  static const double screenBottom = xxl;

  static EdgeInsets screenEdgeInsets({required bool wide}) {
    final h = screenHorizontal(wide);
    return EdgeInsets.fromLTRB(h, screenTop, h, screenBottom);
  }
}

abstract final class AppRadii {
  static const double card = 16;
  static const double tile = 14;
  static const double chip = 999;
}

/// Material 3 varsayılan fontu üzerinden okunabilir hiyerarşi.
abstract final class AppTypography {
  static const TextStyle pageTitle = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.w800,
    height: 1.15,
    color: AppColors.textPrimary,
  );

  static const TextStyle pageSubtitle = TextStyle(
    fontSize: 14,
    height: 1.35,
    color: AppColors.textSecondary,
  );

  static const TextStyle sectionTitle = TextStyle(
    fontSize: 17,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
  );

  static const TextStyle sectionHint = TextStyle(
    fontSize: 12,
    color: AppColors.textSecondary,
  );

  static const TextStyle listTitle = TextStyle(
    fontWeight: FontWeight.w600,
    fontSize: 16,
    color: AppColors.textPrimary,
  );

  static const TextStyle listSubtitle = TextStyle(
    fontSize: 13,
    color: AppColors.textSecondary,
  );

  static const TextStyle caption = TextStyle(
    fontSize: 11,
    color: AppColors.textMuted,
  );
}

abstract final class AppDecorations {
  static BoxDecoration surfaceCard({Color? color}) {
    return BoxDecoration(
      color: color ?? AppColors.surface,
      borderRadius: BorderRadius.circular(AppRadii.card),
      border: Border.all(color: AppColors.borderSubtle),
    );
  }
}
