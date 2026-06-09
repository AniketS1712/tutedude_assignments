import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:todo_app/Models/todo_model.dart';
import 'package:todo_app/providers/auth_provider.dart';
import 'package:todo_app/services/todo_service.dart';

final todoServiceProvider = Provider<TodoService>((ref) => TodoService());

final todoStreamProvider = StreamProvider<List<TodoModel>>((ref) {
  final user = ref.watch(authStateProvider).value;
  
  if (user == null) {
    return Stream.value([]);
  }
  
  return ref.watch(todoServiceProvider).getTodos(user.uid);
});
