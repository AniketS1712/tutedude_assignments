import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../data/models/diary_entry.dart';
import '../data/models/mood.dart';
import '../providers/providers.dart';
import '../widgets/entry_card.dart';

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final _searchController = TextEditingController();
  final _focusNode = FocusNode();
  Timer? _debounce;

  MoodEnum? _moodFilter;
  String? _tagFilter;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () {
      ref.read(searchQueryProvider.notifier).state = query.trim();
    });
  }

  void _submitSearch(String query) {
    final trimmed = query.trim();
    if (trimmed.isNotEmpty) {
      ref.read(recentSearchesProvider.notifier).addSearch(trimmed);
      ref.read(searchQueryProvider.notifier).state = trimmed;
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final query = ref.watch(searchQueryProvider);
    final resultsAsync = ref.watch(searchResultsProvider);
    final recentSearches = ref.watch(recentSearchesProvider);
    final tagsAsync = ref.watch(allTagsProvider);

    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0,
        title: TextField(
          controller: _searchController,
          focusNode: _focusNode,
          onChanged: _onSearchChanged,
          onSubmitted: _submitSearch,
          style: GoogleFonts.inter(fontSize: 16),
          decoration: InputDecoration(
            hintText: 'Search entries...',
            hintStyle: GoogleFonts.inter(
              fontSize: 16,
              color: cs.onSurface.withAlpha(102),
            ),
            border: InputBorder.none,
            filled: false,
            contentPadding: const EdgeInsets.symmetric(vertical: 12),
            suffixIcon: _searchController.text.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.clear, size: 20),
                    onPressed: () {
                      _searchController.clear();
                      ref.read(searchQueryProvider.notifier).state = '';
                      _focusNode.requestFocus();
                    },
                  )
                : null,
          ),
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                ...Mood.values.where((m) => m != Mood.none).map((mood) {
                  final isActive = _moodFilter == MoodEnum.values[mood.index];
                  return Padding(
                    padding: const EdgeInsets.only(right: 6),
                    child: FilterChip(
                      label: Text('${mood.emoji} ${mood.label}'),
                      selected: isActive,
                      onSelected: (selected) {
                        setState(() {
                          _moodFilter = selected
                              ? MoodEnum.values[mood.index]
                              : null;
                        });
                      },
                      visualDensity: VisualDensity.compact,
                    ),
                  );
                }),

                tagsAsync.when(
                  data: (tags) => Row(
                    children: tags.take(5).map((tag) {
                      final isActive = _tagFilter == tag.name;
                      return Padding(
                        padding: const EdgeInsets.only(right: 6),
                        child: FilterChip(
                          label: Text(tag.name),
                          selected: isActive,
                          onSelected: (selected) {
                            setState(() {
                              _tagFilter = selected ? tag.name : null;
                            });
                          },
                          visualDensity: VisualDensity.compact,
                        ),
                      );
                    }).toList(),
                  ),
                  loading: () => const SizedBox(),
                  error: (_, _) => const SizedBox(),
                ),
              ],
            ),
          ),

          const Divider(height: 1),

          Expanded(
            child: query.isEmpty && _moodFilter == null && _tagFilter == null
                ? _buildRecentSearches(context, recentSearches)
                : _buildResults(context, resultsAsync),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentSearches(BuildContext context, List<String> searches) {
    final cs = Theme.of(context).colorScheme;

    if (searches.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.search, size: 64, color: cs.onSurface.withAlpha(38)),
            const SizedBox(height: 16),
            Text(
              'Search your diary',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: cs.onSurface.withAlpha(102),
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Recent Searches',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  color: cs.onSurface.withAlpha(153),
                ),
              ),
              TextButton(
                onPressed: () =>
                    ref.read(recentSearchesProvider.notifier).clear(),
                child: const Text('Clear all'),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: searches.length,
            itemBuilder: (context, index) {
              final search = searches[index];
              return ListTile(
                leading: Icon(
                  Icons.history,
                  color: cs.onSurface.withAlpha(102),
                ),
                title: Text(search),
                trailing: IconButton(
                  icon: Icon(
                    Icons.close,
                    size: 18,
                    color: cs.onSurface.withAlpha(78),
                  ),
                  onPressed: () => ref
                      .read(recentSearchesProvider.notifier)
                      .removeSearch(search),
                ),
                onTap: () {
                  _searchController.text = search;
                  _searchController.selection = TextSelection.fromPosition(
                    TextPosition(offset: search.length),
                  );
                  _submitSearch(search);
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildResults(
    BuildContext context,
    AsyncValue<List<DiaryEntry>> resultsAsync,
  ) {
    return resultsAsync.when(
      data: (results) {
        var filtered = results;
        if (_moodFilter != null) {
          filtered = filtered.where((e) => e.mood == _moodFilter).toList();
        }
        if (_tagFilter != null) {
          filtered = filtered
              .where((e) => e.tags.contains(_tagFilter))
              .toList();
        }

        if (filtered.isEmpty) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.search_off,
                  size: 48,
                  color: Theme.of(context).colorScheme.onSurface.withAlpha(51),
                ),
                const SizedBox(height: 12),
                Text(
                  'No entries found',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withAlpha(102),
                  ),
                ),
              ],
            ),
          );
        }

        return ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: filtered.length,
          separatorBuilder: (_, _) => const SizedBox(height: 8),
          itemBuilder: (context, index) {
            final entry = filtered[index];
            return EntryCard(
              entry: entry,
              onTap: () => context.push('/entry/${entry.id}'),
            );
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Error: $e')),
    );
  }
}
