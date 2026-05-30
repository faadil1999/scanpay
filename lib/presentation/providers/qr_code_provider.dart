import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/qr_code_model.dart';
import '../../data/services/api_service.dart';
import 'auth_provider.dart';

final qrCodesProvider = FutureProvider<List<QrCodeModel>>((ref) async {
  final api = ref.watch(apiServiceProvider);
  final user = ref.watch(userProvider);
  if (user == null) return [];
  final json = await api.get('/qrcodes') as List;
  return json.map((e) => QrCodeModel.fromJson(e)).toList();
});

class QrCodeNotifier extends StateNotifier<AsyncValue<QrCodeModel?>> {
  final ApiService _api;
  QrCodeNotifier(this._api) : super(const AsyncValue.data(null));

  Future<QrCodeModel> generate({
    required double amount,
    String? description,
    String? walletId,
    int expiresInMinutes = 15,
  }) async {
    state = const AsyncValue.loading();
    try {
      final body = <String, dynamic>{
        'amount': amount,
        'currency': 'XOF',
        'expiresInMinutes': expiresInMinutes,
        if (description != null && description.isNotEmpty) 'description': description,
        if (walletId != null) 'walletId': walletId,
      };
      final json = await _api.post('/qrcodes', body);
      final qr = QrCodeModel.fromJson(json);
      state = AsyncValue.data(qr);
      return qr;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }

  Future<QrCodeModel> scanByReference(String reference) async {
    final json = await _api.get('/qrcodes/scan/$reference');
    return QrCodeModel.fromJson(json);
  }

  void reset() => state = const AsyncValue.data(null);
}

final qrCodeNotifierProvider =
    StateNotifierProvider<QrCodeNotifier, AsyncValue<QrCodeModel?>>(
  (ref) => QrCodeNotifier(ref.watch(apiServiceProvider)),
);
