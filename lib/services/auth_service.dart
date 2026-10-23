import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

enum Role { customer, owner, rider }

class Session {
  final Role role;
  final String uid;
  final String name;
  const Session(this.role, this.uid, this.name);
}

/// Logins. Customers are signed in automatically without an account; the
/// owner and delivery staff log in with an email and password.
class AuthService {
  final FirebaseAuth auth;
  final FirebaseFirestore db;
  AuthService(this.auth, this.db);

  Future<Session> start() async {
    final user = auth.currentUser ?? (await auth.signInAnonymously()).user!;
    return _sessionFor(user);
  }

  Future<Session> _sessionFor(User user) async {
    if (user.isAnonymous) return Session(Role.customer, user.uid, '');
    final data = (await db.collection('users').doc(user.uid).get()).data() ?? {};
    final name = data['name'] as String? ?? '';
    switch (data['role']) {
      case 'owner':
        return Session(Role.owner, user.uid, name);
      case 'rider':
        return Session(Role.rider, user.uid, name);
      default:
        await auth.signOut();
        throw const AuthMessage('This account is not set up as store staff. Ask the owner to add you.');
    }
  }

  Future<Session> signIn(String email, String password) async {
    try {
      final cred = await auth.signInWithEmailAndPassword(email: email.trim(), password: password);
      return await _sessionFor(cred.user!);
    } on FirebaseAuthException catch (e) {
      throw AuthMessage(_explain(e));
    }
  }

  /// True once someone has set up the owner account for this store.
  Future<bool> storeHasOwner() async => (await db.doc('config/store').get()).exists;

  /// Creates the owner account. Only works once per store; the security
  /// rules refuse a second owner.
  Future<Session> setUpOwner(String name, String email, String password) async {
    try {
      final cred = await auth.createUserWithEmailAndPassword(email: email.trim(), password: password);
      final uid = cred.user!.uid;
      final batch = db.batch()
        ..set(db.doc('config/store'), {'ownerUid': uid})
        ..set(db.doc('users/$uid'), {'role': 'owner', 'name': name, 'email': email.trim()});
      await batch.commit();
      return Session(Role.owner, uid, name);
    } on FirebaseAuthException catch (e) {
      throw AuthMessage(_explain(e));
    }
  }

  Future<Session> signOut() async {
    await auth.signOut();
    return start();
  }

  String _explain(FirebaseAuthException e) => switch (e.code) {
        'invalid-credential' || 'wrong-password' || 'user-not-found' => 'Wrong email or password.',
        'email-already-in-use' => 'That email already has an account. Log in instead.',
        'weak-password' => 'Use a password with at least 6 characters.',
        'invalid-email' => 'That email address doesn\'t look right.',
        'network-request-failed' => 'No internet connection. Try again.',
        _ => 'Couldn\'t log in (${e.code}). Try again.',
      };
}

/// A login problem to show the person as is.
class AuthMessage implements Exception {
  final String message;
  const AuthMessage(this.message);
  @override
  String toString() => message;
}
