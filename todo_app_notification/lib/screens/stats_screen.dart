import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:todo_app/providers/todo_provider.dart';

class StatsScreen extends ConsumerWidget {
  const StatsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final todosAsync = ref.watch(todoStreamProvider);

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          "Statistics",
          style: TextStyle(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: todosAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, __) => const Center(
          child: Text(
            "Could not load stats",
            style: TextStyle(color: Colors.white54),
          ),
        ),
        data: (todos) {
          final total = todos.length;
          final completed = todos.where((t) => t.isCompleted).length;
          final pending = todos.where((t) => !t.isCompleted).length;
          final rate = total == 0 ? 0.0 : completed / total;

          return ListView(
            padding: const EdgeInsets.all(24),
            children: [
              // Completion Rate Ring (simple linear version)
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.grey.shade900,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "Completion Rate",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          "${(rate * 100).toStringAsFixed(0)}%",
                          style: TextStyle(
                            color: Colors.yellow.shade100,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: LinearProgressIndicator(
                        value: rate,
                        minHeight: 12,
                        backgroundColor: Colors.grey.shade800,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          Colors.yellow.shade100,
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      "$completed of $total tasks completed",
                      style: TextStyle(
                        color: Colors.grey.shade500,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Task Counts Row
              Row(
                children: [
                  _SimpleStatTile(
                    label: "Total",
                    value: total,
                    color: Colors.blueAccent,
                  ),
                  const SizedBox(width: 12),
                  _SimpleStatTile(
                    label: "Done",
                    value: completed,
                    color: Colors.green,
                  ),
                  const SizedBox(width: 12),
                  _SimpleStatTile(
                    label: "Pending",
                    value: pending,
                    color: Colors.orangeAccent,
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Remove priority breakdown
            ],
          );
        },
      ),
    );
  }
}

class _SimpleStatTile extends StatelessWidget {
  final String label;
  final int value;
  final Color color;

  const _SimpleStatTile({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          color: Colors.grey.shade900,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            Text(
              value.toString(),
              style: TextStyle(
                color: color,
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(color: Colors.grey.shade500, fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }
}
