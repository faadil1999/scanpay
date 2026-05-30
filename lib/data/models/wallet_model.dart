// ignore_for_file: constant_identifier_names
enum WalletProvider { mtn_momo, moov_money, celtiis_cash }
enum WalletCurrency { XOF, EUR, USD }
enum WalletStatus { active, suspended }

class WalletModel {
  final String id;
  final String userId;
  final WalletProvider provider;
  final String phoneNumber;
  final WalletCurrency currency;
  final double balance;
  final bool isDefault;
  final WalletStatus status;
  final DateTime createdAt;
  final DateTime updatedAt;

  String get providerName {
    switch (provider) {
      case WalletProvider.mtn_momo:
        return 'MTN Mobile Money';
      case WalletProvider.moov_money:
        return 'Moov Money';
      case WalletProvider.celtiis_cash:
        return 'Celtiis Cash';
    }
  }

  String get formattedBalance => '${balance.toStringAsFixed(0)} ${currency.name}';

  const WalletModel({
    required this.id,
    required this.userId,
    required this.provider,
    required this.phoneNumber,
    required this.currency,
    required this.balance,
    required this.isDefault,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
  });

  factory WalletModel.fromJson(Map<String, dynamic> json) {
    return WalletModel(
      id: json['id'],
      userId: json['userId'],
      provider: WalletProvider.values.firstWhere(
        (e) => e.name == json['provider'],
        orElse: () => WalletProvider.mtn_momo,
      ),
      phoneNumber: json['phoneNumber'],
      currency: WalletCurrency.values.firstWhere(
        (e) => e.name == json['currency'],
        orElse: () => WalletCurrency.XOF,
      ),
      balance: double.tryParse(json['balance'].toString()) ?? 0.0,
      isDefault: json['isDefault'] ?? false,
      status: WalletStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => WalletStatus.active,
      ),
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'userId': userId,
    'provider': provider.name,
    'phoneNumber': phoneNumber,
    'currency': currency.name,
    'balance': balance,
    'isDefault': isDefault,
    'status': status.name,
    'createdAt': createdAt.toIso8601String(),
    'updatedAt': updatedAt.toIso8601String(),
  };
}
