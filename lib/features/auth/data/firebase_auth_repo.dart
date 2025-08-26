import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:social_media_app/features/auth/domain/entities/app_user.dart';
import 'package:social_media_app/features/auth/domain/repos/auth_repo.dart';

class FirebaseAuthRepo implements AuthRepo {
  final FirebaseAuth firebaseAuth = FirebaseAuth.instance;
  final FirebaseFirestore firebaseFirestore = FirebaseFirestore.instance;

  @override
  Future<AppUser?> loginWithEmailPassword(String email, String password) async {
    try {
      UserCredential userCredential = await firebaseAuth
          .signInWithEmailAndPassword(email: email, password: password);

      final String uid = userCredential.user!.uid;

      // Read from the correct collection and handle missing docs
      DocumentSnapshot<Map<String, dynamic>> userDoc =
          await firebaseFirestore.collection('users').doc(uid).get();

      String resolvedName;
      if (userDoc.exists) {
        final data = userDoc.data();
        resolvedName = (data != null && data['name'] is String)
            ? data['name'] as String
            : '';
      } else {
        // Fallback: try Firebase displayName or email prefix
        final displayName = userCredential.user!.displayName;
        resolvedName = displayName ?? email.split('@').first;
        // Optionally create the missing user document to keep data consistent
        await firebaseFirestore.collection('users').doc(uid).set({
          'uid': uid,
          'email': email,
          'name': resolvedName,
        }, SetOptions(merge: true));
      }

      return AppUser(email: email, name: resolvedName, uid: uid);
    } catch (e) {
      throw Exception('Login Failed: $e');
    }
  }

  @override
  Future<AppUser?> registerWithEmailPassword(
      String email, String password, String name) async {
    try {
      UserCredential userCredential = await firebaseAuth
          .createUserWithEmailAndPassword(email: email, password: password);

      AppUser user =
          AppUser(email: email, name: name, uid: userCredential.user!.uid);

      await firebaseFirestore
          .collection("users")
          .doc(user.uid)
          .set(user.toJson());

      return user;
    } catch (e) {
      throw Exception('Register Failed: $e');
    }
  }

  @override
  Future<void> logout() async {
    await firebaseAuth.signOut();
  }

  @override
  Future<AppUser?> getCurrentUser() async {
    final firebaseUser = firebaseAuth.currentUser;

    if (firebaseUser == null) {
      return null;
    }

    DocumentSnapshot userDoc =
        await firebaseFirestore.collection("users").doc(firebaseUser.uid).get();

    if (!userDoc.exists) {
      return null;
    }

    return AppUser(
        email: firebaseUser.email!,
        name: userDoc['name'],
        uid: firebaseUser.uid);
  }
}
