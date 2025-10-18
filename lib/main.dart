import 'package:financecloud/screens/settings_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'utils/theme.dart';
import 'screens/dashboard_screen.dart';
import 'screens/add_transaction_screen.dart';
import 'screens/transactions_screen.dart';
import 'screens/reports_screen.dart';
import 'screens/qr_screen.dart';
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
        return const QrScreen();
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
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final List<Map<String, dynamic>> menuItems = [
      {'icon': Icons.home_rounded, 'label': 'Dashboard', 'index': 0},
      {'icon': Icons.add_circle_rounded, 'label': 'Agregar', 'index': 1},
      {'icon': Icons.receipt_long_rounded, 'label': 'Transacciones', 'index': 2},
      {'icon': Icons.show_chart_rounded, 'label': 'Reportes', 'index': 3},
      {'icon': Icons.qr_code_2_rounded, 'label': 'QR', 'index': 99},
      {'icon': Icons.settings_rounded, 'label': 'Ajustes', 'index': 100},
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
          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
        ),
        centerTitle: true,
        elevation: 0,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: PopupMenuButton<int>(
              icon: const Icon(Icons.menu_rounded, size: 28),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              color: isDark
                  ? Colors.grey[900]?.withOpacity(0.95)
                  : Colors.white.withOpacity(0.95),
              elevation: 8,
              onSelected: (index) {
                HapticFeedback.lightImpact();
                _navigateToScreen(index);
              },
              itemBuilder: (BuildContext context) {
                return menuItems.map((item) {
                  final isActive = _currentIndex == item['index'];
                  return PopupMenuItem<int>(
                    value: item['index'],
                    child: Container(
                      decoration: BoxDecoration(
                        color: isActive
                            ? cs.primary.withOpacity(0.15)
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            item['icon'],
                            color: isActive ? cs.primary : cs.onSurface,
                            size: 24,
                          ),
                          const SizedBox(width: 16),
                          Text(
                            item['label'],
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: isActive
                                  ? FontWeight.w700
                                  : FontWeight.w600,
                              color: isActive ? cs.primary : cs.onSurface,
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