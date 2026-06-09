import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:todo_app/Models/user_model.dart';

class AuthService {
  final Ref ref;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final CollectionReference<Map<String, dynamic>> _userFirestore =
      FirebaseFirestore.instance.collection('users');

  AuthService(this.ref);

  Future<void> createUser(UserModel user) async {
    await _userFirestore.doc(user.id).set({
      ...user.toMap(),
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Future<UserModel> getUser(String id) async {
    final doc = await _userFirestore.doc(id).get();

    if (!doc.exists) {
      throw Exception("User not found");
    }

    return UserModel.fromMap(doc.data()!);
  }

  Future<UserModel> signIn(String email, String password) async {
    try {
      final result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = result.user;

      if (user == null) {
        throw Exception("User not found after sign in");
      }
      return await getUser(user.uid);
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'user-not-found':
          throw Exception("No user found for that email.");
        case 'wrong-password':
          throw Exception("Wrong password provided.");
        case 'invalid-credential':
          throw Exception("Invalid email or password.");
        case 'user-disabled':
          throw Exception("This user account has been disabled.");
        case 'too-many-requests':
          throw Exception("Too many attempts. Please try again later.");
        default:
          throw Exception(e.message ?? "Authentication failed");
      }
    } catch (e) {
      throw Exception("An unexpected error occurred during login.");
    }
  }

  Future<UserCredential?> signUp(
    String name,
    String email,
    String password,
  ) async {
    try {
      final UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = UserModel(
        id: result.user!.uid,
        name: name,
        email: email,
        createdAt: DateTime.now(),
      );

      await createUser(user);
      return result;
    } catch (e) {
      throw Exception("Sign Up Failed: $e");
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }
}
