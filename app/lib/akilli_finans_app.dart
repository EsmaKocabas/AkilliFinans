import 'package:flutter/material.dart';

import 'dashboard_screen.dart';
import 'design_preset.dart';
import 'design_presets.dart';
import 'investment_screen.dart';
import 'map_screen.dart';
import 'profile_screen.dart';
import 'transactions_screen.dart';

///seçilen sekme ve UI ön ayarını yönetir.
class AkilliFinansApp extends StatefulWidget {
  const AkilliFinansApp({super.key});

  @override
  State<AkilliFinansApp> createState() => _AkilliFinansAppState();
}

class _AkilliFinansAppState extends State<AkilliFinansApp> {
  int _selectedTab = 0;
  DesignPreset _selectedPreset = designPresets.first;

  @override
  Widget build(BuildContext context) {
    final pages = <Widget>[
      DashboardScreen(preset: _selectedPreset),
      MapScreen(preset: _selectedPreset),
      TransactionsScreen(preset: _selectedPreset),
      ProfileScreen(preset: _selectedPreset),
      InvestmentScreen(preset: _selectedPreset),
    ];

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Akıllı Finans Wireframe',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: _selectedPreset.primary),
        scaffoldBackgroundColor: _selectedPreset.background,
        useMaterial3: true,
      ),
      home: Scaffold(
        appBar: AppBar(
          title: Text('Akıllı Finans - ${_selectedPreset.name}'),
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: DropdownButtonHideUnderline(
                // Theme selector to switch between five UI variants.
                child: DropdownButton<DesignPreset>(
                  value: _selectedPreset,
                  dropdownColor: _selectedPreset.surface,
                  style: TextStyle(color: _selectedPreset.onSurface),
                  iconEnabledColor: _selectedPreset.onSurface,
                  items: designPresets
                      .map(
                        (preset) => DropdownMenuItem<DesignPreset>(
                          value: preset,
                          child: Text(preset.name),
                        ),
                      )
                      .toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        _selectedPreset = value;
                      });
                    }
                  },
                ),
              ),
            ),
          ],
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
