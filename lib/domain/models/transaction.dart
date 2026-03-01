import 'package:cloud_firestore/cloud_firestore.dart';

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

  factory TransactionModel.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map;
    return TransactionModel(
      id: doc.id,
      merchantId: data['merchantId'] ?? '',
      userId: data['userId'] ?? '',
      amount: (data['amount'] ?? 0).toDouble(),
      timestamp: (data['timestamp'] as Timestamp).toDate(),
      status: data['status'] ?? 'pending',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'merchantId': merchantId,
      'userId': userId,
      'amount': amount,
      'timestamp': FieldValue.serverTimestamp(),
      'status': status,
    };
  }
}
