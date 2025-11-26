import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'utils/theme.dart';
import 'models/finance_models.dart';
import 'screens/dashboard_screen.dart';
import 'screens/add_transaction_screen.dart';
import 'screens/transactions_screen.dart';
import 'screens/reports_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/market_news_screen.dart';
import 'screens/notification_icon_button.dart';
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'screens/user_profile_screen.dart';
import 'state/finance_app_state.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ✅ Cargar variables .env antes de correr la app
  await dotenv.load(fileName: ".env");

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
  bool _isLoggedIn = false;
  bool _isCheckingAuth = true;

  @override
  void initState() {
    super.initState();
    _checkAuthStatus();
  }

  Future<void> _checkAuthStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final isLoggedIn = prefs.getBool('is_logged_in') ?? false;
    
    setState(() {
      _isLoggedIn = isLoggedIn;
      _isCheckingAuth = false;
    });
  }

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

  void _handleLogout() {
    setState(() {
      _isLoggedIn = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isCheckingAuth) {
      return MaterialApp(
        title: 'Finabiz',
        debugShowCheckedModeBanner: false,
        theme: buildTheme().copyWith(useMaterial3: true),
        darkTheme: buildDarkTheme().copyWith(useMaterial3: true),
        home: Scaffold(
          body: Center(
            child: CircularProgressIndicator(
              color: buildTheme().primaryColor,
            ),
          ),
        ),
      );
    }

    return MaterialApp(
      title: 'Finabiz',
      debugShowCheckedModeBanner: false,
      theme: buildTheme().copyWith(useMaterial3: true),
      darkTheme: buildDarkTheme().copyWith(useMaterial3: true),
      themeMode: _themeMode,
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('en', ''),
        Locale('es', ''),
      ],
      home: _isLoggedIn
          ? MainScreen(
              themeMode: _themeMode,
              isAutomaticTheme: _isAutomaticTheme,
              onThemeChanged: _updateThemeMode,
              onAutomaticThemeChanged: _updateAutomaticTheme,
              onLogout: _handleLogout,
            )
          : LoginScreen(
              onLoginSuccess: () {
                setState(() => _isLoggedIn = true);
              },
            ),
      routes: {
        '/login': (context) => LoginScreen(
          onLoginSuccess: () {
            setState(() => _isLoggedIn = true);
            Navigator.of(context).pushReplacementNamed('/main');
          },
        ),
        '/register': (context) => RegisterScreen(
          onRegisterSuccess: () {
            Navigator.of(context).pushReplacementNamed('/login');
          },
        ),
        '/main': (context) => MainScreen(
          themeMode: _themeMode,
          isAutomaticTheme: _isAutomaticTheme,
          onThemeChanged: _updateThemeMode,
          onAutomaticThemeChanged: _updateAutomaticTheme,
          onLogout: _handleLogout,
        ),
        '/profile': (context) => UserProfileScreen(
          themeMode: _themeMode,
          onThemeChanged: _updateThemeMode,
        ),
      },
    );
  }
}

class MainScreen extends StatefulWidget {
  final ThemeMode themeMode;
  final bool isAutomaticTheme;
  final ValueChanged<bool> onThemeChanged;
  final ValueChanged<bool> onAutomaticThemeChanged;
  final VoidCallback onLogout;

  const MainScreen({
    super.key,
    required this.themeMode,
    required this.isAutomaticTheme,
    required this.onThemeChanged,
    required this.onAutomaticThemeChanged,
    required this.onLogout,
  });

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;
  late Future<FinanceAppState> _stateFuture;
  late FinanceAppState _state;

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

  @override
  void initState() {
    super.initState();
    _stateFuture = FinanceAppState.seed();
    _stateFuture.then((state) {
      setState(() {
        _state = state;
      });
    });
  }

  void _navigateToScreen(int index) {
    setState(() => _currentIndex = index);
  }

  void _navigateToProfile() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => UserProfileScreen(
          themeMode: widget.themeMode,
          onThemeChanged: widget.onThemeChanged,
        ),
      ),
    );
  }

  void _handleLogout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('is_logged_in', false);
    await prefs.clear();
    
    if (mounted) {
      widget.onLogout();
      Navigator.of(context).pushReplacementNamed('/login');
    }
  }

  Widget _buildScreen(int index) {
    switch (index) {
      case 0:
        return DashboardScreen(
          state: _state,
          themeMode: widget.themeMode,
          onThemeChanged: widget.onThemeChanged,
          onNavigateToProfile: _navigateToProfile,
          notifications: _notifications,
        );
      case 1:
        return AddTransactionScreen(
          onSaved: (tx) {
            setState(() {
              _state.addTransaction(tx);
            });
          },
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
          onLogout: _handleLogout,
        );
      default:
        return DashboardScreen(
          state: _state,
          themeMode: widget.themeMode,
          onThemeChanged: widget.onThemeChanged,
          onNavigateToProfile: _navigateToProfile,
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
      {'icon': Icons.newspaper_rounded, 'label': 'Noticias Financieras', 'index': 99},
      {'icon': Icons.settings_rounded, 'label': 'Ajustes', 'index': 100},
    ];

    String getCurrentTitle() {
      final item = menuItems.firstWhere(
        (item) => item['index'] == _currentIndex,
        orElse: () => {'label': 'Finabiz'},
      );
      return item['label'];
    }

    return FutureBuilder<FinanceAppState>(
      future: _stateFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            body: Center(
              child: CircularProgressIndicator(
                color: cs.primary,
              ),
            ),
          );
        }

        if (snapshot.hasError) {
          return Scaffold(
            body: Center(
              child: Text('Error: ${snapshot.error}'),
            ),
          );
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
      },
    );
  }
}