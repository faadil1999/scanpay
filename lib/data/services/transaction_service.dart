import 'package:flutter/foundation.dart';
import 'package:scanpay_benin/domain/models/transaction.dart';

class TransactionService {
  // Process a payment between a user and a merchant.
  Future<bool> processPayment({
    required String userId,
    required String merchantId,
    required double amount,
  }) async {
    try {
      // TODO: replace with actual API call
      debugPrint("Processing payment: $userId -> $merchantId : $amount");
      return true;
    } catch (e) {
      debugPrint("Erreur de transaction: $e");
      return false;
    }
  }

  // Returns a stream of transactions for a given user or merchant.
  Stream<List<TransactionModel>> getTransactions(String id, bool isMerchant) {
    // TODO: replace with actual API / local DB stream
    return Stream.value([]);
  }
}
