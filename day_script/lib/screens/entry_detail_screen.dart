import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:share_plus/share_plus.dart';

import '../core/theme/app_theme.dart';
import '../core/utils/date_formatter.dart';
import '../data/models/diary_entry.dart';
import '../data/models/mood.dart';
import '../providers/providers.dart';

class EntryDetailScreen extends ConsumerWidget {
  final int entryId;
  const EntryDetailScreen({super.key, required this.entryId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final entryAsync = ref.watch(entryByIdProvider(entryId));
    final cs = Theme.of(context).colorScheme;

    return entryAsync.when(
      data: (entry) {
        if (entry == null) {
          return Scaffold(
            appBar: AppBar(),
            body: const Center(child: Text('Entry not found')),
          );
        }
        final mood = Mood.values[entry.mood.index];
        final moodColor = AppColors.getMoodColor(entry.mood.index);

        return Scaffold(
          body: CustomScrollView(
            slivers: [
              SliverAppBar(
                pinned: true,
                expandedHeight: entry.photoPaths.isNotEmpty ? 280 : 0,
                flexibleSpace: entry.photoPaths.isNotEmpty
                    ? FlexibleSpaceBar(
                        background: Stack(
                          fit: StackFit.expand,
                          children: [
                            Image.file(
                              File(entry.photoPaths.first),
                              fit: BoxFit.cover,
                              errorBuilder: (_, _, _) =>
                                  Container(color: cs.surfaceContainerHighest),
                            ),
                            const DecoratedBox(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [Colors.transparent, Colors.black54],
                                ),
                              ),
                            ),
                          ],
                        ),
                      )
                    : null,
                actions: [
                  IconButton(
                    icon: const Icon(Icons.share_outlined),
                    onPressed: () {
                      Share.share(
                        '${entry.title}\n---\n${entry.bodyPlainText}',
                        subject: entry.title,
                      );
                    },
                  ),
                  IconButton(
                    icon: Icon(
                      entry.isFavorite
                          ? Icons.favorite_rounded
                          : Icons.favorite_border_rounded,
                      color: entry.isFavorite ? Colors.red.shade300 : null,
                    ),
                    onPressed: () async {
                      await ref
                          .read(entryRepositoryProvider)
                          .toggleFavorite(entry.id);
                      ref.invalidate(entryByIdProvider(entryId));
                      ref.invalidate(allEntriesProvider);
                    },
                  ),
                  PopupMenuButton<String>(
                    onSelected: (v) {
                      if (v == 'delete') _confirmDelete(context, ref, entry);
                    },
                    itemBuilder: (_) => [
                      const PopupMenuItem(
                        value: 'delete',
                        child: Row(
                          children: [
                            Icon(Icons.delete_outline, color: Colors.red),
                            SizedBox(width: 8),
                            Text('Delete', style: TextStyle(color: Colors.red)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              SliverPadding(
                padding: const EdgeInsets.all(20),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    Hero(
                      tag: 'entry_$entryId',
                      child: Material(
                        color: Colors.transparent,
                        child: Text(
                          entry.title.isEmpty ? 'Untitled' : entry.title,
                          style: GoogleFonts.playfairDisplay(
                            fontSize: 28,
                            fontWeight: FontWeight.w700,
                            color: cs.onSurface,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 12,
                      runSpacing: 8,
                      children: [
                        _metaChip(
                          context,
                          Icons.calendar_today_rounded,
                          DateFormatter.relative(entry.createdAt),
                        ),
                        _metaChip(
                          context,
                          Icons.text_fields_rounded,
                          '${entry.wordCount} words',
                        ),
                        if (entry.locationCity != null &&
                            entry.locationCity!.isNotEmpty)
                          _metaChip(
                            context,
                            Icons.location_on_outlined,
                            entry.locationCity!,
                          ),
                      ],
                    ),
                    if (entry.mood.index != 0) ...[
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: moodColor.withAlpha(25),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: moodColor.withAlpha(78)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              mood.emoji,
                              style: const TextStyle(fontSize: 20),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Feeling ${mood.label}',
                              style: TextStyle(
                                color: moodColor,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                    if (entry.tags.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 6,
                        runSpacing: 6,
                        children: entry.tags
                            .map(
                              (t) => Chip(
                                label: Text(t),
                                visualDensity: VisualDensity.compact,
                              ),
                            )
                            .toList(),
                      ),
                    ],
                    const SizedBox(height: 24),
                    Divider(color: cs.outlineVariant.withAlpha(78)),
                    const SizedBox(height: 16),
                    SelectableText(
                      entry.bodyPlainText.isEmpty
                          ? 'No content'
                          : entry.bodyPlainText,
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        height: 1.7,
                        color: cs.onSurface.withAlpha(195),
                      ),
                    ),
                    const SizedBox(height: 80),
                  ]),
                ),
              ),
            ],
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: () => context.push('/entry/$entryId/edit'),
            child: const Icon(Icons.edit_rounded),
          ),
        );
      },
      loading: () =>
          const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (e, _) => Scaffold(
        appBar: AppBar(),
        body: Center(child: Text('Error: $e')),
      ),
    );
  }

  Widget _metaChip(BuildContext context, IconData icon, String text) {
    final cs = Theme.of(context).colorScheme;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: cs.onSurface.withAlpha(128)),
        const SizedBox(width: 4),
        Text(
          text,
          style: Theme.of(
            context,
          ).textTheme.bodySmall?.copyWith(color: cs.onSurface.withAlpha(154)),
        ),
      ],
    );
  }

  void _confirmDelete(BuildContext context, WidgetRef ref, DiaryEntry entry) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Entry'),
        content: const Text('Are you sure? This cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            onPressed: () async {
              Navigator.pop(ctx);
              await ref.read(entryRepositoryProvider).deleteEntry(entry.id);
              ref.invalidate(allEntriesProvider);
              if (context.mounted) context.go('/home');
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
