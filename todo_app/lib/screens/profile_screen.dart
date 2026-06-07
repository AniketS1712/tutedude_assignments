import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:todo_app/Models/user_model.dart';
import 'package:todo_app/providers/auth_provider.dart';
import 'package:todo_app/providers/todo_provider.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(getUser);
    final todoListAsync = ref.watch(todoStreamProvider);

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: userAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(
            child: Text(
              e.toString(),
              style: const TextStyle(color: Colors.white),
            ),
          ),
          data: (UserModel user) {
            return todoListAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => const SizedBox(),
              data: (todos) {
                final completed = todos.where((t) => t.isCompleted).length;
                final pending = todos.where((t) => !t.isCompleted).length;
                final highPriority = todos
                    .where((t) => t.priority.name == 'high')
                    .length;

                return SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 16,
                  ),
                  child: Column(
                    children: [
                      const SizedBox(height: 16),

                      // Avatar & Name
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.yellow.shade100,
                        ),
                        child: Center(
                          child: Text(
                            user.name.isNotEmpty
                                ? user.name[0].toUpperCase()
                                : '?',
                            style: const TextStyle(
                              color: Colors.black,
                              fontSize: 36,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      Text(
                        user.name,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        user.email,
                        style: TextStyle(
                          color: Colors.grey.shade400,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "Joined ${_formatDate(user.createdAt)}",
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 32),

                      // Stats Grid
                      Row(
                        children: [
                          _StatCard(
                            label: "Total Tasks",
                            value: todos.length.toString(),
                            icon: Icons.list_alt_rounded,
                            color: Colors.blueAccent,
                          ),
                          const SizedBox(width: 12),
                          _StatCard(
                            label: "Completed",
                            value: completed.toString(),
                            icon: Icons.check_circle_outline,
                            color: Colors.green,
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          _StatCard(
                            label: "Pending",
                            value: pending.toString(),
                            icon: Icons.pending_actions_rounded,
                            color: Colors.orangeAccent,
                          ),
                          const SizedBox(width: 12),
                          _StatCard(
                            label: "High Priority",
                            value: highPriority.toString(),
                            icon: Icons.flag_rounded,
                            color: Colors.redAccent,
                          ),
                        ],
                      ),
                      const SizedBox(height: 32),

                      // Completion bar
                      if (todos.isNotEmpty) ...[
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            "Completion Rate",
                            style: TextStyle(
                              color: Colors.grey.shade400,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: LinearProgressIndicator(
                            value: completed / todos.length,
                            minHeight: 10,
                            backgroundColor: Colors.grey.shade800,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.yellow.shade100,
                            ),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Align(
                          alignment: Alignment.centerRight,
                          child: Text(
                            "${(completed / todos.length * 100).toStringAsFixed(0)}%",
                            style: TextStyle(
                              color: Colors.yellow.shade100,
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(height: 32),
                      ],

                      // Logout button
                      SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: OutlinedButton.icon(
                          onPressed: () async {
                            await ref.read(authServiceProvider).signOut();
                          },
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: Colors.redAccent),
                            foregroundColor: Colors.redAccent,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          icon: const Icon(Icons.logout_rounded),
                          label: const Text(
                            "Sign Out",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                    ],
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    const months = [
      '',
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return "${months[date.month]} ${date.year}";
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.grey.shade900,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withAlpha(30),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(height: 12),
            Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 2),
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
