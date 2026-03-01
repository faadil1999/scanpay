import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:scanpay_benin/domain/models/transaction.dart';

class TransactionService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Effectuer un paiement atomique
  Future<bool> processPayment({
    required String userId,
    required String merchantId,
    required double amount,
  }) async {
    final userRef = _db.collection('users').doc(userId);
    final merchantRef = _db.collection('merchants').doc(merchantId);
    final transactionRef = _db.collection('transactions').doc();

    try {
      await _db.runTransaction((transaction) async {
        final userDoc = await transaction.get(userRef);
        
        if (!userDoc.exists) throw Exception("Utilisateur non trouvé");
        
        double currentBalance = userDoc.data()?['balance'] ?? 0.0;
        if (currentBalance < amount) throw Exception("Solde insuffisant");

        // 1. Débiter l'utilisateur
        transaction.update(userRef, {'balance': currentBalance - amount});

        // 2. Créditer le marchand
        final merchantDoc = await transaction.get(merchantRef);
        double merchantBalance = merchantDoc.data()?['balance'] ?? 0.0;
        transaction.update(merchantRef, {'balance': merchantBalance + amount});

        // 3. Enregistrer la transaction
        transaction.set(transactionRef, {
          'userId': userId,
          'merchantId': merchantId,
          'amount': amount,
          'status': 'success',
          'timestamp': FieldValue.serverTimestamp(),
        });
      });
      return true;
    } catch (e) {
      print("Erreur de transaction: $e");
      return false;
    }
  }

  // Flux de transactions en temps réel
  Stream<List<TransactionModel>> getTransactions(String id, bool isMerchant) {
    String field = isMerchant ? 'merchantId' : 'userId';
    return _db
        .collection('transactions')
        .where(field, isEqualTo: id)
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => TransactionModel.fromFirestore(doc))
            .toList());
  }
}
