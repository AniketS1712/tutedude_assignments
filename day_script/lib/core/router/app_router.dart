import 'package:go_router/go_router.dart';

import 'page_transitions.dart';
import '../../screens/splash_screen.dart';
import '../../screens/home_screen.dart';
import '../../screens/entry_detail_screen.dart';
import '../../screens/entry_editor_screen.dart';
import '../../screens/calendar_screen.dart';
import '../../screens/search_screen.dart';
import '../../screens/settings_screen.dart';
import '../../screens/lock_screen.dart';

class AppRoutes {
  AppRoutes._();

  static const String splash = '/';
  static const String home = '/home';
  static const String entryDetail = '/entry/:id';
  static const String newEntry = '/entry/new';
  static const String editEntry = '/entry/:id/edit';
  static const String calendar = '/calendar';
  static const String search = '/search';
  static const String settings = '/settings';
  static const String lock = '/lock';
}

final GoRouter appRouter = GoRouter(
  initialLocation: AppRoutes.splash,
  debugLogDiagnostics: false,
  routes: [
    GoRoute(
      path: AppRoutes.splash,
      name: 'splash',
      pageBuilder: (context, state) => FadeScalePage(
        key: state.pageKey,
        name: state.name,
        child: const SplashScreen(),
      ),
    ),

    GoRoute(
      path: AppRoutes.home,
      name: 'home',
      pageBuilder: (context, state) => FadeScalePage(
        key: state.pageKey,
        name: state.name,
        child: const HomeScreen(),
      ),
    ),

    GoRoute(
      path: AppRoutes.newEntry,
      name: 'newEntry',
      pageBuilder: (context, state) => CircularRevealPage(
        key: state.pageKey,
        name: state.name,
        child: const EntryEditorScreen(),
      ),
    ),

    GoRoute(
      path: AppRoutes.entryDetail,
      name: 'entryDetail',
      pageBuilder: (context, state) {
        final id = int.parse(state.pathParameters['id']!);
        return HeroFadePage(
          key: state.pageKey,
          name: state.name,
          child: EntryDetailScreen(entryId: id),
        );
      },
    ),

    GoRoute(
      path: AppRoutes.editEntry,
      name: 'editEntry',
      pageBuilder: (context, state) {
        final id = int.parse(state.pathParameters['id']!);
        return VerticalSlideUpPage(
          key: state.pageKey,
          name: state.name,
          child: EntryEditorScreen(entryId: id),
        );
      },
    ),

    GoRoute(
      path: AppRoutes.calendar,
      name: 'calendar',
      pageBuilder: (context, state) => FadeSlideUpPage(
        key: state.pageKey,
        name: state.name,
        child: const CalendarScreen(),
      ),
    ),

    GoRoute(
      path: AppRoutes.search,
      name: 'search',
      pageBuilder: (context, state) => SlideDownFadePage(
        key: state.pageKey,
        name: state.name,
        child: const SearchScreen(),
      ),
    ),

    GoRoute(
      path: AppRoutes.settings,
      name: 'settings',
      pageBuilder: (context, state) => SlideRightPage(
        key: state.pageKey,
        name: state.name,
        child: const SettingsScreen(),
      ),
    ),

    GoRoute(
      path: AppRoutes.lock,
      name: 'lock',
      pageBuilder: (context, state) => BlurFadePage(
        key: state.pageKey,
        name: state.name,
        child: const LockScreen(),
      ),
    ),
  ],
);
