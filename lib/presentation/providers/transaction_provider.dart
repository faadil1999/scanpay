import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/transaction_model.dart';
import '../../data/models/merchant_stats_model.dart';
import 'auth_provider.dart';

final transactionsProvider = FutureProvider<List<TransactionModel>>((ref) async {
  final api = ref.watch(apiServiceProvider);
  final user = ref.watch(userProvider);
  if (user == null) return [];
  final json = await api.get('/transactions') as List;
  return json.map((e) => TransactionModel.fromJson(e)).toList();
});

final merchantStatsProvider = FutureProvider<MerchantStats>((ref) async {
  final api = ref.watch(apiServiceProvider);
  final json = await api.get('/transactions/stats');
  return MerchantStats.fromJson(json);
});
