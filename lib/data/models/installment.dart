class Installment {
  final int? id;
  final int loanId;
  final int sequence;
  final DateTime dueDate;
  final int amount;
  final int paidAmount;
  final String status;
  final DateTime? paidAt;

  const Installment({
    this.id,
    required this.loanId,
    required this.sequence,
    required this.dueDate,
    required this.amount,
    required this.paidAmount,
    required this.status,
    this.paidAt,
  });

  int get remaining => (amount - paidAmount).clamp(0, amount).toInt();
  bool get isPaid => status == 'paid';
  bool get isOverdue => !isPaid && dueDate.isBefore(DateTime.now());

  Map<String, Object?> toMap() => {
    'id': id,
    'loan_id': loanId,
    'sequence': sequence,
    'due_date': dueDate.toIso8601String(),
    'amount': amount,
    'paid_amount': paidAmount,
    'status': status,
    'paid_at': paidAt?.toIso8601String(),
  };

  factory Installment.fromMap(Map<String, Object?> m) => Installment(
    id: m['id'] as int?,
    loanId: m['loan_id'] as int,
    sequence: m['sequence'] as int,
    dueDate: DateTime.parse(m['due_date'] as String),
    amount: m['amount'] as int,
    paidAmount: (m['paid_amount'] as int?) ?? 0,
    status: (m['status'] as String?) ?? 'pending',
    paidAt: m['paid_at'] == null ? null : DateTime.parse(m['paid_at'] as String),
  );
}
