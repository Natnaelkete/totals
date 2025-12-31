class Budget {
  final int? id;
  final String name;
  final String type; // 'daily', 'monthly', 'yearly', 'category'
  final double amount;
  final int? categoryId;
  final DateTime startDate;
  final DateTime? endDate;
  final bool rollover;
  final double alertThreshold; // 0-100 percentage
  final bool isActive;
  final DateTime createdAt;
  final DateTime? updatedAt;

  Budget({
    this.id,
    required this.name,
    required this.type,
    required this.amount,
    this.categoryId,
    required this.startDate,
    this.endDate,
    this.rollover = false,
    this.alertThreshold = 80.0,
    this.isActive = true,
    required this.createdAt,
    this.updatedAt,
  });

  factory Budget.fromDb(Map<String, dynamic> row) {
    return Budget(
      id: row['id'] as int?,
      name: (row['name'] as String?) ?? '',
      type: (row['type'] as String?) ?? 'monthly',
      amount: (row['amount'] as num?)?.toDouble() ?? 0.0,
      categoryId: row['categoryId'] as int?,
      startDate: row['startDate'] != null
          ? DateTime.parse(row['startDate'] as String)
          : DateTime.now(),
      endDate: row['endDate'] != null
          ? DateTime.parse(row['endDate'] as String)
          : null,
      rollover: (row['rollover'] as int? ?? 0) == 1,
      alertThreshold: (row['alertThreshold'] as num?)?.toDouble() ?? 80.0,
      isActive: (row['isActive'] as int? ?? 1) == 1,
      createdAt: row['createdAt'] != null
          ? DateTime.parse(row['createdAt'] as String)
          : DateTime.now(),
      updatedAt: row['updatedAt'] != null
          ? DateTime.parse(row['updatedAt'] as String)
          : null,
    );
  }

  Map<String, dynamic> toDb() {
    return {
      'id': id,
      'name': name,
      'type': type,
      'amount': amount,
      'categoryId': categoryId,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate?.toIso8601String(),
      'rollover': rollover ? 1 : 0,
      'alertThreshold': alertThreshold,
      'isActive': isActive ? 1 : 0,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  Budget copyWith({
    int? id,
    String? name,
    String? type,
    double? amount,
    int? categoryId,
    DateTime? startDate,
    DateTime? endDate,
    bool? rollover,
    double? alertThreshold,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Budget(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      amount: amount ?? this.amount,
      categoryId: categoryId ?? this.categoryId,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      rollover: rollover ?? this.rollover,
      alertThreshold: alertThreshold ?? this.alertThreshold,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  // Helper methods for period calculations
  DateTime getCurrentPeriodStart() {
    final now = DateTime.now();
    switch (type) {
      case 'daily':
        return DateTime(now.year, now.month, now.day);
      case 'monthly':
        return DateTime(now.year, now.month, 1);
      case 'yearly':
        return DateTime(now.year, 1, 1);
      case 'category':
        // For category budgets, use monthly by default
        return DateTime(now.year, now.month, 1);
      default:
        return DateTime(now.year, now.month, 1);
    }
  }

  DateTime getCurrentPeriodEnd() {
    final start = getCurrentPeriodStart();
    switch (type) {
      case 'daily':
        return DateTime(start.year, start.month, start.day, 23, 59, 59);
      case 'monthly':
        final nextMonth = DateTime(start.year, start.month + 1, 1);
        return nextMonth.subtract(const Duration(seconds: 1));
      case 'yearly':
        return DateTime(start.year, 12, 31, 23, 59, 59);
      case 'category':
        final nextMonth = DateTime(start.year, start.month + 1, 1);
        return nextMonth.subtract(const Duration(seconds: 1));
      default:
        final nextMonth = DateTime(start.year, start.month + 1, 1);
        return nextMonth.subtract(const Duration(seconds: 1));
    }
  }

  bool isDateInCurrentPeriod(DateTime date) {
    final start = getCurrentPeriodStart();
    final end = getCurrentPeriodEnd();
    return !date.isBefore(start) && !date.isAfter(end);
  }
}
