// lib/models/badge_model.dart
class Badge {
  final String id;
  final String name;
  final String description;
  final String icon;
  final bool isUnlocked;
  final DateTime? unlockedDate;
  final String category; // ej: 'savings', 'spending', 'investment'
  final int requiredAmount; // Cantidad requerida para desbloquear

  Badge({
    required this.id,
    required this.name,
    required this.description,
    required this.icon,
    this.isUnlocked = false,
    this.unlockedDate,
    required this.category,
    required this.requiredAmount,
  });

  // Constructor desde JSON
  factory Badge.fromJson(Map<String, dynamic> json) {
    return Badge(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      icon: json['icon'],
      isUnlocked: json['isUnlocked'] ?? false,
      unlockedDate: json['unlockedDate'] != null 
          ? DateTime.parse(json['unlockedDate']) 
          : null,
      category: json['category'],
      requiredAmount: json['requiredAmount'],
    );
  }

  // Convertir a JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'icon': icon,
      'isUnlocked': isUnlocked,
      'unlockedDate': unlockedDate?.toIso8601String(),
      'category': category,
      'requiredAmount': requiredAmount,
    };
  }

  // Método para copiar con cambios
  Badge copyWith({
    String? id,
    String? name,
    String? description,
    String? icon,
    bool? isUnlocked,
    DateTime? unlockedDate,
    String? category,
    int? requiredAmount,
  }) {
    return Badge(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      icon: icon ?? this.icon,
      isUnlocked: isUnlocked ?? this.isUnlocked,
      unlockedDate: unlockedDate ?? this.unlockedDate,
      category: category ?? this.category,
      requiredAmount: requiredAmount ?? this.requiredAmount,
    );
  }
}