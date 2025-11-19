import 'package:flutter/material.dart';

class SettingsScreen extends StatefulWidget {
  final ThemeMode themeMode;
  final bool isAutomaticTheme;
  final ValueChanged<bool> onThemeChanged;
  final ValueChanged<bool> onAutomaticThemeChanged;
  final VoidCallback onLogout;  // ← AÑADE ESTO

  const SettingsScreen({super.key, 
    required this.themeMode,
    required this.isAutomaticTheme,
    required this.onThemeChanged,
    required this.onAutomaticThemeChanged,
    required this.onLogout,  // ← AÑADE ESTO
  });

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _themeAnimationController;
  bool _notificationsEnabled = true;
  String _selectedCurrency = 'PEN';
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
    return hour >= 20 || hour < 6;
  }

  String _getTimeRangeText() {
    return 'Modo oscuro: 20:00 - 06:00';
  }

  void _showAboutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        final cs = Theme.of(context).colorScheme;
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(28),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Encabezado Premium
                  Center(
                    child: Column(
                      children: [
                        Container(
                          width: 88,
                          height: 88,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                cs.primary.withOpacity(0.15),
                                cs.primary.withOpacity(0.05),
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(
                              color: cs.primary.withOpacity(0.2),
                              width: 2,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: cs.primary.withOpacity(0.15),
                                blurRadius: 16,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          child: Icon(
                            Icons.cloud_rounded,
                            size: 50,
                            color: cs.primary,
                          ),
                        ),
                        const SizedBox(height: 18),
                        Text(
                          'FinanceCloud',
                          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.w800,
                            fontSize: 24,
                            letterSpacing: 0.3,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: cs.primary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: cs.primary.withOpacity(0.3),
                              width: 1,
                            ),
                          ),
                          child: Text(
                            'v1.0.0',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: cs.primary,
                              letterSpacing: 0.3,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 28),
                  
                  // Descripción
                  Text(
                    'Acerca de la Aplicación',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                      fontSize: 16,
                      letterSpacing: 0.2,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'FinanceCloud es tu asistente personal para la gestión inteligente de tus finanzas. '
                    'Con una interfaz moderna y herramientas avanzadas, puedes controlar tus gastos, '
                    'ingresos y generar reportes detallados para tomar decisiones financieras más informadas.',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      height: 1.6,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 28),

                  // Características principales
                  Text(
                    'Características Principales',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                      fontSize: 16,
                      letterSpacing: 0.2,
                    ),
                  ),
                  const SizedBox(height: 14),
                  _buildFeatureItem(context, Icons.dashboard_rounded, 'Dashboard', 'Visualiza un resumen completo de tus finanzas'),
                  _buildFeatureItem(context, Icons.add_circle_rounded, 'Transacciones', 'Registra y categoriza tus gastos e ingresos'),
                  _buildFeatureItem(context, Icons.show_chart_rounded, 'Reportes', 'Analiza tendencias y patrones de gasto'),
                  _buildFeatureItem(context, Icons.smart_toy_rounded, 'Asistente IA', 'Chat inteligente sobre tus finanzas'),
                  const SizedBox(height: 28),

                  // Información técnica
                  Text(
                    'Información Técnica',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                      fontSize: 16,
                      letterSpacing: 0.2,
                    ),
                  ),
                  const SizedBox(height: 14),
                  _buildInfoRow(context, 'Versión:', '1.0.0'),
                  _buildInfoRow(context, 'Plataforma:', 'Flutter'),
                  _buildInfoRow(context, 'Material Design:', '3.0'),
                  const SizedBox(height: 28),

                  // Licencia
                  Text(
                    'Licencia y Derechos de Autor',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                      fontSize: 16,
                      letterSpacing: 0.2,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    '© 2025 FinanceCloud. Todos los derechos reservados.\n\n'
                    'Esta aplicación se proporciona bajo licencia de uso. Se prohíbe la reproducción, '
                    'distribución o transmisión sin permiso expreso.',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      height: 1.6,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 28),

                  // Botón cerrar Premium
                  SizedBox(
                    width: double.infinity,
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [cs.primary, cs.primary.withBlue(220)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: [
                          BoxShadow(
                            color: cs.primary.withOpacity(0.3),
                            blurRadius: 12,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () => Navigator.pop(context),
                          borderRadius: BorderRadius.circular(14),
                          child: const Padding(
                            padding: EdgeInsets.symmetric(vertical: 14),
                            child: Text(
                              'Cerrar',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                                letterSpacing: 0.3,
                              ),
                            ),
                          ),
                        ),
                      ),
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
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  cs.primary.withOpacity(0.15),
                  cs.primary.withOpacity(0.05),
                ],
              ),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: cs.primary.withOpacity(0.2),
                width: 1,
              ),
            ),
            child: Icon(
              icon,
              color: cs.primary,
              size: 22,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant.withOpacity(0.7),
                    fontSize: 13,
                    height: 1.4,
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
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: cs.onSurfaceVariant.withOpacity(0.7),
              fontWeight: FontWeight.w600,
            ),
          ),
          Text(
            value,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w800,
              color: cs.primary,
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

    return Scaffold(
      backgroundColor: cs.background,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: cs.surface,
        title: const Text(
          'Configuración',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w800,
            letterSpacing: 0.3,
          ),
        ),
        centerTitle: false,
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 20),
        children: [
          // Sección de Tema
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              'Apariencia',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.2,
              ),
            ),
          ),
          const SizedBox(height: 14),
          // Modo Automático Premium
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Container(
              decoration: BoxDecoration(
                color: cs.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: cs.outlineVariant.withOpacity(0.2),
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.03),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                leading: Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        cs.primary.withOpacity(0.15),
                        cs.primary.withOpacity(0.05),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: cs.primary.withOpacity(0.2),
                      width: 1,
                    ),
                  ),
                  child: Icon(
                    Icons.schedule_rounded,
                    color: cs.primary,
                    size: 22,
                  ),
                ),
                title: const Text(
                  'Modo automático',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                  ),
                ),
                subtitle: Text(
                  _getTimeRangeText(),
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: cs.onSurfaceVariant.withOpacity(0.7),
                  ),
                ),
                trailing: Switch(
                  value: _isAutomaticTheme,
                  onChanged: (value) {
                    setState(() => _isAutomaticTheme = value);
                    widget.onAutomaticThemeChanged(value);
                    
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
          ),
          const SizedBox(height: 14),
          // Tema Manual Premium
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Container(
              decoration: BoxDecoration(
                color: cs.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: cs.outlineVariant.withOpacity(0.2),
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.03),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                leading: Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        (_isAutomaticTheme ? cs.outlineVariant : cs.primary).withOpacity(0.15),
                        (_isAutomaticTheme ? cs.outlineVariant : cs.primary).withOpacity(0.05),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: (_isAutomaticTheme ? cs.outlineVariant : cs.primary).withOpacity(0.2),
                      width: 1,
                    ),
                  ),
                  child: Icon(
                    isDark ? Icons.dark_mode_rounded : Icons.light_mode_rounded,
                    color: _isAutomaticTheme ? cs.outline : cs.primary,
                    size: 22,
                  ),
                ),
                title: Text(
                  'Tema oscuro',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                    color: _isAutomaticTheme ? cs.onSurfaceVariant.withOpacity(0.5) : null,
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
          ),
          const SizedBox(height: 28),
          // Sección de Notificaciones
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              'Notificaciones',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.2,
              ),
            ),
          ),
          const SizedBox(height: 14),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Container(
              decoration: BoxDecoration(
                color: cs.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: cs.outlineVariant.withOpacity(0.2),
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.03),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                leading: Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        cs.primary.withOpacity(0.15),
                        cs.primary.withOpacity(0.05),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: cs.primary.withOpacity(0.2),
                      width: 1,
                    ),
                  ),
                  child: Icon(
                    Icons.notifications_rounded,
                    color: cs.primary,
                    size: 22,
                  ),
                ),
                title: const Text(
                  'Habilitar notificaciones',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                  ),
                ),
                trailing: Switch(
                  value: _notificationsEnabled,
                  onChanged: (value) {
                    setState(() => _notificationsEnabled = value);
                  },
                ),
              ),
            ),
          ),
          const SizedBox(height: 28),
          // Sección de Configuración
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              'Configuración',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.2,
              ),
            ),
          ),
          const SizedBox(height: 14),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Container(
              decoration: BoxDecoration(
                color: cs.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: cs.outlineVariant.withOpacity(0.2),
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.03),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                leading: Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        cs.primary.withOpacity(0.15),
                        cs.primary.withOpacity(0.05),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: cs.primary.withOpacity(0.2),
                      width: 1,
                    ),
                  ),
                  child: Icon(
                    Icons.currency_exchange_rounded,
                    color: cs.primary,
                    size: 22,
                  ),
                ),
                title: const Text(
                  'Moneda',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                  ),
                ),
                trailing: DropdownButton<String>(
                  value: _selectedCurrency,
                  underline: const SizedBox(),
                  dropdownColor: cs.surface,
                  items: const [
                    DropdownMenuItem(value: 'USD', child: Text('USD')),
                    DropdownMenuItem(value: 'EUR', child: Text('EUR')),
                    DropdownMenuItem(value: 'PEN', child: Text('S/ PEN')),
                    DropdownMenuItem(value: 'MXN', child: Text('MXN')),
                  ],
                  onChanged: (value) {
                    setState(() => _selectedCurrency = value ?? 'PEN');
                  },
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                    color: cs.primary,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 28),
          // Sección de Información
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              'Información',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.2,
              ),
            ),
          ),
          const SizedBox(height: 14),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Container(
              decoration: BoxDecoration(
                color: cs.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: cs.outlineVariant.withOpacity(0.2),
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.03),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                leading: Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        cs.primary.withOpacity(0.15),
                        cs.primary.withOpacity(0.05),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: cs.primary.withOpacity(0.2),
                      width: 1,
                    ),
                  ),
                  child: Icon(
                    Icons.info_outline_rounded,
                    color: cs.primary,
                    size: 22,
                  ),
                ),
                title: const Text(
                  'Versión',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                  ),
                ),
                trailing: Text(
                  '1.0.0',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    color: cs.primary,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 14),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Container(
              decoration: BoxDecoration(
                color: cs.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: cs.outlineVariant.withOpacity(0.2),
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.03),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                leading: Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        cs.primary.withOpacity(0.15),
                        cs.primary.withOpacity(0.05),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: cs.primary.withOpacity(0.2),
                      width: 1,
                    ),
                  ),
                  child: Icon(
                    Icons.help_outline_rounded,
                    color: cs.primary,
                    size: 22,
                  ),
                ),
                title: const Text(
                  'Acerca de',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                  ),
                ),
                trailing: Icon(
                  Icons.arrow_forward_rounded,
                  color: cs.primary.withOpacity(0.5),
                  size: 20,
                ),
                onTap: () => _showAboutDialog(context),
              ),
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}