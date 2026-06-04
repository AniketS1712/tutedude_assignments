import 'package:flutter/material.dart';

import '../data/models/mood.dart';

class MoodPicker extends StatelessWidget {
  final Mood selectedMood;
  final ValueChanged<Mood> onMoodSelected;

  const MoodPicker({
    super.key,
    required this.selectedMood,
    required this.onMoodSelected,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return SizedBox(
      height: 80,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: Mood.values.length,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final mood = Mood.values[index];
          final isSelected = mood == selectedMood;

          return GestureDetector(
            onTap: () => onMoodSelected(mood),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeInOut,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected
                    ? Color(mood.colorValue).withAlpha(38)
                    : colorScheme.surfaceContainerHighest.withAlpha(78),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isSelected
                      ? Color(mood.colorValue)
                      : Colors.transparent,
                  width: 2,
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    mood.emoji,
                    style: TextStyle(fontSize: isSelected ? 28 : 24),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    mood.label,
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: isSelected
                          ? Color(mood.colorValue)
                          : colorScheme.onSurface.withAlpha(153),
                      fontWeight: isSelected
                          ? FontWeight.w600
                          : FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
