import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'dart:ui';
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
        onThemeChanged: (bool isDark) {
          setState(() {
            _themeMode = isDark ? ThemeMode.dark : ThemeMode.light;
          });
        },
      ),
    );
  }
}

class MainScreen extends StatefulWidget {
  final ThemeMode themeMode;
  final ValueChanged<bool> onThemeChanged;

  const MainScreen({
    super.key,
    required this.themeMode,
    required this.onThemeChanged,
  });

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;
  final FinanceAppState _state = FinanceAppState.seed();
  final Widget qrScreen = const QrScreen();

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

  @override
  Widget build(BuildContext context) {
    final screens = [
      DashboardScreen(
        state: _state,
        themeMode: widget.themeMode,
        onThemeChanged: widget.onThemeChanged,
        onNavigateToProfile: () => _navigateToProfile(context),
      ),
      AddTransactionScreen(
        onSaved: (tx) => setState(() => _state.transactions.insert(0, tx)),
        themeMode: widget.themeMode,
        onThemeChanged: widget.onThemeChanged,
      ),
      TransactionsScreen(
        state: _state,
        themeMode: widget.themeMode,
        onThemeChanged: widget.onThemeChanged,
      ),
      ReportsScreen(
        state: _state,
        themeMode: widget.themeMode,
        onThemeChanged: widget.onThemeChanged,
      ),
    ];

    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: SafeArea(
        child: _currentIndex == 99 ? qrScreen : screens[_currentIndex],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: FloatingActionButton(
        backgroundColor: cs.primary,
        elevation: 0,
        shape: const CircleBorder(),
        onPressed: () {
          HapticFeedback.lightImpact();
          setState(() => _currentIndex = 99);
        },
        child: Icon(Icons.qr_code_2_rounded, size: 36, color: Colors.white),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.only(bottom: 16, left: 16, right: 16),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
            child: Container(
              decoration: BoxDecoration(
                color: isDark
                    ? Colors.white.withOpacity(0.08)
                    : Colors.white.withOpacity(0.15),
                border: Border.all(
                  color: isDark
                      ? Colors.white.withOpacity(0.15)
                      : Colors.white.withOpacity(0.25),
                  width: 1.5,
                ),
                borderRadius: BorderRadius.circular(24),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _NavItem(
                    icon: _currentIndex == 0
                        ? Icons.home_rounded
                        : Icons.home_outlined,
                    isActive: _currentIndex == 0,
                    onTap: () => setState(() => _currentIndex = 0),
                  ),
                  _NavItem(
                    icon: _currentIndex == 1
                        ? Icons.add_circle_rounded
                        : Icons.add_circle_outline,
                    isActive: _currentIndex == 1,
                    onTap: () => setState(() => _currentIndex = 1),
                  ),
                  SizedBox(width: 48),
                  _NavItem(
                    icon: _currentIndex == 2
                        ? Icons.receipt_long_rounded
                        : Icons.receipt_long_outlined,
                    isActive: _currentIndex == 2,
                    onTap: () => setState(() => _currentIndex = 2),
                  ),
                  _NavItem(
                    icon: _currentIndex == 3
                        ? Icons.show_chart_rounded
                        : Icons.show_chart_outlined,
                    isActive: _currentIndex == 3,
                    onTap: () => setState(() => _currentIndex = 3),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatefulWidget {
  final IconData icon;
  final bool isActive;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.isActive,
    required this.onTap,
  });

  @override
  State<_NavItem> createState() => _NavItemState();
}

class _NavItemState extends State<_NavItem>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.85).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return ScaleTransition(
      scale: _scaleAnimation,
      child: GestureDetector(
        onTapDown: (_) => _controller.forward(),
        onTapUp: (_) {
          _controller.reverse();
          HapticFeedback.lightImpact();
          widget.onTap();
        },
        onTapCancel: () => _controller.reverse(),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          child: Icon(
            widget.icon,
            size: 28,
            color: widget.isActive ? cs.primary : cs.onSurface.withOpacity(0.6),
          ),
        ),
      ),
    );
  }
}