import 'package:flutter/material.dart';

import 'app_navigation.dart';
import 'dashboard_screen.dart';
import 'design_presets.dart';
import 'investment_screen.dart';
import 'map_screen.dart';
import 'profile_screen.dart';
import 'theme/design_tokens.dart';
import 'transactions_screen.dart';


import 'login_screen.dart';
import 'register_screen.dart';
import 'forgot_password_screen.dart';

class AkilliFinansApp extends StatelessWidget {
  const AkilliFinansApp({super.key});

  @override
  Widget build(BuildContext context) {
    const preset = appLightPreset;

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
      
      initialRoute: '/login',
      
      routes: {
        '/login': (context) => const LoginScreen(),
        '/register': (context) => const RegisterScreen(),
        '/forgot_password': (context) => ForgotPasswordScreen(),
        '/dashboard': (context) => const MainAppShell(), 
      },
    );
  }
}


class MainAppShell extends StatefulWidget {
  const MainAppShell({super.key});

  @override
  State<MainAppShell> createState() => _MainAppShellState();
}

class _MainAppShellState extends State<MainAppShell> {
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

    return Scaffold(
      appBar: AppBar(
        title: const Text('Akıllı Finans'),
        automaticallyImplyLeading: false, 
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
    );
  }
}