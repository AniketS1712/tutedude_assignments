import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../core/theme/app_theme.dart';
import '../core/utils/date_formatter.dart';
import '../data/models/diary_entry.dart';
import '../data/models/mood.dart';

class EntryCard extends StatelessWidget {
  final DiaryEntry entry;
  final VoidCallback onTap;
  final VoidCallback? onDismissed;
  final bool compact;

  const EntryCard({
    super.key,
    required this.entry,
    required this.onTap,
    this.onDismissed,
    this.compact = false,
  });

  Mood get _mood => Mood.values[entry.mood.index];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final moodColor = AppColors.getMoodColor(entry.mood.index);

    final card = Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          decoration: BoxDecoration(
            color: theme.cardTheme.color ?? colorScheme.surfaceContainerLow,
            borderRadius: BorderRadius.circular(12),
            border: Border(left: BorderSide(color: moodColor, width: 4)),
          ),
          padding: EdgeInsets.all(compact ? 12 : 16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            entry.title.isEmpty ? 'Untitled' : entry.title,
                            style: GoogleFonts.playfairDisplay(
                              fontSize: compact ? 16 : 18,
                              fontWeight: FontWeight.w600,
                              color: colorScheme.onSurface,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (entry.mood != MoodEnum.none) ...[
                          const SizedBox(width: 8),
                          Text(
                            _mood.emoji,
                            style: const TextStyle(fontSize: 18),
                          ),
                        ],
                      ],
                    ),

                    if (!compact) const SizedBox(height: 6),

                    if (entry.bodyPlainText.isNotEmpty && !compact)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Text(
                          entry.bodyPlainText,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: colorScheme.onSurface.withAlpha(153),
                            height: 1.4,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),

                    Row(
                      children: [
                        Icon(
                          Icons.access_time_rounded,
                          size: 14,
                          color: colorScheme.onSurface.withAlpha(102),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          DateFormatter.relative(entry.createdAt),
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurface.withAlpha(128),
                          ),
                        ),
                        if (entry.isFavorite) ...[
                          const SizedBox(width: 8),
                          Icon(
                            Icons.favorite_rounded,
                            size: 14,
                            color: Colors.red.shade300,
                          ),
                        ],
                        const Spacer(),

                        ...entry.tags
                            .take(3)
                            .map(
                              (tag) => Padding(
                                padding: const EdgeInsets.only(left: 4),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: colorScheme.secondaryContainer
                                        .withAlpha(128),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    tag,
                                    style: theme.textTheme.labelSmall?.copyWith(
                                      color: colorScheme.onSecondaryContainer,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                      ],
                    ),
                  ],
                ),
              ),

              if (entry.photoPaths.isNotEmpty && !compact) ...[
                const SizedBox(width: 12),
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: SizedBox(
                    width: 60,
                    height: 60,
                    child: Image.file(
                      File(entry.photoPaths.first),
                      fit: BoxFit.cover,
                      errorBuilder: (_, _, _) => Container(
                        color: colorScheme.surfaceContainerHighest,
                        child: Icon(
                          Icons.image_rounded,
                          color: colorScheme.onSurface.withAlpha(78),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );

    if (onDismissed != null) {
      return Dismissible(
        key: ValueKey(entry.id),
        direction: DismissDirection.endToStart,
        background: Container(
          alignment: Alignment.centerRight,
          padding: const EdgeInsets.only(right: 24),
          decoration: BoxDecoration(
            color: colorScheme.error,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(Icons.delete_outline_rounded, color: colorScheme.onError),
        ),
        confirmDismiss: (_) async => true,
        onDismissed: (_) => onDismissed!(),
        child: card,
      );
    }

    return card;
  }
}
