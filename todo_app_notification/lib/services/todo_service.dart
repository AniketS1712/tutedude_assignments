import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:todo_app/Models/todo_model.dart';

class TodoService {
  final CollectionReference<Map<String, dynamic>> _todoCollection =
      FirebaseFirestore.instance.collection("todos");

  Future<void> addTodo(TodoModel todo) async {
    final docRef = _todoCollection.doc();
    final newTodo = todo.copyWith(id: docRef.id);
    try {
      await docRef.set({
        ...newTodo.toMap(),
        'createdAt': FieldValue.serverTimestamp(),
      });
    } on FirebaseException catch (e) {
      throw Exception(e.message);
    } catch (e) {
      throw Exception("An error occurred while creating the task");
    }
  }

  Future<void> deleteTodo(String id) async {
    try {
      await _todoCollection.doc(id).delete();
    } on FirebaseException catch (e) {
      throw Exception(e.message);
    } catch (e) {
      throw Exception("An error occurred while deleting the task");
    }
  }

  Stream<List<TodoModel>> getTodos(String userId) {
    return _todoCollection
        .where('userId', isEqualTo: userId)
        // If you want to order by creation time, uncomment below:
        // .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => TodoModel.fromMap(doc.data()))
              .toList(),
        );
  }

  Future<void> toggleTodo(String id, bool isCompleted) async {
    try {
      await _todoCollection.doc(id).update({'isCompleted': isCompleted});
    } on FirebaseException catch (e) {
      throw Exception(e.message);
    } catch (e) {
      throw Exception("An error occurred while updating the task");
    }
  }
}
