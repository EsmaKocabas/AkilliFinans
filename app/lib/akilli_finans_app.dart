import 'package:flutter/material.dart';

import 'app_navigation.dart';
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
  AppTab _selectedTab = AppTab.dashboard;

  void _navigateToTab(AppTab tab) {
    if (_selectedTab == tab) return;
    setState(() {
      _selectedTab = tab;
    });
  }

  @override
  Widget build(BuildContext context) {
    const preset = appLightPreset;

    final pages = <AppTab, Widget>{
      AppTab.dashboard: DashboardScreen(
        preset: preset,
        onNavigateToTab: _navigateToTab,
      ),
      AppTab.map: const MapScreen(preset: preset),
      AppTab.transactions: const TransactionsScreen(preset: preset),
      AppTab.profile: const ProfileScreen(preset: preset),
      AppTab.investment: const InvestmentScreen(preset: preset),
    };

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
        body: pages[_selectedTab]!,
        bottomNavigationBar: NavigationBar(
          selectedIndex: _selectedTab.index,
          onDestinationSelected: (value) {
            _navigateToTab(AppTab.values[value]);
          },
          destinations: [
            for (final tab in AppTab.values)
              NavigationDestination(
                icon: Icon(tab.icon),
                selectedIcon: Icon(tab.selectedIcon),
                label: tab.label,
              ),
          ],
        ),
      ),
    );
  }
}
