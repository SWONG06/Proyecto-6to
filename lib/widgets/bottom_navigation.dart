import 'package:flutter/material.dart';

class CustomBottomNavigation extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;
  
  const CustomBottomNavigation({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: isDark
            ? const Color(0xFF1C1C1E).withOpacity(0.95)
            : Colors.white.withOpacity(0.95),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withOpacity(0.3)
                : Colors.black.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
        border: Border(
          top: BorderSide(
            color: isDark
                ? Colors.white.withOpacity(0.1)
                : Colors.black.withOpacity(0.06),
            width: 0.5,
          ),
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _NavItem(
                icon: Icons.home_rounded,
                label: 'Inicio',
                isActive: currentIndex == 0,
                onTap: () => onTap(0),
                color: cs.primary,
                isDark: isDark,
              ),
              _NavItem(
                icon: Icons.add_circle_rounded,
                label: 'Agregar',
                isActive: currentIndex == 1,
                onTap: () => onTap(1),
                color: cs.primary,
                isDark: isDark,
                isCenter: true,
              ),
              _NavItem(
                icon: Icons.receipt_long_rounded,
                label: 'Transacciones',
                isActive: currentIndex == 2,
                onTap: () => onTap(2),
                color: cs.primary,
                isDark: isDark,
              ),
              _NavItem(
                icon: Icons.bar_chart_rounded,
                label: 'Reportes',
                isActive: currentIndex == 3,
                onTap: () => onTap(3),
                color: cs.primary,
                isDark: isDark,
              ),
              _NavItem(
                icon: Icons.person_rounded,
                label: 'Perfil',
                isActive: currentIndex == 4,
                onTap: () => onTap(4),
                color: cs.primary,
                isDark: isDark,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isActive;
  final VoidCallback onTap;
  final Color color;
  final bool isDark;
  final bool isCenter;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.isActive,
    required this.onTap,
    required this.color,
    required this.isDark,
    this.isCenter = false,
  });

  @override
  Widget build(BuildContext context) {
    final activeColor = color;
    final inactiveColor = isDark
        ? Colors.white.withOpacity(0.5)
        : Colors.black.withOpacity(0.4);

    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeInOut,
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Ícono con animación
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeInOut,
                padding: EdgeInsets.all(isCenter && isActive ? 4 : 0),
                decoration: BoxDecoration(
                  color: isActive
                      ? activeColor.withOpacity(0.12)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(isCenter ? 20 : 16),
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Glow effect cuando está activo
                    if (isActive)
                      Container(
                        width: isCenter ? 48 : 40,
                        height: isCenter ? 48 : 40,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: activeColor.withOpacity(0.3),
                              blurRadius: 12,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                      ),
                    
                    // Ícono
                    Icon(
                      icon,
                      size: isCenter ? 32 : 26,
                      color: isActive ? activeColor : inactiveColor,
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 4),
              
              // Label con animación
              AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeInOut,
                style: TextStyle(
                  fontSize: isActive ? 11 : 10,
                  fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
                  color: isActive ? activeColor : inactiveColor,
                  letterSpacing: -0.2,
                  height: 1.2,
                ),
                child: Text(
                  label,
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              
              // Indicador de punto activo
              const SizedBox(height: 2),
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeInOut,
                width: isActive ? 4 : 0,
                height: isActive ? 4 : 0,
                decoration: BoxDecoration(
                  color: activeColor,
                  shape: BoxShape.circle,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}