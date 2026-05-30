class TransactionModel {
  final String id;
  final String merchantId;
  final String userId;
  final double amount;
  final DateTime timestamp;
  final String status;

  TransactionModel({
    required this.id,
    required this.merchantId,
    required this.userId,
    required this.amount,
    required this.timestamp,
    required this.status,
  });

  factory TransactionModel.fromMap(String id, Map<String, dynamic> data) {
    return TransactionModel(
      id: id,
      merchantId: data['merchantId'] ?? '',
      userId: data['userId'] ?? '',
      amount: (data['amount'] ?? 0).toDouble(),
      timestamp: data['timestamp'] != null
          ? DateTime.parse(data['timestamp'] as String)
          : DateTime.now(),
      status: data['status'] ?? 'pending',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'merchantId': merchantId,
      'userId': userId,
      'amount': amount,
      'timestamp': timestamp.toIso8601String(),
      'status': status,
    };
  }
}
