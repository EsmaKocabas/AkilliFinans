import 'package:flutter/material.dart';

import 'dashboard_screen.dart';
import 'design_presets.dart';
import 'investment_screen.dart';
import 'map_screen.dart';
import 'profile_screen.dart';
import 'theme/design_tokens.dart';
import 'transactions_screen.dart';

class AkilliFinansApp extends StatefulWidget {
  const AkilliFinansApp({super.key});

  @override
  State<AkilliFinansApp> createState() => _AkilliFinansAppState();
}

class _AkilliFinansAppState extends State<AkilliFinansApp> {
  int _selectedTab = 0;

  @override
  Widget build(BuildContext context) {
    const preset = appLightPreset;

    final pages = <Widget>[
      DashboardScreen(
        preset: preset,
        onNavigateToTab: (index) => setState(() => _selectedTab = index),
      ),
      const MapScreen(preset: preset),
      const TransactionsScreen(preset: preset),
      const ProfileScreen(preset: preset),
      const InvestmentScreen(preset: preset),
    ];

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Akıllı Finans',
      themeMode: ThemeMode.light,
      theme: ThemeData(
        colorScheme: ColorScheme.light(
          surface: preset.surface,
          primary: preset.primary,
          onPrimary: Colors.white,
          onSurface: preset.onSurface,
        ),
        scaffoldBackgroundColor: AppColors.canvas,
        useMaterial3: true,
      ),
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Akıllı Finans'),
        ),
        body: pages[_selectedTab],
        bottomNavigationBar: NavigationBar(
          selectedIndex: _selectedTab,
          onDestinationSelected: (value) {
            setState(() {
              _selectedTab = value;
            });
          },
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.dashboard_outlined),
              selectedIcon: Icon(Icons.dashboard),
              label: 'Dashboard',
            ),
            NavigationDestination(
              icon: Icon(Icons.map_outlined),
              selectedIcon: Icon(Icons.map),
              label: 'Harita',
            ),
            NavigationDestination(
              icon: Icon(Icons.receipt_long_outlined),
              selectedIcon: Icon(Icons.receipt_long),
              label: 'Geçmiş',
            ),
            NavigationDestination(
              icon: Icon(Icons.person_outline),
              selectedIcon: Icon(Icons.person),
              label: 'Profil',
            ),
            NavigationDestination(
              icon: Icon(Icons.trending_up_outlined),
              selectedIcon: Icon(Icons.trending_up),
              label: 'Yatırım',
            ),
          ],
        ),
      ),
    );
  }
}
