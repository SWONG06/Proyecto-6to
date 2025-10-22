import 'package:financecloud/screens/MarketNewsScreen.dart';
import 'package:financecloud/screens/notification_icon_button.dart';
import 'package:financecloud/screens/settings_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'utils/theme.dart';
import 'screens/dashboard_screen.dart';
import 'screens/add_transaction_screen.dart';
import 'screens/transactions_screen.dart';
import 'screens/reports_screen.dart';
import 'screens/market_news_screen.dart';
import 'screens/profile_screen.dart';
import 'models/finance_models.dart';

void main() {
  runApp(const FinanceCloudApp());
}

class FinanceCloudApp extends StatefulWidget {
  const FinanceCloudApp({super.key});

  @override
  State<FinanceCloudApp> createState() => _FinanceCloudAppState();
}

class _FinanceCloudAppState extends State<FinanceCloudApp> {
  ThemeMode _themeMode = ThemeMode.system;
  bool _isAutomaticTheme = false;

  bool _isDarkModeByTime() {
    final hour = DateTime.now().hour;
    return hour >= 20 || hour < 6;
  }

  void _updateThemeMode(bool isDark) {
    setState(() {
      _themeMode = isDark ? ThemeMode.dark : ThemeMode.light;
    });
  }

  void _updateAutomaticTheme(bool isAutomatic) {
    setState(() {
      _isAutomaticTheme = isAutomatic;
      if (isAutomatic) {
        final isDarkNow = _isDarkModeByTime();
        _themeMode = isDarkNow ? ThemeMode.dark : ThemeMode.light;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FinanceCloud',
      debugShowCheckedModeBanner: false,
      theme: buildTheme().copyWith(useMaterial3: true),
      darkTheme: buildDarkTheme().copyWith(useMaterial3: true),
      themeMode: _themeMode,
      localizationsDelegates: [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('en', ''),
        Locale('es', ''),
      ],
      home: MainScreen(
        themeMode: _themeMode,
        isAutomaticTheme: _isAutomaticTheme,
        onThemeChanged: _updateThemeMode,
        onAutomaticThemeChanged: _updateAutomaticTheme,
      ),
    );
  }
}

class MainScreen extends StatefulWidget {
  final ThemeMode themeMode;
  final bool isAutomaticTheme;
  final ValueChanged<bool> onThemeChanged;
  final ValueChanged<bool> onAutomaticThemeChanged;

  const MainScreen({
    super.key,
    required this.themeMode,
    required this.isAutomaticTheme,
    required this.onThemeChanged,
    required this.onAutomaticThemeChanged,
  });

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;
  final FinanceAppState _state = FinanceAppState.seed();
  final List<NotificationItem> _notifications = [
    NotificationItem(
      id: '1',
      title: 'Nueva transacción',
      body: 'Has añadido una transacción exitosamente',
      timestamp: 'Hace 2 minutos',
      icon: Icons.check_circle,
      color: Colors.green,
    ),
    NotificationItem(
      id: '2',
      title: 'Límite de gastos',
      body: 'Has alcanzado el 80% de tu presupuesto',
      timestamp: 'Hace 1 hora',
      icon: Icons.warning,
      color: Colors.orange,
    ),
  ];

  void _navigateToProfile(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ProfileScreen(
          themeMode: widget.themeMode,
          onThemeChanged: widget.onThemeChanged,
        ),
      ),
    );
  }

  void _navigateToScreen(int index) {
    setState(() => _currentIndex = index);
  }

  Widget _buildScreen(int index) {
    switch (index) {
      case 0:
        return DashboardScreen(
          state: _state,
          themeMode: widget.themeMode,
          onThemeChanged: widget.onThemeChanged,
          onNavigateToProfile: () => _navigateToProfile(context),
          notifications: _notifications,
        );
      case 1:
        return AddTransactionScreen(
          onSaved: (tx) => setState(() => _state.transactions.insert(0, tx)),
          themeMode: widget.themeMode,
          onThemeChanged: widget.onThemeChanged,
        );
      case 2:
        return TransactionsScreen(
          state: _state,
          themeMode: widget.themeMode,
          onThemeChanged: widget.onThemeChanged,
        );
      case 3:
        return ReportsScreen(
          state: _state,
          themeMode: widget.themeMode,
          onThemeChanged: widget.onThemeChanged,
        );
      case 99:
        return const MarketNewsScreen();
      case 100:
        return SettingsScreen(
          themeMode: widget.themeMode,
          isAutomaticTheme: widget.isAutomaticTheme,
          onThemeChanged: widget.onThemeChanged,
          onAutomaticThemeChanged: widget.onAutomaticThemeChanged,
        );
      default:
        return DashboardScreen(
          state: _state,
          themeMode: widget.themeMode,
          onThemeChanged: widget.onThemeChanged,
          onNavigateToProfile: () => _navigateToProfile(context),
          notifications: _notifications,
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final List<Map<String, dynamic>> menuItems = [
      {'icon': Icons.house_rounded, 'label': 'Inicio', 'index': 0},
      {'icon': Icons.hls_rounded, 'label': 'Agregar', 'index': 1},
      {'icon': Icons.list_rounded, 'label': 'Movimientos', 'index': 2},
      {'icon': Icons.trending_up_rounded, 'label': 'Reportes', 'index': 3},
      {'icon': Icons.newspaper_rounded, 'label': 'Noticias', 'index': 99},
      {'icon': Icons.grass_rounded, 'label': 'Ajustes', 'index': 100},
    ];

    String getCurrentTitle() {
      final item = menuItems.firstWhere(
        (item) => item['index'] == _currentIndex,
        orElse: () => {'label': 'FinanceCloud'},
      );
      return item['label'];
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          getCurrentTitle(),
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            letterSpacing: -0.5,
          ),
        ),
        centerTitle: false,
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: Colors.transparent,
        actions: [
          NotificationIconButton(
            notificationCount:
                _notifications.where((n) => !n.isRead).length,
            onPressed: () {},
            notifications: _notifications,
            onNotificationTapped: (notification) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(notification.title),
                  duration: const Duration(seconds: 2),
                ),
              );
            },
          ),
          Padding(
            padding: const EdgeInsets.only(right: 12.0),
            child: PopupMenuButton<int>(
              icon: Icon(
                Icons.more_horiz_rounded,
                size: 26,
                color: cs.onSurface,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              color: isDark
                  ? cs.surface.withOpacity(0.95)
                  : Colors.white.withOpacity(0.98),
              elevation: 0,
              offset: const Offset(0, 10),
              onSelected: (index) {
                HapticFeedback.selectionClick();
                _navigateToScreen(index);
              },
              itemBuilder: (BuildContext context) {
                return menuItems.map((item) {
                  final isActive = _currentIndex == item['index'];
                  return PopupMenuItem<int>(
                    value: item['index'],
                    height: 44,
                    child: Container(
                      decoration: BoxDecoration(
                        color: isActive
                            ? cs.primary.withOpacity(0.08)
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 4,
                        vertical: 2,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            item['icon'],
                            color: isActive ? cs.primary : cs.onSurface,
                            size: 20,
                          ),
                          const SizedBox(width: 12),
                          Text(
                            item['label'],
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: isActive
                                  ? FontWeight.w600
                                  : FontWeight.w500,
                              color: isActive ? cs.primary : cs.onSurface,
                              letterSpacing: -0.3,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList();
              },
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: _buildScreen(_currentIndex),
      ),
    );
  }
}