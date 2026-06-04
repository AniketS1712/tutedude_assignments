import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'core/constants/app_constants.dart';
import 'core/utils/extensions.dart';
import 'providers/providers.dart';

class DearDiaryApp extends ConsumerStatefulWidget {
  const DearDiaryApp({super.key});

  @override
  ConsumerState<DearDiaryApp> createState() => _DearDiaryAppState();
}

class _DearDiaryAppState extends ConsumerState<DearDiaryApp>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    final settings = ref.read(settingsProvider).valueOrNull;
    if (settings == null) return;

    final lockEnabled = settings.isBiometricEnabled || settings.isPinEnabled;
    if (!lockEnabled) return;

    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive) {
      ref.read(needsAuthProvider.notifier).state = true;
    } else if (state == AppLifecycleState.resumed) {
      final needsAuth = ref.read(needsAuthProvider);
      if (needsAuth) {
        final lastUnlocked = settings.lastUnlockedAt;
        final lockMinutes = settings.lockAfterMinutes;

        if (lockMinutes == 0) {
          ref.read(needsAuthProvider.notifier).state = false;
          return;
        }

        if (lastUnlocked != null) {
          final elapsed = DateTime.now().difference(lastUnlocked).inMinutes;
          if (elapsed < lockMinutes) {
            ref.read(needsAuthProvider.notifier).state = false;
            return;
          }
        }

        ref.read(isLockedProvider.notifier).state = true;
        appRouter.go(AppRoutes.lock);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final settingsAsync = ref.watch(settingsProvider);

    return settingsAsync.when(
      data: (settings) {
        final seedColor = settings.accentColorHex.toColor;
        final themeMode = switch (settings.themeMode) {
          1 => ThemeMode.light,
          2 => ThemeMode.dark,
          _ => ThemeMode.system,
        };

        return MaterialApp.router(
          title: AppConstants.appName,
          debugShowCheckedModeBanner: false,
          theme: AppTheme.light(seedColor: seedColor),
          darkTheme: AppTheme.dark(seedColor: seedColor),
          themeMode: themeMode,
          routerConfig: appRouter,
          builder: (context, child) {
            final mediaQuery = MediaQuery.of(context);
            final clampedScale = mediaQuery.textScaler.clamp();
            return MediaQuery(
              data: mediaQuery.copyWith(textScaler: clampedScale),
              child: child ?? const SizedBox.shrink(),
            );
          },
        );
      },
      loading: () => MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light(),
        home: const Scaffold(body: Center(child: CircularProgressIndicator())),
      ),
      error: (error, stack) => MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light(),
        home: Scaffold(body: Center(child: Text('Error: $error'))),
      ),
    );
  }
}
