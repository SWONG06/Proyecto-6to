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

  void _showAboutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Encabezado
                  Center(
                    child: Column(
                      children: [
                        Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Icon(
                            Icons.cloud_rounded,
                            size: 50,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'FinanceCloud',
                          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'v1.0.0',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Theme.of(context).colorScheme.outline,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  
                  // Descripción
                  Text(
                    'Acerca de la Aplicación',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'FinanceCloud es tu asistente personal para la gestión inteligente de tus finanzas. '
                    'Con una interfaz moderna y herramientas avanzadas, puedes controlar tus gastos, '
                    'ingresos y generar reportes detallados para tomar decisiones financieras más informadas.',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 24),

                  // Características principales
                  Text(
                    'Características Principales',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildFeatureItem(context, Icons.dashboard_rounded, 'Dashboard', 'Visualiza un resumen completo de tus finanzas'),
                  _buildFeatureItem(context, Icons.add_circle_rounded, 'Transacciones', 'Registra y categoriza tus gastos e ingresos'),
                  _buildFeatureItem(context, Icons.show_chart_rounded, 'Reportes', 'Analiza tendencias y patrones de gasto'),
                  _buildFeatureItem(context, Icons.qr_code_2_rounded, 'Código QR', 'Escanea y procesa información rápidamente'),
                  const SizedBox(height: 24),

                  // Información técnica
                  Text(
                    'Información Técnica',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildInfoRow(context, 'Versión:', '1.0.0'),
                  _buildInfoRow(context, 'Plataforma:', 'Flutter'),
                  _buildInfoRow(context, 'Material Design:', '3.0'),
                  const SizedBox(height: 24),

                  // Licencia
                  Text(
                    'Licencia y Derechos de Autor',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    '© 2025 FinanceCloud. Todos los derechos reservados.\n\n'
                    'Esta aplicación se proporciona bajo licencia de uso. Se prohíbe la reproducción, '
                    'distribución o transmisión sin permiso expreso.',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  const SizedBox(height: 24),

                  // Botón cerrar
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cerrar'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildFeatureItem(BuildContext context, IconData icon, String title, String description) {
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: cs.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              icon,
              color: cs.primary,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.outline,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(BuildContext context, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.outline,
            ),
          ),
          Text(
            value,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
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
            onTap: () => _showAboutDialog(context),
          ),
        ),
        const SizedBox(height: 32),
      ],
    );
  }
}