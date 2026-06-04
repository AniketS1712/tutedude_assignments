import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:table_calendar/table_calendar.dart';

import '../core/theme/app_theme.dart';
import '../core/utils/date_formatter.dart';
import '../core/utils/extensions.dart';
import '../data/models/diary_entry.dart';
import '../providers/providers.dart';
import '../widgets/entry_card.dart';

class CalendarScreen extends ConsumerStatefulWidget {
  const CalendarScreen({super.key});

  @override
  ConsumerState<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends ConsumerState<CalendarScreen> {
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final groupedAsync = ref.watch(entriesGroupedByDateProvider);
    final entryCountAsync = ref.watch(entryCountProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Calendar',
          style: GoogleFonts.playfairDisplay(
            fontSize: 24,
            fontWeight: FontWeight.w700,
          ),
        ),
        actions: [
          entryCountAsync.when(
            data: (count) => Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: cs.secondaryContainer.withAlpha(128),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '$count entries',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: cs.onSecondaryContainer,
                    ),
                  ),
                ),
              ),
            ),
            loading: () => const SizedBox(),
            error: (_, _) => const SizedBox(),
          ),
        ],
      ),
      body: groupedAsync.when(
        data: (grouped) => Column(
          children: [
            TableCalendar<DiaryEntry>(
              firstDay: DateTime(2020),
              lastDay: DateTime(2030),
              focusedDay: _focusedDay,
              calendarFormat: _calendarFormat,
              selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
              onDaySelected: (selectedDay, focusedDay) {
                setState(() {
                  _selectedDay = selectedDay;
                  _focusedDay = focusedDay;
                });
                _showDayEntries(context, selectedDay, grouped);
              },
              onFormatChanged: (format) {
                setState(() => _calendarFormat = format);
              },
              onPageChanged: (focusedDay) {
                _focusedDay = focusedDay;
              },
              eventLoader: (day) {
                final dateKey = day.dateOnly;
                return grouped[dateKey] ?? [];
              },
              calendarStyle: CalendarStyle(
                todayDecoration: BoxDecoration(
                  color: cs.primary.withAlpha(60),
                  shape: BoxShape.circle,
                ),
                todayTextStyle: TextStyle(
                  color: cs.primary,
                  fontWeight: FontWeight.w700,
                ),
                selectedDecoration: BoxDecoration(
                  color: cs.primary,
                  shape: BoxShape.circle,
                ),
                selectedTextStyle: TextStyle(
                  color: cs.onPrimary,
                  fontWeight: FontWeight.w600,
                ),
                outsideDaysVisible: false,
                markerDecoration: BoxDecoration(
                  color: cs.primary,
                  shape: BoxShape.circle,
                ),
                markerSize: 6,
                markersMaxCount: 3,
                markersAnchor: 0.7,
              ),
              calendarBuilders: CalendarBuilders(
                markerBuilder: (context, date, events) {
                  if (events.isEmpty) return null;

                  final dominantMood = _getDominantMood(events);
                  final color = AppColors.getMoodColor(dominantMood.index);
                  return Positioned(
                    bottom: 1,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: List.generate(
                        events.length.clamp(1, 3),
                        (i) => Container(
                          width: 6,
                          height: 6,
                          margin: const EdgeInsets.symmetric(horizontal: 1),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: color,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
              headerStyle: HeaderStyle(
                titleCentered: true,
                formatButtonDecoration: BoxDecoration(
                  border: Border.all(color: cs.outline.withAlpha(78)),
                  borderRadius: BorderRadius.circular(12),
                ),
                formatButtonTextStyle: TextStyle(
                  color: cs.onSurface,
                  fontSize: 12,
                ),
                titleTextStyle: GoogleFonts.playfairDisplay(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              daysOfWeekStyle: DaysOfWeekStyle(
                weekdayStyle: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: cs.onSurface.withAlpha(180),
                ),
                weekendStyle: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: cs.onSurface.withAlpha(120),
                ),
              ),
            ),

            const Divider(height: 1),

            if (_selectedDay != null)
              Expanded(
                child: _buildDayEntries(grouped[_selectedDay!.dateOnly] ?? []),
              )
            else
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.touch_app_outlined,
                        size: 48,
                        color: cs.onSurface.withAlpha(64),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Tap a day to see entries',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: cs.onSurface.withAlpha(120),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
    );
  }

  Widget _buildDayEntries(List<DiaryEntry> entries) {
    if (entries.isEmpty) {
      return Center(
        child: Text(
          'No entries on this day',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: Theme.of(context).colorScheme.onSurface.withAlpha(120),
          ),
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: entries.length,
      separatorBuilder: (_, _) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final entry = entries[index];
        return EntryCard(
          entry: entry,
          compact: true,
          onTap: () => context.push('/entry/${entry.id}'),
        );
      },
    );
  }

  MoodEnum _getDominantMood(List<DiaryEntry> entries) {
    if (entries.isEmpty) return MoodEnum.none;
    final counts = <MoodEnum, int>{};
    for (final e in entries) {
      counts[e.mood] = (counts[e.mood] ?? 0) + 1;
    }
    return counts.entries.reduce((a, b) => a.value >= b.value ? a : b).key;
  }

  void _showDayEntries(
    BuildContext context,
    DateTime day,
    Map<DateTime, List<DiaryEntry>> grouped,
  ) {
    final entries = grouped[day.dateOnly] ?? [];
    if (entries.isEmpty) return;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => DraggableScrollableSheet(
        initialChildSize: 0.4,
        minChildSize: 0.25,
        maxChildSize: 0.8,
        expand: false,
        builder: (ctx, scrollController) {
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
                child: Text(
                  DateFormatter.fullDate(day),
                  style: GoogleFonts.playfairDisplay(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Expanded(
                child: ListView.separated(
                  controller: scrollController,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: entries.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 8),
                  itemBuilder: (ctx, i) {
                    final entry = entries[i];
                    return EntryCard(
                      entry: entry,
                      onTap: () {
                        Navigator.pop(ctx);
                        context.push('/entry/${entry.id}');
                      },
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
