import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'app_navigation.dart';
import 'dashboard_screen.dart';
import 'design_presets.dart';
import 'investment_screen.dart';
import 'map_screen.dart';
import 'profile_screen.dart';
import 'theme/design_tokens.dart';
import 'transactions_screen.dart';
import 'package:provider/provider.dart';
import 'services/session_service.dart';

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
      
      initialRoute: AppSession.instance.isLoggedIn ? '/dashboard' : '/login',
      
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
  List<dynamic> _notifications = [];
  Timer? _pollingTimer;

  void _navigateToTab(AppTab tab) {
    if (_selectedTab == tab) return;
    setState(() {
      _selectedTab = tab;
    });
  }

  @override
  void initState() {
    super.initState();
    _fetchNotifications();
    
    // Auto-fetch notifications when the budget state changes (e.g. after transaction or trade)
    AppSession.instance.addListener(_onBudgetChanged);
    
    // Poll for new notifications every 15 seconds
    _pollingTimer = Timer.periodic(const Duration(seconds: 15), (_) {
      if (mounted) {
        _fetchNotifications();
      }
    });
  }

  @override
  void dispose() {
    AppSession.instance.removeListener(_onBudgetChanged);
    _pollingTimer?.cancel();
    super.dispose();
  }

  void _onBudgetChanged() {
    _fetchNotifications();
  }

  Future<void> _fetchNotifications() async {
    if (!mounted) return;
    final session = context.read<AppSession>();
    if (!session.isLoggedIn) return;
    try {
      final url = Uri.parse('${AppSession.baseUrl}/api/notifications');
      final res = await http.get(url, headers: session.headers);
      if (res.statusCode == 200) {
        final decoded = jsonDecode(res.body);
        if (decoded['status'] == 'success') {
          if (mounted) {
            setState(() {
              _notifications = decoded['data'] ?? [];
            });
          }
        }
      }
    } catch (e) {
      debugPrint('Error fetching notifications: $e');
    }
  }

  Future<void> _markAsRead(int notifId) async {
    if (!mounted) return;
    final session = context.read<AppSession>();
    try {
      final url = Uri.parse('${AppSession.baseUrl}/api/notifications/$notifId/read');
      final res = await http.put(url, headers: session.headers);
      if (res.statusCode == 200) {
        if (mounted) {
          setState(() {
            final index = _notifications.indexWhere((n) => n['id'] == notifId);
            if (index != -1) {
              _notifications[index]['isRead'] = true;
            }
          });
        }
      }
    } catch (e) {
      debugPrint('Error marking notification as read: $e');
    }
  }

  Future<void> _markAllAsRead() async {
    if (!mounted) return;
    final session = context.read<AppSession>();
    try {
      final url = Uri.parse('${AppSession.baseUrl}/api/notifications/read-all');
      final res = await http.put(url, headers: session.headers);
      if (res.statusCode == 200) {
        if (mounted) {
          setState(() {
            for (var n in _notifications) {
              n['isRead'] = true;
            }
          });
        }
      }
    } catch (e) {
      debugPrint('Error marking all notifications as read: $e');
    }
  }

  int get _unreadCount => _notifications.where((n) => !(n['isRead'] as bool)).length;

  String _formatTime(String rawDate) {
    try {
      final dt = DateTime.parse(rawDate).toLocal();
      final now = DateTime.now();
      final diff = now.difference(dt);
      
      if (diff.inSeconds < 60) {
        return 'Şimdi';
      } else if (diff.inMinutes < 60) {
        return '${diff.inMinutes} dk önce';
      } else if (diff.inHours < 24) {
        return '${diff.inHours} sa önce';
      } else if (diff.inDays == 1) {
        return 'Dün';
      } else {
        return '${dt.day.toString().padLeft(2, '0')}.${dt.month.toString().padLeft(2, '0')}.${dt.year}';
      }
    } catch (_) {
      return '';
    }
  }

  void _showNotificationsSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            final unreadList = _notifications.where((n) => !(n['isRead'] as bool)).toList();
            
            return Container(
              height: MediaQuery.of(context).size.height * 0.70,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: Column(
                children: [
                  // Grab Handle
                  Center(
                    child: Container(
                      margin: const EdgeInsets.only(top: 10, bottom: 8),
                      width: 44,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  // Header
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            const Text(
                              'Bildirimler',
                              style: TextStyle(
                                fontSize: 19,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF111827),
                              ),
                            ),
                            if (unreadList.isNotEmpty) ...[
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: Colors.red[50],
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  '${unreadList.length} yeni',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: Colors.red[700],
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ]
                          ],
                        ),
                        if (unreadList.isNotEmpty)
                          TextButton(
                            onPressed: () async {
                              await _markAllAsRead();
                              setSheetState(() {});
                            },
                            child: const Text(
                              'Hepsini Okundu Yap',
                              style: TextStyle(
                                color: Color(0xFF111827),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                  const Divider(height: 1),
                  // Notifications List
                  Expanded(
                    child: _notifications.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.notifications_none_outlined,
                                  size: 48,
                                  color: Colors.grey[400],
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'Henüz bildiriminiz yok',
                                  style: TextStyle(
                                    fontSize: 15,
                                    color: Colors.grey[500],
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          )
                        : ListView.separated(
                            itemCount: _notifications.length,
                            separatorBuilder: (context, index) => const Divider(height: 1, indent: 72),
                            itemBuilder: (context, index) {
                              final notif = _notifications[index];
                              final isRead = notif['isRead'] as bool;
                              final notifId = notif['id'] as int;
                              final title = notif['title'] ?? '';
                              final message = notif['message'] ?? '';
                              final type = notif['type'] ?? 'info';
                              final createdAt = notif['createdAt'] ?? '';

                              IconData iconData;
                              Color iconBgColor;
                              Color iconColor;

                              switch (type) {
                                case 'warning':
                                  iconData = Icons.warning_amber_rounded;
                                  iconBgColor = const Color(0xFFFEF3C7);
                                  iconColor = const Color(0xFFD97706);
                                  break;
                                case 'transaction':
                                  iconData = Icons.account_balance_wallet_outlined;
                                  iconBgColor = const Color(0xFFDBEAFE);
                                  iconColor = const Color(0xFF2563EB);
                                  break;
                                case 'investment':
                                  iconData = Icons.trending_up_outlined;
                                  iconBgColor = const Color(0xFFD1FAE5);
                                  iconColor = const Color(0xFF059669);
                                  break;
                                case 'welcome':
                                default:
                                  iconData = Icons.celebration_outlined;
                                  iconBgColor = const Color(0xFFF3F4F6);
                                  iconColor = const Color(0xFF4B5563);
                                  break;
                              }

                              return InkWell(
                                onTap: () async {
                                  if (!isRead) {
                                    await _markAsRead(notifId);
                                    setSheetState(() {});
                                  }
                                },
                                child: Container(
                                  color: isRead ? Colors.transparent : const Color(0xFFF9FAFB),
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                  child: Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      // Rounded Icon
                                      Container(
                                        width: 40,
                                        height: 40,
                                        decoration: BoxDecoration(
                                          color: iconBgColor,
                                          shape: BoxShape.circle,
                                        ),
                                        child: Icon(
                                          iconData,
                                          color: iconColor,
                                          size: 20,
                                        ),
                                      ),
                                      const SizedBox(width: 16),
                                      // Main Text Content
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                              children: [
                                                Expanded(
                                                  child: Text(
                                                    title,
                                                    style: TextStyle(
                                                      fontSize: 14,
                                                      fontWeight: isRead ? FontWeight.w500 : FontWeight.bold,
                                                      color: const Color(0xFF111827),
                                                    ),
                                                  ),
                                                ),
                                                Text(
                                                  _formatTime(createdAt),
                                                  style: TextStyle(
                                                    fontSize: 11,
                                                    color: Colors.grey[500],
                                                  ),
                                                ),
                                              ],
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              message,
                                              style: TextStyle(
                                                fontSize: 13,
                                                color: isRead ? const Color(0xFF4B5563) : const Color(0xFF1F2937),
                                                height: 1.45,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      // Blue Dot for unread
                                      if (!isRead) ...[
                                        const SizedBox(width: 8),
                                        Container(
                                          margin: const EdgeInsets.only(top: 6),
                                          width: 8,
                                          height: 8,
                                          decoration: const BoxDecoration(
                                            color: Colors.blue,
                                            shape: BoxShape.circle,
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
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
        actions: [
          IconButton(
            icon: Stack(
              clipBehavior: Clip.none,
              children: [
                const Icon(Icons.notifications_outlined, size: 26),
                if (_unreadCount > 0)
                  Positioned(
                    right: -2,
                    top: -2,
                    child: Container(
                      padding: const EdgeInsets.all(2),
                      decoration: const BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
                      constraints: const BoxConstraints(
                        minWidth: 14,
                        minHeight: 14,
                      ),
                      child: Center(
                        child: Text(
                          '$_unreadCount',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 8,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            onPressed: () {
              _showNotificationsSheet(context);
            },
          ),
          const SizedBox(width: 12),
        ],
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