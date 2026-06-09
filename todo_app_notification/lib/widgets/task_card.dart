import 'package:flutter/material.dart';

class TaskCard extends StatelessWidget {
  final String title;
  final String description;
  final String time;
  final String priority;
  final Color priorityColor;
  final bool isCompleted;
  final VoidCallback onToggle;

  const TaskCard({
    super.key,
    required this.title,
    required this.description,
    required this.time,
    required this.priority,
    required this.priorityColor,
    required this.isCompleted,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.grey.shade900,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Custom Checkbox
          GestureDetector(
            onTap: onToggle,
            child: AnimatedContainer(
              duration: Duration(milliseconds: 200),
              margin: const EdgeInsets.only(right: 16, top: 2),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isCompleted
                    ? Colors.yellow.shade100
                    : Colors.transparent,
                border: Border.all(
                  color: isCompleted
                      ? Colors.yellow.shade100
                      : Colors.grey.shade500,
                  width: 2,
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(4.0),
                child: Icon(
                  Icons.check,
                  color: isCompleted ? Colors.black : Colors.transparent,
                  size: 16,
                ),
              ),
            ),
          ),
          // Task Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: priorityColor.withAlpha(25),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    priority,
                    style: TextStyle(
                      color: priorityColor,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  title,
                  style: TextStyle(
                    color: isCompleted ? Colors.grey.shade400 : Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    decoration: isCompleted ? TextDecoration.lineThrough : null,
                  ),
                ),
                SizedBox(height: 6),
                Text(
                  description,
                  style: TextStyle(
                    color: isCompleted ? Colors.grey.shade600 : Colors.white54,
                    fontSize: 14,
                    height: 1.4,
                    decoration: isCompleted ? TextDecoration.lineThrough : null,
                  ),
                ),
                SizedBox(height: 16),
                Row(
                  children: [
                    Spacer(),
                    Icon(
                      Icons.access_time_rounded,
                      color: isCompleted
                          ? Colors.grey.shade500
                          : Colors.grey.shade300,
                      size: 16,
                    ),
                    SizedBox(width: 4),
                    Text(
                      time,
                      style: TextStyle(
                        color: isCompleted
                            ? Colors.grey.shade500
                            : Colors.grey.shade300,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
