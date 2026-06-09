import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:todo_app/providers/auth_provider.dart';
import 'package:todo_app/providers/todo_provider.dart';
import 'package:todo_app/screens/add_form.dart';
import 'package:todo_app/screens/calendar_screen.dart';
import 'package:todo_app/screens/profile_screen.dart';
import 'package:todo_app/screens/stats_screen.dart';
import 'package:todo_app/widgets/task_card.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  int _selectedIndex = 0;

  final List<BottomNavigationBarItem> _items = [
    const BottomNavigationBarItem(
      icon: Icon(Icons.home_rounded),
      label: "Home",
    ),
    const BottomNavigationBarItem(
      icon: Icon(Icons.calendar_month_outlined),
      label: "Calendar",
    ),
    BottomNavigationBarItem(
      icon: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.yellow.shade100,
        ),
        child: const Icon(Icons.add_rounded, color: Colors.black87),
      ),
      label: "",
    ),
    const BottomNavigationBarItem(
      icon: Icon(Icons.show_chart_rounded),
      label: "Statistics",
    ),
    const BottomNavigationBarItem(
      icon: Icon(Icons.person_outline_rounded),
      label: "Profile",
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final userName = ref.watch(
      getUser.select((asyncUser) => asyncUser.value?.name ?? ''),
    );
    final todoListAsync = ref.watch(todoStreamProvider);

    // The tab screens (index 2 is the add button, not a screen)
    final screens = [
      _HomeTab(userName: userName, todoListAsync: todoListAsync),
      const CalendarScreen(),
      const SizedBox.shrink(), // placeholder for add (handled in onTap)
      const StatsScreen(),
      const ProfileScreen(),
    ];

    return Scaffold(
      backgroundColor: Colors.black,
      body: IndexedStack(index: _selectedIndex, children: screens),
      bottomNavigationBar: BottomNavigationBar(
        items: _items,
        currentIndex: _selectedIndex,
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.grey.shade900,
        elevation: 0,
        selectedItemColor: Colors.yellow.shade100,
        unselectedItemColor: Colors.grey.shade500,
        showSelectedLabels: false,
        showUnselectedLabels: false,
        onTap: (index) {
          if (index == 2) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const AddForm()),
            );
          } else {
            setState(() => _selectedIndex = index);
          }
        },
      ),
    );
  }
}

// ─── Home Tab ─────────────────────────────────────────────────────────────────

class _HomeTab extends ConsumerWidget {
  final String userName;
  final AsyncValue<List> todoListAsync;

  const _HomeTab({required this.userName, required this.todoListAsync});

  Color _priorityColor(String name) {
    switch (name) {
      case 'high':
        return Colors.redAccent;
      case 'medium':
        return Colors.orangeAccent;
      default:
        return Colors.green;
    }
  }

  String _priorityLabel(String name) =>
      name[0].toUpperCase() + name.substring(1);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Re-watch the stream here so it rebuilds properly within the widget tree
    final todos = ref.watch(todoStreamProvider);

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        title: Text(
          "Hello, $userName 👋",
          style: const TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 10),
              const Text(
                "Ongoing",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                  letterSpacing: 1.5,
                ),
              ),
              const SizedBox(height: 16),
              todos.when(
                data: (todoList) {
                  if (todoList.isEmpty) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 48),
                        child: Column(
                          children: [
                            Icon(
                              Icons.check_circle_outline,
                              size: 64,
                              color: Colors.grey.shade700,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              "No tasks yet!\nTap + to add one.",
                              textAlign: TextAlign.center,
                              style: TextStyle(color: Colors.grey.shade500),
                            ),
                          ],
                        ),
                      ),
                    );
                  }
                  return ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: todoList.length,
                    itemBuilder: (context, index) {
                      final todo = todoList[index];
                      final pColor = _priorityColor(todo.priority.name);
                      final pName = _priorityLabel(todo.priority.name);

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: TaskCard(
                          title: todo.taskname,
                          description: todo.description,
                          time:
                              "${todo.startDate.hour.toString().padLeft(2, '0')}:${todo.startDate.minute.toString().padLeft(2, '0')}",
                          priority: pName,
                          priorityColor: pColor,
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
                loading: () => const Center(
                  child: Padding(
                    padding: EdgeInsets.all(32),
                    child: CircularProgressIndicator(),
                  ),
                ),
                error: (error, _) => Center(
                  child: Text(
                    "Error loading tasks",
                    style: TextStyle(color: Colors.redAccent),
                  ),
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}
