class Payment {
  final int? id;
  final int installmentId;
  final int amount;
  final DateTime paidAt;
  final String note;

  const Payment({this.id, required this.installmentId, required this.amount, required this.paidAt, required this.note});

  Map<String, Object?> toMap() => {
    'id': id,
    'installment_id': installmentId,
    'amount': amount,
    'paid_at': paidAt.toIso8601String(),
    'note': note,
  };

  factory Payment.fromMap(Map<String, Object?> m) => Payment(
    id: m['id'] as int?, installmentId: m['installment_id'] as int,
    amount: m['amount'] as int, paidAt: DateTime.parse(m['paid_at'] as String),
    note: (m['note'] as String?) ?? '',
  );
}
