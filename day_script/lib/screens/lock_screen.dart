import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:local_auth/local_auth.dart';

import '../core/constants/app_constants.dart';
import '../core/router/app_router.dart';
import '../core/utils/extensions.dart';
import '../providers/providers.dart';

class LockScreen extends ConsumerStatefulWidget {
  const LockScreen({super.key});

  @override
  ConsumerState<LockScreen> createState() => _LockScreenState();
}

class _LockScreenState extends ConsumerState<LockScreen>
    with SingleTickerProviderStateMixin {
  final _localAuth = LocalAuthentication();
  final List<int> _pinDigits = [];
  bool _isAuthenticating = false;
  bool _wrongPin = false;
  late AnimationController _shakeController;
  late Animation<double> _shakeAnimation;

  @override
  void initState() {
    super.initState();
    _shakeController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _shakeAnimation =
        TweenSequence<double>([
          TweenSequenceItem(tween: Tween(begin: 0, end: -12), weight: 1),
          TweenSequenceItem(tween: Tween(begin: -12, end: 12), weight: 2),
          TweenSequenceItem(tween: Tween(begin: 12, end: -8), weight: 2),
          TweenSequenceItem(tween: Tween(begin: -8, end: 8), weight: 2),
          TweenSequenceItem(tween: Tween(begin: 8, end: 0), weight: 1),
        ]).animate(
          CurvedAnimation(parent: _shakeController, curve: Curves.easeInOut),
        );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _attemptBiometric();
    });
  }

  @override
  void dispose() {
    _shakeController.dispose();
    super.dispose();
  }

  Future<void> _attemptBiometric() async {
    final settings = ref.read(settingsProvider).valueOrNull;
    if (settings == null || !settings.isBiometricEnabled) return;
    if (_isAuthenticating) return;

    setState(() => _isAuthenticating = true);

    try {
      final canAuth = await _localAuth.canCheckBiometrics;
      if (!canAuth) {
        setState(() => _isAuthenticating = false);
        return;
      }

      final didAuthenticate = await _localAuth.authenticate(
        localizedReason: 'Unlock Day Script',
        options: const AuthenticationOptions(
          stickyAuth: true,
          biometricOnly: false,
        ),
      );

      if (didAuthenticate) {
        _unlock();
      }
    } catch (e) {
      debugPrint('Biometric auth error: $e');
    } finally {
      if (mounted) setState(() => _isAuthenticating = false);
    }
  }

  void _onPinDigit(int digit) {
    if (_pinDigits.length >= AppConstants.pinLength) return;
    HapticFeedback.lightImpact();

    setState(() {
      _pinDigits.add(digit);
      _wrongPin = false;
    });

    if (_pinDigits.length == AppConstants.pinLength) {
      _verifyPin();
    }
  }

  void _onBackspace() {
    if (_pinDigits.isEmpty) return;
    HapticFeedback.lightImpact();
    setState(() {
      _pinDigits.removeLast();
      _wrongPin = false;
    });
  }

  void _verifyPin() {
    final settings = ref.read(settingsProvider).valueOrNull;
    if (settings == null) return;

    final enteredPin = _pinDigits.join();
    final pinHash = enteredPin.sha256Hash;

    if (pinHash == settings.pinHash) {
      _unlock();
    } else {
      HapticFeedback.heavyImpact();
      setState(() {
        _wrongPin = true;
        _pinDigits.clear();
      });
      _shakeController.forward(from: 0);
    }
  }

  void _unlock() {
    ref.read(isLockedProvider.notifier).state = false;
    ref.read(needsAuthProvider.notifier).state = false;
    ref.read(settingsProvider.notifier).setLastUnlockedAt(DateTime.now());

    if (mounted) {
      context.go(AppRoutes.home);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final settings = ref.watch(settingsProvider).valueOrNull;
    final showPin = settings?.isPinEnabled ?? false;

    return Scaffold(
      body: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          width: double.infinity,
          height: double.infinity,
          color: cs.surface.withAlpha(217),
          child: SafeArea(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Spacer(flex: 2),

                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: cs.primaryContainer,
                    borderRadius: BorderRadius.circular(22),
                  ),
                  child: Icon(
                    Icons.auto_stories_rounded,
                    size: 40,
                    color: cs.primary,
                  ),
                ),

                const SizedBox(height: 24),

                Text(
                  'Welcome back',
                  style: GoogleFonts.playfairDisplay(
                    fontSize: 28,
                    fontWeight: FontWeight.w700,
                    color: cs.onSurface,
                  ),
                ),

                const SizedBox(height: 8),

                Text(
                  settings?.isBiometricEnabled == true
                      ? 'Use biometrics or enter your PIN'
                      : 'Enter your PIN to unlock',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    color: cs.onSurface.withAlpha(128),
                  ),
                ),

                const SizedBox(height: 40),

                if (showPin)
                  AnimatedBuilder(
                    animation: _shakeAnimation,
                    builder: (context, child) {
                      return Transform.translate(
                        offset: Offset(_shakeAnimation.value, 0),
                        child: child,
                      );
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(AppConstants.pinLength, (i) {
                        final filled = i < _pinDigits.length;
                        return AnimatedContainer(
                          duration: const Duration(milliseconds: 150),
                          margin: const EdgeInsets.symmetric(horizontal: 8),
                          width: 16,
                          height: 16,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: _wrongPin
                                ? cs.error
                                : filled
                                ? cs.primary
                                : cs.outline.withAlpha(78),
                            border: Border.all(
                              color: _wrongPin
                                  ? cs.error
                                  : filled
                                  ? cs.primary
                                  : cs.outline.withAlpha(78),
                              width: 2,
                            ),
                          ),
                        );
                      }),
                    ),
                  ),

                if (_wrongPin) ...[
                  const SizedBox(height: 12),
                  Text(
                    'Wrong PIN',
                    style: TextStyle(color: cs.error, fontSize: 13),
                  ),
                ],

                const SizedBox(height: 32),

                if (showPin) _buildNumberPad(context),

                const Spacer(),

                if (settings?.isBiometricEnabled == true)
                  TextButton.icon(
                    onPressed: _isAuthenticating ? null : _attemptBiometric,
                    icon: const Icon(Icons.fingerprint, size: 28),
                    label: const Text('Use Biometrics'),
                  ),

                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNumberPad(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    Widget numButton(int num) {
      return Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _onPinDigit(num),
          borderRadius: BorderRadius.circular(40),
          child: Container(
            width: 72,
            height: 72,
            alignment: Alignment.center,
            child: Text(
              '$num',
              style: GoogleFonts.inter(
                fontSize: 28,
                fontWeight: FontWeight.w400,
                color: cs.onSurface,
              ),
            ),
          ),
        ),
      );
    }

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [numButton(1), numButton(2), numButton(3)],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [numButton(4), numButton(5), numButton(6)],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [numButton(7), numButton(8), numButton(9)],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(width: 72, height: 72),
            numButton(0),
            SizedBox(
              width: 72,
              height: 72,
              child: IconButton(
                onPressed: _onBackspace,
                icon: Icon(
                  Icons.backspace_outlined,
                  color: cs.onSurface.withAlpha(153),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
