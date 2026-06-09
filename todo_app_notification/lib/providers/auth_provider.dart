import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:todo_app/Models/user_model.dart';
import 'package:todo_app/services/auth_service.dart';

final authServiceProvider = Provider<AuthService>((ref) => AuthService(ref));

final authStateProvider = StreamProvider<User?>(
  (ref) => FirebaseAuth.instance.authStateChanges(),
);

final getUser = FutureProvider<UserModel>((ref) async {
  final authService = ref.watch(authServiceProvider);
  final user = ref.watch(authStateProvider).value;
  return authService.getUser(user!.uid);
});
