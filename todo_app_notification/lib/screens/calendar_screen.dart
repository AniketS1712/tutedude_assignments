import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:todo_app/Models/todo_model.dart';
import 'package:todo_app/providers/todo_provider.dart';
import 'package:todo_app/widgets/task_card.dart';

class CalendarScreen extends ConsumerStatefulWidget {
  const CalendarScreen({super.key});

  @override
  ConsumerState<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends ConsumerState<CalendarScreen> {
  DateTime _selectedDate = DateTime.now();
  DateTime _focusedMonth = DateTime.now();

  DateTime get _today => DateTime(
        DateTime.now().year,
        DateTime.now().month,
        DateTime.now().day,
      );

  void _previousMonth() {
    setState(() {
      _focusedMonth = DateTime(_focusedMonth.year, _focusedMonth.month - 1);
    });
  }

  void _nextMonth() {
    setState(() {
      _focusedMonth = DateTime(_focusedMonth.year, _focusedMonth.month + 1);
    });
  }

  List<DateTime?> _daysInGrid() {
    final firstDay = DateTime(_focusedMonth.year, _focusedMonth.month, 1);
    final lastDay = DateTime(_focusedMonth.year, _focusedMonth.month + 1, 0);
    final startOffset = firstDay.weekday % 7; // 0=Sun offset

    final days = <DateTime?>[];
    for (int i = 0; i < startOffset; i++) {
      days.add(null); // empty padding
    }
    for (int d = 1; d <= lastDay.day; d++) {
      days.add(DateTime(_focusedMonth.year, _focusedMonth.month, d));
    }
    return days;
  }

  bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  Color _priorityColor(Priority p) {
    switch (p) {
      case Priority.high:
        return Colors.redAccent;
      case Priority.medium:
        return Colors.orangeAccent;
      case Priority.low:
        return Colors.green;
    }
  }

  String _priorityName(Priority p) {
    return p.name[0].toUpperCase() + p.name.substring(1);
  }

  @override
  Widget build(BuildContext context) {
    final todoListAsync = ref.watch(todoStreamProvider);
    final days = _daysInGrid();

    const weekdays = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];

    final monthName = [
      '', 'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December',
    ][_focusedMonth.month];

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "$monthName ${_focusedMonth.year}",
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Row(
                    children: [
                      _NavBtn(
                        icon: Icons.chevron_left,
                        onTap: _previousMonth,
                      ),
                      const SizedBox(width: 8),
                      _NavBtn(
                        icon: Icons.chevron_right,
                        onTap: _nextMonth,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Weekday labels
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                children: weekdays
                    .map(
                      (d) => Expanded(
                        child: Center(
                          child: Text(
                            d,
                            style: TextStyle(
                              color: Colors.grey.shade500,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    )
                    .toList(),
              ),
            ),
            const SizedBox(height: 8),

            // Calendar grid
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: todoListAsync.when(
                loading: () => const SizedBox(),
                error: (_, __) => const SizedBox(),
                data: (todos) {
                  // collect days that have tasks
                  final daysWithTasks = <String>{};
                  for (final t in todos) {
                    daysWithTasks.add(
                      '${t.startDate.year}-${t.startDate.month}-${t.startDate.day}',
                    );
                  }

                  return GridView.count(
                    crossAxisCount: 7,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    children: days.map((date) {
                      if (date == null) return const SizedBox();

                      final isSelected = _isSameDay(date, _selectedDate);
                      final isToday = _isSameDay(date, _today);
                      final hasTask = daysWithTasks.contains(
                        '${date.year}-${date.month}-${date.day}',
                      );

                      return GestureDetector(
                        onTap: () => setState(() => _selectedDate = date),
                        child: Container(
                          margin: const EdgeInsets.all(3),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: isSelected
                                ? Colors.yellow.shade100
                                : Colors.transparent,
                            border: isToday && !isSelected
                                ? Border.all(color: Colors.yellow.shade100, width: 1.5)
                                : null,
                          ),
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              Text(
                                date.day.toString(),
                                style: TextStyle(
                                  color: isSelected
                                      ? Colors.black
                                      : Colors.white,
                                  fontWeight: isToday
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                                  fontSize: 14,
                                ),
                              ),
                              if (hasTask && !isSelected)
                                Positioned(
                                  bottom: 4,
                                  child: Container(
                                    width: 4,
                                    height: 4,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: Colors.yellow.shade100,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  );
                },
              ),
            ),

            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Text(
                "Tasks on ${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}",
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Task list for selected day
            Expanded(
              child: todoListAsync.when(
                loading: () =>
                    const Center(child: CircularProgressIndicator()),
                error: (_, __) => const SizedBox(),
                data: (todos) {
                  final filtered = todos
                      .where((t) => _isSameDay(t.startDate, _selectedDate))
                      .toList();

                  if (filtered.isEmpty) {
                    return Center(
                      child: Text(
                        "No tasks on this day",
                        style: TextStyle(color: Colors.grey.shade600),
                      ),
                    );
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    itemCount: filtered.length,
                    itemBuilder: (context, index) {
                      final todo = filtered[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: TaskCard(
                          title: todo.taskname,
                          description: todo.description,
                          time:
                              "${todo.startDate.hour.toString().padLeft(2, '0')}:${todo.startDate.minute.toString().padLeft(2, '0')}",
                          priority: _priorityName(todo.priority),
                          priorityColor: _priorityColor(todo.priority),
                          isCompleted: todo.isCompleted,
                          onToggle: () {
                            ref
                                .read(todoServiceProvider)
                                .toggleTodo(todo.id, !todo.isCompleted);
                          },
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NavBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _NavBtn({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: Colors.grey.shade900,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: Colors.white, size: 20),
      ),
    );
  }
}
