import 'package:cloud_firestore/cloud_firestore.dart';

class TransactionModel {
  final String id;
  final String senderId;
  final String receiverId;
  final String senderName;
  final String receiverName;
  final double amount;
  final String type; // 'payment', 'transfer', 'deposit'
  final DateTime timestamp;
  final String status; // 'completed', 'pending', 'failed'

  TransactionModel({
    required this.id,
    required this.senderId,
    required this.receiverId,
    required this.senderName,
    required this.receiverName,
    required this.amount,
    required this.type,
    required this.timestamp,
    required this.status,
  });

  factory TransactionModel.fromMap(Map<String, dynamic> map, String id) {
    return TransactionModel(
      id: id,
      senderId: map['senderId'] ?? '',
      receiverId: map['receiverId'] ?? '',
      senderName: map['senderName'] ?? '',
      receiverName: map['receiverName'] ?? '',
      amount: (map['amount'] ?? 0).toDouble(),
      type: map['type'] ?? 'payment',
      timestamp: (map['timestamp'] as Timestamp).toDate(),
      status: map['status'] ?? 'completed',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'senderId': senderId,
      'receiverId': receiverId,
      'senderName': senderName,
      'receiverName': receiverName,
      'amount': amount,
      'type': type,
      'timestamp': Timestamp.fromDate(timestamp),
      'status': status,
    };
  }
}
