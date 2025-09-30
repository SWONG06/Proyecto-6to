import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // para haptic feedback
import 'package:flutter_localizations/flutter_localizations.dart'; // 👈 IMPORTANTE
import 'utils/theme.dart';
import 'screens/dashboard_screen.dart';
import 'screens/add_transaction_screen.dart';
import 'screens/transactions_screen.dart';
import 'screens/reports_screen.dart';
import 'screens/qr_screen.dart';
import 'screens/profile_screen.dart'; // IMPORTAR PROFILE
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

      // 👇 localizaciones
      localizationsDelegates: [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('en', ''), // Inglés
        Locale('es', ''), // Español
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

// WIDGET SEPARADO PARA EL CONTENIDO PRINCIPAL
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
  int _currentIndex = 0; // 0 Inicio, 1 Agregar, 2 Transacciones, 3 Reportes, 99 QR
  
  final FinanceAppState _state = FinanceAppState.seed();
  
  // Pantalla QR
  final Widget qrScreen = const QrScreen();

  // FUNCIÓN PARA NAVEGAR A PROFILE
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
    // Screens
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
    
    return Scaffold(
      body: SafeArea(
        child: _currentIndex == 99
            ? qrScreen // Pantalla QR
            : screens[_currentIndex],
      ),

      // FAB central para QR
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: FloatingActionButton(
        backgroundColor: Theme.of(context).colorScheme.primary,
        elevation: 4,
        shape: const CircleBorder(),
        onPressed: () {
          HapticFeedback.lightImpact();
          setState(() {
            _currentIndex = 99; // Pantalla QR
          });
        },
        child: const Icon(Icons.qr_code_2_rounded, size: 32),
      ),

      // BottomAppBar con íconos
      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        notchMargin: 8.0,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            // Lado izquierdo
            IconButton(
              icon: Icon(
                _currentIndex == 0
                    ? Icons.home_rounded
                    : Icons.home_outlined,
              ),
              onPressed: () {
                setState(() => _currentIndex = 0);
              },
            ),
            IconButton(
              icon: Icon(
                _currentIndex == 1
                    ? Icons.add_circle_rounded
                    : Icons.add_circle_outline,
              ),
              onPressed: () {
                setState(() => _currentIndex = 1);
              },
            ),
            const SizedBox(width: 48), // espacio para FAB
            IconButton(
              icon: Icon(
                _currentIndex == 2
                    ? Icons.receipt_long_rounded
                    : Icons.receipt_long_outlined,
              ),
              onPressed: () {
                setState(() => _currentIndex = 2);
              },
            ),
            IconButton(
              icon: Icon(
                _currentIndex == 3
                    ? Icons.show_chart_rounded
                    : Icons.show_chart_outlined,
              ),
              onPressed: () {
                setState(() => _currentIndex = 3);
              },
            ),
          ],
        ),
      ),
    );
  }
}