import 'package:flutter/material.dart';

/// App genelinde kullanılan 5 ana sekme.
enum AppTab {
  dashboard(
    label: 'Dashboard',
    icon: Icons.dashboard_outlined,
    selectedIcon: Icons.dashboard,
  ),
  map(
    label: 'Harita',
    icon: Icons.map_outlined,
    selectedIcon: Icons.map,
  ),
  transactions(
    label: 'Geçmiş',
    icon: Icons.receipt_long_outlined,
    selectedIcon: Icons.receipt_long,
  ),
  profile(
    label: 'Profil',
    icon: Icons.person_outline,
    selectedIcon: Icons.person,
  ),
  investment(
    label: 'Yatırım',
    icon: Icons.trending_up_outlined,
    selectedIcon: Icons.trending_up,
  );

  const AppTab({
    required this.label,
    required this.icon,
    required this.selectedIcon,
  });

  final String label;
  final IconData icon;
  final IconData selectedIcon;
}
