import 'package:flutter/material.dart';

class SettingsScreen extends StatefulWidget {
  final ThemeMode themeMode;
  final void Function(bool isDark) onThemeChanged;
  final void Function(bool isAutomatic) onAutomaticThemeChanged;
  final bool isAutomaticTheme;

  const SettingsScreen({
    super.key,
    required this.themeMode,
    required this.onThemeChanged,
    required this.onAutomaticThemeChanged,
    required this.isAutomaticTheme,
  });

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _themeAnimationController;
  bool _notificationsEnabled = true;
  String _selectedCurrency = 'USD';
  late bool _isAutomaticTheme;

  @override
  void initState() {
    super.initState();
    _isAutomaticTheme = widget.isAutomaticTheme;
    
    _themeAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    if (widget.themeMode == ThemeMode.dark) {
      _themeAnimationController.value = 1.0;
    }
  }

  @override
  void dispose() {
    _themeAnimationController.dispose();
    super.dispose();
  }

  bool _isDarkModeByTime() {
    final hour = DateTime.now().hour;
    // Modo oscuro de 20:00 (8 PM) a 06:00 (6 AM)
    return hour >= 20 || hour < 6;
  }

  String _getTimeRangeText() {
    return 'Modo oscuro: 20:00 - 06:00';
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isDark = widget.themeMode == ThemeMode.dark;

    return ListView(
      children: [
        const SizedBox(height: 16),
        // Sección de Tema
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'Apariencia',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
          ),
        ),
        const SizedBox(height: 12),
        // Modo Automático
        Card(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          child: ListTile(
            leading: Icon(
              Icons.schedule_rounded,
              color: cs.primary,
            ),
            title: const Text('Modo automático'),
            subtitle: Text(_getTimeRangeText()),
            trailing: Switch(
              value: _isAutomaticTheme,
              onChanged: (value) {
                setState(() => _isAutomaticTheme = value);
                widget.onAutomaticThemeChanged(value);
                
                // Si se activa el automático, aplicar el tema según la hora
                if (value) {
                  final isDarkNow = _isDarkModeByTime();
                  widget.onThemeChanged(isDarkNow);
                  if (isDarkNow) {
                    _themeAnimationController.forward();
                  } else {
                    _themeAnimationController.reverse();
                  }
                }
              },
            ),
          ),
        ),
        const SizedBox(height: 12),
        // Tema Manual (deshabilitado si está en modo automático)
        Card(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          child: ListTile(
            leading: Icon(
              isDark ? Icons.dark_mode_rounded : Icons.light_mode_rounded,
              color: _isAutomaticTheme ? cs.outline : cs.primary,
            ),
            title: Text(
              'Tema oscuro',
              style: TextStyle(
                color: _isAutomaticTheme ? cs.outline : null,
              ),
            ),
            trailing: Switch(
              value: isDark,
              onChanged: _isAutomaticTheme
                  ? null
                  : (value) {
                      widget.onThemeChanged(value);
                      if (value) {
                        _themeAnimationController.forward();
                      } else {
                        _themeAnimationController.reverse();
                      }
                    },
            ),
          ),
        ),
        const SizedBox(height: 24),
        // Sección de Notificaciones
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'Notificaciones',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
          ),
        ),
        const SizedBox(height: 12),
        Card(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          child: ListTile(
            leading: Icon(
              Icons.notifications_rounded,
              color: cs.primary,
            ),
            title: const Text('Habilitar notificaciones'),
            trailing: Switch(
              value: _notificationsEnabled,
              onChanged: (value) {
                setState(() => _notificationsEnabled = value);
              },
            ),
          ),
        ),
        const SizedBox(height: 24),
        // Sección de Moneda
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'Configuración',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
          ),
        ),
        const SizedBox(height: 12),
        Card(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          child: ListTile(
            leading: Icon(
              Icons.currency_exchange_rounded,
              color: cs.primary,
            ),
            title: const Text('Moneda'),
            trailing: DropdownButton<String>(
              value: _selectedCurrency,
              underline: const SizedBox(),
              items: const [
                DropdownMenuItem(value: 'USD', child: Text('USD')),
                DropdownMenuItem(value: 'EUR', child: Text('EUR')),
                DropdownMenuItem(value: 'PEN', child: Text('PEN')),
                DropdownMenuItem(value: 'MXN', child: Text('MXN')),
              ],
              onChanged: (value) {
                setState(() => _selectedCurrency = value ?? 'USD');
              },
            ),
          ),
        ),
        const SizedBox(height: 24),
        // Sección de Información
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'Información',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
          ),
        ),
        const SizedBox(height: 12),
        Card(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          child: ListTile(
            leading: Icon(
              Icons.info_outline_rounded,
              color: cs.primary,
            ),
            title: const Text('Versión'),
            trailing: const Text('1.0.0'),
          ),
        ),
        const SizedBox(height: 16),
        Card(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          child: ListTile(
            leading: Icon(
              Icons.help_outline_rounded,
              color: cs.primary,
            ),
            title: const Text('Acerca de'),
            onTap: () {
              showAboutDialog(
                context: context,
                applicationName: 'FinanceCloud',
                applicationVersion: '1.0.0',
                applicationLegalese: '© 2025 FinanceCloud',
              );
            },
          ),
        ),
        const SizedBox(height: 32),
      ],
    );
  }
}