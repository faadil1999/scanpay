import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/user_model.dart';

// Firebase instances
final firebaseAuthProvider = Provider<FirebaseAuth>((ref) => FirebaseAuth.instance);
final firestoreProvider = Provider<FirebaseFirestore>((ref) => FirebaseFirestore.instance);

// Auth state listener
final authStateProvider = StreamProvider<User?>((ref) {
  return ref.watch(firebaseAuthProvider).authStateChanges();
});

// Current user data provider
final userProvider = StateProvider<UserModel?>((ref) => null);

// Auth Controller
final authControllerProvider = Provider((ref) => AuthController(ref));

class AuthController {
  final Ref _ref;
  AuthController(this._ref);

  Future<void> register({
    required String email,
    required String password,
    required String name,
    required String phoneNumber,
    required bool asClient,
    required bool asMerchant,
  }) async {
    try {
      final auth = _ref.read(firebaseAuthProvider);
      final firestore = _ref.read(firestoreProvider);

      // 1. Create user in Firebase Auth
      final userCredential = await auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final uid = userCredential.user!.uid;

      // 2. Prepare roles
      List<String> roles = [];
      if (asClient) roles.add('client');
      if (asMerchant) roles.add('merchant');

      // 3. Create user document in Firestore
      final userModel = UserModel(
        uid: uid,
        email: email,
        name: name,
        phoneNumber: phoneNumber,
        balance: 0.0,
        roles: roles,
        createdAt: DateTime.now(),
      );

      await firestore.collection('users').doc(uid).set(userModel.toMap());

      // 4. Update local state
      _ref.read(userProvider.notifier).state = userModel;
    } catch (e) {
      rethrow;
    }
  }

  Future<void> login(String email, String password) async {
    try {
      final auth = _ref.read(firebaseAuthProvider);
      await auth.signInWithEmailAndPassword(email: email, password: password);
      await fetchUserData();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> fetchUserData() async {
    final auth = _ref.read(firebaseAuthProvider);
    final firestore = _ref.read(firestoreProvider);
    final user = auth.currentUser;

    if (user != null) {
      final doc = await firestore.collection('users').doc(user.uid).get();
      if (doc.exists) {
        _ref.read(userProvider.notifier).state = UserModel.fromMap(doc.data()!, doc.id);
      }
    }
  }

  Future<void> signOut() async {
    await _ref.read(firebaseAuthProvider).signOut();
    _ref.read(userProvider.notifier).state = null;
  }
}

// Toggle between Client and Merchant view if user has both roles
final isMerchantViewProvider = StateProvider<bool>((ref) => false);
