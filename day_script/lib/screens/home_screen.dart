import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../core/constants/app_constants.dart';
import '../core/router/app_router.dart';
import '../core/utils/date_formatter.dart';
import '../core/utils/extensions.dart';
import '../data/models/diary_entry.dart';
import '../providers/providers.dart';
import '../widgets/entry_card.dart';
import '../widgets/empty_state.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final ScrollController _scrollController = ScrollController();
  bool _isFabExtended = true;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    final isExtended = _scrollController.offset < 50;
    if (isExtended != _isFabExtended) {
      setState(() => _isFabExtended = isExtended);
    }
  }

  void _deleteEntry(DiaryEntry entry) async {
    final repo = ref.read(entryRepositoryProvider);
    await repo.deleteEntry(entry.id);
    ref.invalidate(allEntriesProvider);

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Deleted "${entry.title.isEmpty ? 'Untitled' : entry.title}"',
        ),
        action: SnackBarAction(
          label: 'Undo',
          onPressed: () async {
            await repo.saveEntry(entry);
            ref.invalidate(allEntriesProvider);
          },
        ),
        duration: const Duration(seconds: 4),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isTablet = context.isTablet;
    final navIndex = ref.watch(bottomNavIndexProvider);

    return Scaffold(
      body: _buildCurrentPage(navIndex),
      floatingActionButton: navIndex == 0 ? _buildFab(context) : null,
      bottomNavigationBar: isTablet ? null : _buildBottomNav(context, navIndex),
    );
  }

  Widget _buildCurrentPage(int index) {
    switch (index) {
      case 0:
        return _buildEntryList();
      case 1:
        WidgetsBinding.instance.addPostFrameCallback((_) {
          context.push(AppRoutes.calendar);
          ref.read(bottomNavIndexProvider.notifier).state = 0;
        });
        return _buildEntryList();
      case 2:
        WidgetsBinding.instance.addPostFrameCallback((_) {
          context.push(AppRoutes.search);
          ref.read(bottomNavIndexProvider.notifier).state = 0;
        });
        return _buildEntryList();
      case 3:
        WidgetsBinding.instance.addPostFrameCallback((_) {
          context.push(AppRoutes.settings);
          ref.read(bottomNavIndexProvider.notifier).state = 0;
        });
        return _buildEntryList();
      default:
        return _buildEntryList();
    }
  }

  Widget _buildEntryList() {
    final entriesAsync = ref.watch(allEntriesProvider);

    return entriesAsync.when(
      data: (entries) {
        if (entries.isEmpty) {
          return CustomScrollView(
            slivers: [
              _buildAppBar(),
              SliverFillRemaining(
                child: EmptyState(
                  actionLabel: 'Write your first entry',
                  onAction: () => context.push(AppRoutes.newEntry),
                ),
              ),
            ],
          );
        }

        final grouped = _groupEntriesByDate(entries);

        return CustomScrollView(
          controller: _scrollController,
          slivers: [
            _buildAppBar(),
            ...grouped.entries.expand(
              (group) => [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                    child: Text(
                      DateFormatter.groupHeader(group.key),
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Theme.of(
                          context,
                        ).colorScheme.onSurface.withAlpha(128),
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ),

                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  sliver: SliverList.separated(
                    itemCount: group.value.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 8),
                    itemBuilder: (context, index) {
                      final entry = group.value[index];
                      return EntryCard(
                        entry: entry,
                        onTap: () => context.push('/entry/${entry.id}'),
                        onDismissed: () => _deleteEntry(entry),
                      );
                    },
                  ),
                ),
              ],
            ),
            const SliverPadding(padding: EdgeInsets.only(bottom: 88)),
          ],
        );
      },
      loading: () => CustomScrollView(
        slivers: [
          _buildAppBar(),
          const SliverFillRemaining(
            child: Center(child: CircularProgressIndicator()),
          ),
        ],
      ),
      error: (error, _) => CustomScrollView(
        slivers: [
          _buildAppBar(),
          SliverFillRemaining(child: Center(child: Text('Error: $error'))),
        ],
      ),
    );
  }

  SliverAppBar _buildAppBar() {
    final colorScheme = Theme.of(context).colorScheme;
    final today = DateTime.now();

    return SliverAppBar(
      floating: true,
      snap: true,
      title: Text(
        AppConstants.appName,
        style: GoogleFonts.playfairDisplay(
          fontSize: 26,
          fontWeight: FontWeight.w700,
        ),
      ),
      actions: [
        Container(
          margin: const EdgeInsets.only(right: 8),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: colorScheme.secondaryContainer.withAlpha(128),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            DateFormatter.shortDate(today),
            style: GoogleFonts.inter(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: colorScheme.onSecondaryContainer,
            ),
          ),
        ),
        const SizedBox(width: 4),
      ],
    );
  }

  Widget _buildFab(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 200),
      transitionBuilder: (child, animation) {
        return ScaleTransition(scale: animation, child: child);
      },
      child: _isFabExtended
          ? FloatingActionButton.extended(
              key: const ValueKey('extended'),
              onPressed: () => context.push(AppRoutes.newEntry),
              icon: const Icon(Icons.edit_rounded),
              label: const Text('Write'),
            )
          : FloatingActionButton(
              key: const ValueKey('compact'),
              onPressed: () => context.push(AppRoutes.newEntry),
              child: const Icon(Icons.edit_rounded),
            ),
    );
  }

  NavigationBar _buildBottomNav(BuildContext context, int index) {
    return NavigationBar(
      selectedIndex: index,
      onDestinationSelected: (i) {
        ref.read(bottomNavIndexProvider.notifier).state = i;
      },
      destinations: const [
        NavigationDestination(
          icon: Icon(Icons.home_outlined),
          selectedIcon: Icon(Icons.home_rounded),
          label: 'Home',
        ),
        NavigationDestination(
          icon: Icon(Icons.calendar_today_outlined),
          selectedIcon: Icon(Icons.calendar_today_rounded),
          label: 'Calendar',
        ),
        NavigationDestination(
          icon: Icon(Icons.search_outlined),
          selectedIcon: Icon(Icons.search_rounded),
          label: 'Search',
        ),
        NavigationDestination(
          icon: Icon(Icons.settings_outlined),
          selectedIcon: Icon(Icons.settings_rounded),
          label: 'Settings',
        ),
      ],
    );
  }

  Map<DateTime, List<DiaryEntry>> _groupEntriesByDate(
    List<DiaryEntry> entries,
  ) {
    final Map<DateTime, List<DiaryEntry>> grouped = {};
    for (final entry in entries) {
      final dateKey = entry.createdAt.dateOnly;
      grouped.putIfAbsent(dateKey, () => []).add(entry);
    }
    return grouped;
  }
}
