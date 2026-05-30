import 'wallet_model.dart';
import 'qr_code_model.dart';

enum TransactionStatus { pending, processing, success, failed, refunded }
enum TransactionType { payment, refund }

class TransactionModel {
  final String id;
  final String? qrCodeId;
  final String? senderId;
  final String? receiverId;
  final String? senderWalletId;
  final String? receiverWalletId;
  final double amount;
  final double fees;
  final double amountReceived;
  final String currency;
  final TransactionStatus status;
  final TransactionType type;
  final String reference;
  final String? externalReference;
  final String? provider;
  final String? failureReason;
  final DateTime? completedAt;
  final DateTime createdAt;
  final DateTime updatedAt;
  final WalletModel? senderWallet;
  final WalletModel? receiverWallet;
  final QrCodeModel? qrCode;

  String get formattedAmount => '${amount.toStringAsFixed(0)} $currency';
  String get formattedFees => '${fees.toStringAsFixed(0)} $currency';
  String get formattedAmountReceived =>
      '${amountReceived.toStringAsFixed(0)} $currency';

  bool get isSuccess => status == TransactionStatus.success;
  bool get isFailed => status == TransactionStatus.failed;
  bool get isPending =>
      status == TransactionStatus.pending ||
      status == TransactionStatus.processing;

  String get statusLabel {
    switch (status) {
      case TransactionStatus.pending:
        return 'En attente';
      case TransactionStatus.processing:
        return 'En cours';
      case TransactionStatus.success:
        return 'Réussi';
      case TransactionStatus.failed:
        return 'Échoué';
      case TransactionStatus.refunded:
        return 'Remboursé';
    }
  }

  const TransactionModel({
    required this.id,
    this.qrCodeId,
    this.senderId,
    this.receiverId,
    this.senderWalletId,
    this.receiverWalletId,
    required this.amount,
    required this.fees,
    required this.amountReceived,
    required this.currency,
    required this.status,
    required this.type,
    required this.reference,
    this.externalReference,
    this.provider,
    this.failureReason,
    this.completedAt,
    required this.createdAt,
    required this.updatedAt,
    this.senderWallet,
    this.receiverWallet,
    this.qrCode,
  });

  factory TransactionModel.fromJson(Map<String, dynamic> json) {
    return TransactionModel(
      id: json['id'],
      qrCodeId: json['qrCodeId'],
      senderId: json['senderId'],
      receiverId: json['receiverId'],
      senderWalletId: json['senderWalletId'],
      receiverWalletId: json['receiverWalletId'],
      amount: double.tryParse(json['amount'].toString()) ?? 0.0,
      fees: double.tryParse(json['fees'].toString()) ?? 0.0,
      amountReceived:
          double.tryParse(json['amountReceived'].toString()) ?? 0.0,
      currency: json['currency'] ?? 'XOF',
      status: TransactionStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => TransactionStatus.pending,
      ),
      type: TransactionType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => TransactionType.payment,
      ),
      reference: json['reference'],
      externalReference: json['externalReference'],
      provider: json['provider'],
      failureReason: json['failureReason'],
      completedAt: json['completedAt'] != null
          ? DateTime.parse(json['completedAt'])
          : null,
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
      senderWallet: json['senderWallet'] != null
          ? WalletModel.fromJson(json['senderWallet'])
          : null,
      receiverWallet: json['receiverWallet'] != null
          ? WalletModel.fromJson(json['receiverWallet'])
          : null,
      qrCode:
          json['qrCode'] != null ? QrCodeModel.fromJson(json['qrCode']) : null,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'qrCodeId': qrCodeId,
    'senderId': senderId,
    'receiverId': receiverId,
    'senderWalletId': senderWalletId,
    'receiverWalletId': receiverWalletId,
    'amount': amount,
    'fees': fees,
    'amountReceived': amountReceived,
    'currency': currency,
    'status': status.name,
    'type': type.name,
    'reference': reference,
    'externalReference': externalReference,
    'provider': provider,
    'failureReason': failureReason,
    'completedAt': completedAt?.toIso8601String(),
    'createdAt': createdAt.toIso8601String(),
    'updatedAt': updatedAt.toIso8601String(),
  };
}
