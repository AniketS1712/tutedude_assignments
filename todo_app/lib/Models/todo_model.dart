import 'package:cloud_firestore/cloud_firestore.dart';

enum Priority { low, medium, high }

class TodoModel {
  final String id;
  final String userId;
  final String taskname;
  final DateTime startDate;
  final DateTime endDate;
  final String description;
  final Priority priority;
  final bool isCompleted;

  TodoModel({
    required this.id,
    required this.userId,
    required this.taskname,
    required this.startDate,
    required this.endDate,
    required this.description,
    required this.priority,
    this.isCompleted = false,
  });

  TodoModel copyWith({
    String? id,
    String? userId,
    String? taskname,
    DateTime? startDate,
    DateTime? endDate,
    String? description,
    Priority? priority,
    bool? isCompleted,
  }) {
    return TodoModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      taskname: taskname ?? this.taskname,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      description: description ?? this.description,
      priority: priority ?? this.priority,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      "id": id,
      "userId": userId,
      "taskname": taskname,
      "startDate": Timestamp.fromDate(startDate),
      "endDate": Timestamp.fromDate(endDate),
      "description": description,
      "priority": priority.name,
      "isCompleted": isCompleted,
    };
  }

  factory TodoModel.fromMap(Map<String, dynamic> map) {
    return TodoModel(
      id: map["id"] ?? '',
      userId: map["userId"] ?? '',
      taskname: map["taskname"] ?? '',
      startDate: map["startDate"] != null
          ? (map["startDate"] as Timestamp).toDate()
          : DateTime.now(),
      endDate: map["endDate"] != null
          ? (map["endDate"] as Timestamp).toDate()
          : DateTime.now(),
      description: map["description"] ?? '',
      priority: Priority.values.firstWhere(
        (e) => e.name == map["priority"],
        orElse: () => Priority.medium,
      ),
      isCompleted: map["isCompleted"] ?? false,
    );
  }
}
