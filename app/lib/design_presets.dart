import 'package:flutter/material.dart';

import 'design_preset.dart';

/// Central list for all UI variants shown in the prototype.
const List<DesignPreset> designPresets = [
  DesignPreset(
    name: 'Wireframe Light',
    primary: Color(0xFF2D3748),
    background: Color(0xFFF7F8FA),
    surface: Color(0xFFFFFFFF),
    onSurface: Color(0xFF1A202C),
    accent: Color(0xFF4A5568),
  ),
  DesignPreset(
    name: 'Dark Pro',
    primary: Color(0xFF90CDF4),
    background: Color(0xFF0F172A),
    surface: Color(0xFF1E293B),
    onSurface: Color(0xFFF8FAFC),
    accent: Color(0xFF38BDF8),
  ),
  DesignPreset(
    name: 'Fintech Neon',
    primary: Color(0xFF00F5D4),
    background: Color(0xFF0B1020),
    surface: Color(0xFF161B2C),
    onSurface: Color(0xFFE2E8F0),
    accent: Color(0xFF9B5DE5),
  ),
  DesignPreset(
    name: 'Corporate Blue',
    primary: Color(0xFF1D4ED8),
    background: Color(0xFFEFF6FF),
    surface: Color(0xFFFFFFFF),
    onSurface: Color(0xFF1E3A8A),
    accent: Color(0xFF3B82F6),
  ),
  DesignPreset(
    name: 'Minimal Gray',
    primary: Color(0xFF525252),
    background: Color(0xFFFAFAFA),
    surface: Color(0xFFFFFFFF),
    onSurface: Color(0xFF111827),
    accent: Color(0xFF6B7280),
  ),
];
