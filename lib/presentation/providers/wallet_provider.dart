import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/wallet_model.dart';
import 'auth_provider.dart';

final walletsProvider = FutureProvider<List<WalletModel>>((ref) async {
  final api = ref.watch(apiServiceProvider);
  final user = ref.watch(userProvider);
  if (user == null) return [];
  final json = await api.get('/wallets') as List;
  return json.map((e) => WalletModel.fromJson(e)).toList();
});

final defaultWalletProvider = FutureProvider<WalletModel?>((ref) async {
  final wallets = await ref.watch(walletsProvider.future);
  if (wallets.isEmpty) return null;
  return wallets.firstWhere((w) => w.isDefault, orElse: () => wallets.first);
});
