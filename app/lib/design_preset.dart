import 'package:flutter/material.dart';

/// Stores a reusable UI color profile for wireframe variants.
class DesignPreset {
  const DesignPreset({
    required this.name,
    required this.primary,
    required this.background,
    required this.surface,
    required this.onSurface,
    required this.accent,
  });

  final String name;
  final Color primary;
  final Color background;
  final Color surface;
  final Color onSurface;
  final Color accent;
}
