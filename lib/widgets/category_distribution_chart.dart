import 'package:flutter/material.dart';
import '../utils/formatters.dart';

class CategoryDistributionChart extends StatelessWidget {
  final Map<String, double> data;
  
  const CategoryDistributionChart({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    final total = data.values.fold<double>(0, (a, b) => a + b);
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    final colors = [
      cs.primary,
      cs.secondary,
      const Color(0xFF26C6DA),
      const Color(0xFF66BB6A),
      const Color(0xFFFF7043),
      const Color(0xFFAB47BC),
    ];

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? [
                  const Color(0xFF1C1C1E),
                  const Color(0xFF2C2C2E),
                ]
              : [
                  Colors.white,
                  const Color(0xFFF5F5F7),
                ],
        ),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withOpacity(0.3)
                : Colors.black.withOpacity(0.06),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Título con estilo Apple
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        cs.primary.withOpacity(0.2),
                        cs.primary.withOpacity(0.1),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    Icons.pie_chart_rounded,
                    size: 20,
                    color: cs.primary,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  'Distribución por categorías',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white.withOpacity(0.95) : Colors.black87,
                    letterSpacing: -0.5,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            
            // Lista de categorías
            ...data.entries.toList().asMap().entries.map((mapEntry) {
              final i = mapEntry.key;
              final entry = mapEntry.value;
              final name = entry.key;
              final value = entry.value;
              final pctVal = total == 0 ? 0.0 : value / total;
              final color = colors[i % colors.length];

              return Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Fila superior: indicador + nombre + valor
                    Row(
                      children: [
                        // Indicador de color con glow
                        Container(
                          width: 12,
                          height: 12,
                          decoration: BoxDecoration(
                            color: color,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: color.withOpacity(0.5),
                                blurRadius: 6,
                                spreadRadius: 1,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        
                        // Nombre de la categoría
                        Expanded(
                          child: Text(
                            name,
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w500,
                              color: isDark 
                                  ? Colors.white.withOpacity(0.9)
                                  : Colors.black87,
                              letterSpacing: -0.3,
                            ),
                          ),
                        ),
                        
                        // Porcentaje
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: color.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            '${(pctVal * 100).toStringAsFixed(1)}%',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: color,
                              letterSpacing: -0.2,
                            ),
                          ),
                        ),
                        
                        const SizedBox(width: 12),
                        
                        // Valor monetario
                        Text(
                          money(value),
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: isDark
                                ? Colors.white.withOpacity(0.95)
                                : Colors.black87,
                            letterSpacing: -0.3,
                          ),
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 10),
                    
                    // Barra de progreso estilo Apple
                    Container(
                      height: 6,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(3),
                        color: isDark
                            ? Colors.white.withOpacity(0.08)
                            : Colors.black.withOpacity(0.06),
                      ),
                      child: FractionallySizedBox(
                        alignment: Alignment.centerLeft,
                        widthFactor: pctVal.clamp(0.0, 1.0),
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(3),
                            gradient: LinearGradient(
                              colors: [
                                color,
                                color.withOpacity(0.7),
                              ],
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: color.withOpacity(0.4),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}