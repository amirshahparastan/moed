class Loan {
  final int? id;
  final String title;
  final String type;
  final String lender;
  final int totalAmount;
  final int installmentAmount;
  final int installmentCount;
  final DateTime startDate;
  final String frequency;
  final int frequencyValue;
  final String notes;
  final int colorIndex;
  final bool isCompleted;
  final DateTime createdAt;

  const Loan({
    this.id,
    required this.title,
    required this.type,
    required this.lender,
    required this.totalAmount,
    required this.installmentAmount,
    required this.installmentCount,
    required this.startDate,
    required this.frequency,
    required this.frequencyValue,
    required this.notes,
    required this.colorIndex,
    required this.isCompleted,
    required this.createdAt,
  });

  Map<String, Object?> toMap() => {
    'id': id,
    'title': title,
    'type': type,
    'lender': lender,
    'total_amount': totalAmount,
    'installment_amount': installmentAmount,
    'installment_count': installmentCount,
    'start_date': startDate.toIso8601String(),
    'frequency': frequency,
    'frequency_value': frequencyValue,
    'notes': notes,
    'color_index': colorIndex,
    'is_completed': isCompleted ? 1 : 0,
    'created_at': createdAt.toIso8601String(),
  };

  factory Loan.fromMap(Map<String, Object?> m) => Loan(
    id: m['id'] as int?,
    title: m['title'] as String,
    type: m['type'] as String,
    lender: (m['lender'] as String?) ?? '',
    totalAmount: m['total_amount'] as int,
    installmentAmount: m['installment_amount'] as int,
    installmentCount: m['installment_count'] as int,
    startDate: DateTime.parse(m['start_date'] as String),
    frequency: (m['frequency'] as String?) ?? 'monthly',
    frequencyValue: (m['frequency_value'] as int?) ?? 1,
    notes: (m['notes'] as String?) ?? '',
    colorIndex: (m['color_index'] as int?) ?? 0,
    isCompleted: (m['is_completed'] as int? ?? 0) == 1,
    createdAt: DateTime.parse(m['created_at'] as String),
  );

  Loan copyWith({bool? isCompleted}) => Loan(
    id: id, title: title, type: type, lender: lender, totalAmount: totalAmount,
    installmentAmount: installmentAmount, installmentCount: installmentCount,
    startDate: startDate, frequency: frequency, frequencyValue: frequencyValue,
    notes: notes, colorIndex: colorIndex,
    isCompleted: isCompleted ?? this.isCompleted, createdAt: createdAt,
  );
}
