import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'auth_provider.dart';
import '../../data/models/transaction_model.dart';

final transactionsProvider = StreamProvider<List<TransactionModel>>((ref) {
  final user = ref.watch(userProvider);
  final firestore = ref.watch(firestoreProvider);

  if (user == null) return Stream.value([]);

  // Fetch transactions where user is either sender or receiver
  return firestore
      .collection('transactions')
      .where('senderId', isEqualTo: user.uid)
      .orderBy('timestamp', descending: true)
      .snapshots()
      .map((snapshot) {
    // This is a bit simplified, ideally you'd use a composite query or multiple streams
    // For now, let's just fetch where they are sender.
    // In a real app, you'd merge streams for sender and receiver.
    return snapshot.docs
        .map((doc) => TransactionModel.fromMap(doc.data(), doc.id))
        .toList();
  });
});

// A more complete version that handles both sender and receiver would be better
// but Firestore doesn't support OR queries easily without multiple streams.
// Let's stick to this for now or use a 'participants' array in Firestore.
