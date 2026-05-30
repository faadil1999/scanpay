class MerchantStats {
  final double totalRevenue;
  final int todayTransactions;
  final int successfulTransactions;

  String get formattedRevenue => '${totalRevenue.toStringAsFixed(0)} XOF';

  const MerchantStats({
    required this.totalRevenue,
    required this.todayTransactions,
    required this.successfulTransactions,
  });

  factory MerchantStats.fromJson(Map<String, dynamic> json) {
    return MerchantStats(
      totalRevenue: double.tryParse(json['totalRevenue'].toString()) ?? 0.0,
      todayTransactions: json['todayTransactions'] ?? 0,
      successfulTransactions: json['successfulTransactions'] ?? 0,
    );
  }
}
