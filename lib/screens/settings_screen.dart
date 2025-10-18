import 'package:flutter/material.dart';

class SettingsScreen extends StatefulWidget {
  final ThemeMode themeMode;
  final void Function(bool isDark) onThemeChanged;

  const SettingsScreen({
    super.key,
    required this.themeMode,
    required this.onThemeChanged,
  });

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _themeAnimationController;
  bool _notificationsEnabled = true;
  String _selectedCurrency = 'USD';

  @override
  void initState() {
    super.initState();
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
        Card(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          child: ListTile(
            leading: Icon(
              isDark ? Icons.dark_mode_rounded : Icons.light_mode_rounded,
              color: cs.primary,
            ),
            title: const Text('Tema oscuro'),
            trailing: Switch(
              value: isDark,
              onChanged: (value) {
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