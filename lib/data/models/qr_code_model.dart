// ignore_for_file: constant_identifier_names
enum QrCodeStatus { pending, scanned, completed, expired, cancelled }
enum QrCodeCurrency { XOF, EUR, USD }

class QrCodeModel {
  final String id;
  final String merchantId;
  final String? walletId;
  final double amount;
  final QrCodeCurrency currency;
  final String reference;
  final String qrData;
  final String? qrImage;
  final QrCodeStatus status;
  final String? description;
  final int expiresInMinutes;
  final DateTime expiresAt;
  final DateTime? scannedAt;
  final DateTime? completedAt;
  final DateTime createdAt;
  final DateTime updatedAt;

  bool get isExpired => DateTime.now().isAfter(expiresAt);
  bool get isActive => status == QrCodeStatus.pending && !isExpired;
  Duration get remainingTime => expiresAt.difference(DateTime.now());
  String get formattedAmount => '${amount.toStringAsFixed(0)} ${currency.name}';

  String get statusLabel {
    switch (status) {
      case QrCodeStatus.pending:
        return 'En attente';
      case QrCodeStatus.scanned:
        return 'Scanné';
      case QrCodeStatus.completed:
        return 'Payé';
      case QrCodeStatus.expired:
        return 'Expiré';
      case QrCodeStatus.cancelled:
        return 'Annulé';
    }
  }

  const QrCodeModel({
    required this.id,
    required this.merchantId,
    this.walletId,
    required this.amount,
    required this.currency,
    required this.reference,
    required this.qrData,
    this.qrImage,
    required this.status,
    this.description,
    required this.expiresInMinutes,
    required this.expiresAt,
    this.scannedAt,
    this.completedAt,
    required this.createdAt,
    required this.updatedAt,
  });

  factory QrCodeModel.fromJson(Map<String, dynamic> json) {
    return QrCodeModel(
      id: json['id'],
      merchantId: json['merchantId'],
      walletId: json['walletId'],
      amount: double.tryParse(json['amount'].toString()) ?? 0.0,
      currency: QrCodeCurrency.values.firstWhere(
        (e) => e.name == json['currency'],
        orElse: () => QrCodeCurrency.XOF,
      ),
      reference: json['reference'],
      qrData: json['qrData'],
      qrImage: json['qrImage'],
      status: QrCodeStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => QrCodeStatus.pending,
      ),
      description: json['description'],
      expiresInMinutes: json['expiresInMinutes'] ?? 15,
      expiresAt: DateTime.parse(json['expiresAt']),
      scannedAt:
          json['scannedAt'] != null ? DateTime.parse(json['scannedAt']) : null,
      completedAt: json['completedAt'] != null
          ? DateTime.parse(json['completedAt'])
          : null,
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'merchantId': merchantId,
    'walletId': walletId,
    'amount': amount,
    'currency': currency.name,
    'reference': reference,
    'qrData': qrData,
    'qrImage': qrImage,
    'status': status.name,
    'description': description,
    'expiresInMinutes': expiresInMinutes,
    'expiresAt': expiresAt.toIso8601String(),
    'scannedAt': scannedAt?.toIso8601String(),
    'completedAt': completedAt?.toIso8601String(),
    'createdAt': createdAt.toIso8601String(),
    'updatedAt': updatedAt.toIso8601String(),
  };
}
