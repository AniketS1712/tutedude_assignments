import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../core/constants/app_constants.dart';
import '../core/utils/extensions.dart';
import '../data/models/app_settings.dart';
import '../providers/providers.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = Theme.of(context).colorScheme;
    final settingsAsync = ref.watch(settingsProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Settings',
          style: GoogleFonts.playfairDisplay(
            fontSize: 24,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: settingsAsync.when(
        data: (settings) => ListView(
          padding: const EdgeInsets.symmetric(vertical: 8),
          children: [
            _sectionHeader(context, 'Appearance'),

            ListTile(
              leading: const Icon(Icons.dark_mode_outlined),
              title: const Text('Theme'),
              subtitle: Text(['System', 'Light', 'Dark'][settings.themeMode]),
              onTap: () => _showThemePicker(context, ref, settings),
            ),

            ListTile(
              leading: const Icon(Icons.palette_outlined),
              title: const Text('Accent Color'),
              trailing: Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: settings.accentColorHex.toColor,
                  shape: BoxShape.circle,
                  border: Border.all(color: cs.outline.withAlpha(78)),
                ),
              ),
              onTap: () => _showColorPicker(context, ref, settings),
            ),

            ListTile(
              leading: const Icon(Icons.text_fields_outlined),
              title: const Text('Font Size'),
              subtitle: Text(_fontSizeLabel(settings.fontSizeScale)),
              onTap: () => _showFontSizePicker(context, ref, settings),
            ),

            SwitchListTile(
              secondary: const Icon(Icons.density_small_outlined),
              title: const Text('Compact List'),
              subtitle: const Text('Show more entries on screen'),
              value: settings.listDensity == 1,
              onChanged: (v) =>
                  ref.read(settingsProvider.notifier).setListDensity(v ? 1 : 0),
            ),

            const Divider(indent: 16, endIndent: 16),

            _sectionHeader(context, 'Security'),

            SwitchListTile(
              secondary: const Icon(Icons.fingerprint),
              title: const Text('Biometric Lock'),
              subtitle: const Text('Use fingerprint or face to unlock'),
              value: settings.isBiometricEnabled,
              onChanged: (v) =>
                  ref.read(settingsProvider.notifier).setBiometricEnabled(v),
            ),

            SwitchListTile(
              secondary: const Icon(Icons.pin_outlined),
              title: const Text('PIN Lock'),
              subtitle: const Text('Set a 6-digit PIN as fallback'),
              value: settings.isPinEnabled,
              onChanged: (v) {
                if (v) {
                  _showSetPinDialog(context, ref);
                } else {
                  ref.read(settingsProvider.notifier).setPinEnabled(false);
                  ref.read(settingsProvider.notifier).setPinHash(null);
                }
              },
            ),

            ListTile(
              leading: const Icon(Icons.timer_outlined),
              title: const Text('Lock After'),
              subtitle: Text(_lockAfterLabel(settings.lockAfterMinutes)),
              enabled: settings.isBiometricEnabled || settings.isPinEnabled,
              onTap: () => _showLockTimePicker(context, ref, settings),
            ),

            const Divider(indent: 16, endIndent: 16),

            _sectionHeader(context, 'Data'),

            Consumer(
              builder: (context, ref, _) {
                final countAsync = ref.watch(entryCountProvider);
                final sizeAsync = ref.watch(databaseSizeProvider);
                return ListTile(
                  leading: const Icon(Icons.storage_outlined),
                  title: const Text('Storage'),
                  subtitle: Text(
                    '${countAsync.valueOrNull ?? 0} entries • '
                    '${_formatBytes(sizeAsync.valueOrNull ?? 0)}',
                  ),
                );
              },
            ),

            ListTile(
              leading: const Icon(Icons.download_outlined),
              title: const Text('Export as JSON'),
              subtitle: const Text('Export all entries as a JSON file'),
              onTap: () => _exportJson(context, ref),
            ),

            ListTile(
              leading: const Icon(Icons.upload_outlined),
              title: const Text('Import from Backup'),
              subtitle: const Text('Restore entries from a JSON backup'),
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Import coming soon')),
                );
              },
            ),

            const Divider(indent: 16, endIndent: 16),

            _sectionHeader(context, 'About'),

            ListTile(
              leading: const Icon(Icons.info_outline),
              title: const Text('Day Script'),
              subtitle: const Text('Version 1.0.0'),
            ),

            ListTile(
              leading: const Icon(Icons.description_outlined),
              title: const Text('Open Source Licenses'),
              onTap: () => showLicensePage(
                context: context,
                applicationName: AppConstants.appName,
                applicationVersion: '1.0.0',
              ),
            ),

            const SizedBox(height: 24),
          ],
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
    );
  }

  Widget _sectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
      child: Text(
        title.toUpperCase(),
        style: GoogleFonts.inter(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          letterSpacing: 1.2,
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
    );
  }

  String _fontSizeLabel(double scale) {
    if (scale <= 0.9) return 'Small';
    if (scale >= 1.1) return 'Large';
    return 'Medium';
  }

  String _lockAfterLabel(int minutes) {
    if (minutes == 0) return 'Never';
    if (minutes == 1) return '1 minute';
    return '$minutes minutes';
  }

  String _formatBytes(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1048576) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / 1048576).toStringAsFixed(1)} MB';
  }

  void _showThemePicker(
    BuildContext context,
    WidgetRef ref,
    AppSettings settings,
  ) {
    showDialog(
      context: context,
      builder: (ctx) => SimpleDialog(
        title: const Text('Theme'),
        children: [
          RadioGroup<int>(
            groupValue: settings.themeMode,
            onChanged: (v) {
              if (v != null) {
                ref.read(settingsProvider.notifier).setThemeMode(v);
                Navigator.pop(ctx);
              }
            },
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                for (final entry in {
                  'System': 0,
                  'Light': 1,
                  'Dark': 2,
                }.entries)
                  RadioListTile<int>(
                    title: Text(entry.key),
                    value: entry.value,
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showColorPicker(
    BuildContext context,
    WidgetRef ref,
    AppSettings settings,
  ) {
    showDialog(
      context: context,
      builder: (ctx) => SimpleDialog(
        title: const Text('Accent Color'),
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
            child: Wrap(
              spacing: 12,
              runSpacing: 12,
              children: AppConstants.accentPresets.map((hex) {
                final isSelected =
                    hex.toLowerCase() == settings.accentColorHex.toLowerCase();
                return GestureDetector(
                  onTap: () {
                    ref.read(settingsProvider.notifier).setAccentColor(hex);
                    Navigator.pop(ctx);
                  },
                  child: Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: hex.toColor,
                      shape: BoxShape.circle,
                      border: isSelected
                          ? Border.all(
                              color: Theme.of(context).colorScheme.onSurface,
                              width: 3,
                            )
                          : null,
                      boxShadow: [
                        BoxShadow(
                          color: hex.toColor.withAlpha(102),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: isSelected
                        ? const Icon(Icons.check, color: Colors.white)
                        : null,
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  void _showFontSizePicker(
    BuildContext context,
    WidgetRef ref,
    AppSettings settings,
  ) {
    showDialog(
      context: context,
      builder: (ctx) => SimpleDialog(
        title: const Text('Font Size'),
        children: [
          RadioGroup<double>(
            groupValue: settings.fontSizeScale,
            onChanged: (v) {
              if (v != null) {
                ref.read(settingsProvider.notifier).setFontSizeScale(v);
                Navigator.pop(ctx);
              }
            },
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                for (final entry in AppConstants.fontSizes.entries)
                  RadioListTile<double>(
                    title: Text(
                      entry.key[0].toUpperCase() + entry.key.substring(1),
                    ),
                    value: entry.value,
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showLockTimePicker(
    BuildContext context,
    WidgetRef ref,
    AppSettings settings,
  ) {
    showDialog(
      context: context,
      builder: (ctx) => SimpleDialog(
        title: const Text('Lock After'),
        children: [
          RadioGroup<int>(
            groupValue: settings.lockAfterMinutes,
            onChanged: (v) {
              if (v != null) {
                ref.read(settingsProvider.notifier).setLockAfterMinutes(v);
                Navigator.pop(ctx);
              }
            },
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                for (final mins in [1, 5, 15, 30, 0])
                  RadioListTile<int>(
                    title: Text(mins == 0 ? 'Never' : '$mins minutes'),
                    value: mins,
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showSetPinDialog(BuildContext context, WidgetRef ref) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Set PIN'),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          maxLength: 6,
          obscureText: true,
          decoration: const InputDecoration(
            hintText: 'Enter 6-digit PIN',
            counterText: '',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              final pin = controller.text.trim();
              if (pin.length == 6) {
                ref.read(settingsProvider.notifier).setPinEnabled(true);
                ref.read(settingsProvider.notifier).setPinHash(pin.sha256Hash);
                Navigator.pop(ctx);
              }
            },
            child: const Text('Set'),
          ),
        ],
      ),
    );
  }

  Future<void> _exportJson(BuildContext context, WidgetRef ref) async {
    try {
      final repo = ref.read(entryRepositoryProvider);
      final entries = await repo.getAllEntries();

      final jsonList = entries
          .map(
            (e) => {
              'title': e.title,
              'body': e.bodyPlainText,
              'createdAt': e.createdAt.toIso8601String(),
              'updatedAt': e.updatedAt.toIso8601String(),
              'mood': e.mood.name,
              'tags': e.tags,
              'isFavorite': e.isFavorite,
              'wordCount': e.wordCount,
              'locationCity': e.locationCity,
            },
          )
          .toList();

      final jsonStr = const JsonEncoder.withIndent('  ').convert(jsonList);

      final dir = await getApplicationDocumentsDirectory();
      final file = File(
        '${dir.path}/dear_diary_export_${DateTime.now().millisecondsSinceEpoch}.json',
      );
      await file.writeAsString(jsonStr);

      await Share.shareXFiles([XFile(file.path)], subject: 'Day Script Export');

      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Export complete!')));
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Export failed: $e')));
      }
    }
  }
}
