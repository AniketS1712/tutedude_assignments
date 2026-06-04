import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

import '../core/utils/date_formatter.dart';
import '../data/models/diary_entry.dart';
import '../data/models/mood.dart';
import '../providers/providers.dart';
import '../widgets/mood_picker.dart';

class EntryEditorScreen extends ConsumerStatefulWidget {
  final int? entryId;
  const EntryEditorScreen({super.key, this.entryId});

  @override
  ConsumerState<EntryEditorScreen> createState() => _EntryEditorScreenState();
}

class _EntryEditorScreenState extends ConsumerState<EntryEditorScreen> {
  final _titleController = TextEditingController();
  final _bodyController = TextEditingController();
  final _tagController = TextEditingController();

  Mood _selectedMood = Mood.none;
  List<String> _tags = [];
  List<String> _photoPaths = [];
  String? _locationCity;
  bool _hasChanges = false;
  bool _isSaving = false;
  Timer? _autoSaveTimer;
  DiaryEntry? _existingEntry;

  bool get _isEditing => widget.entryId != null;
  bool get _hasContent =>
      _titleController.text.trim().isNotEmpty ||
      _bodyController.text.trim().isNotEmpty;

  @override
  void initState() {
    super.initState();
    if (_isEditing) _loadEntry();
    _titleController.addListener(_onContentChanged);
    _bodyController.addListener(_onContentChanged);
    _startAutoSave();
  }

  void _startAutoSave() {
    _autoSaveTimer = Timer.periodic(const Duration(seconds: 30), (_) {
      if (_hasChanges && _hasContent) _saveEntry(showFeedback: false);
    });
  }

  void _onContentChanged() {
    if (!_hasChanges) setState(() => _hasChanges = true);
  }

  Future<void> _loadEntry() async {
    final repo = ref.read(entryRepositoryProvider);
    final entry = await repo.getEntry(widget.entryId!);
    if (entry != null && mounted) {
      setState(() {
        _existingEntry = entry;
        _titleController.text = entry.title;
        _bodyController.text = entry.bodyPlainText;
        _selectedMood = Mood.values[entry.mood.index];
        _tags = List.from(entry.tags);
        _photoPaths = List.from(entry.photoPaths);
        _locationCity = entry.locationCity;
        _hasChanges = false;
      });
    }
  }

  @override
  void dispose() {
    _autoSaveTimer?.cancel();
    _titleController.dispose();
    _bodyController.dispose();
    _tagController.dispose();
    super.dispose();
  }

  int get _wordCount {
    final text = _bodyController.text.trim();
    if (text.isEmpty) return 0;
    return text.split(RegExp(r'\s+')).length;
  }

  Future<void> _saveEntry({bool showFeedback = true}) async {
    if (_isSaving) return;
    setState(() => _isSaving = true);

    try {
      final repo = ref.read(entryRepositoryProvider);
      final now = DateTime.now();

      final entry = _existingEntry ?? DiaryEntry();
      entry.title = _titleController.text.trim();
      entry.bodyJson = _bodyController.text;
      entry.bodyPlainText = _bodyController.text.trim();
      entry.mood = MoodEnum.values[_selectedMood.index];
      entry.tags = _tags;
      entry.photoPaths = _photoPaths;
      entry.locationCity = _locationCity;
      entry.wordCount = _wordCount;
      entry.updatedAt = now;

      if (!_isEditing && _existingEntry == null) {
        entry.createdAt = now;
        entry.isFavorite = false;
      }

      final id = await repo.saveEntry(entry);
      _existingEntry = entry..id = id;

      final tagRepo = ref.read(tagRepositoryProvider);
      for (final tag in _tags) {
        await tagRepo.getOrCreateTag(tag);
        await tagRepo.incrementUsage(tag);
      }

      ref.invalidate(allEntriesProvider);
      ref.invalidate(allTagsProvider);
      setState(() => _hasChanges = false);

      if (showFeedback && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Entry saved'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final image = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1920,
      maxHeight: 1920,
      imageQuality: 85,
    );
    if (image == null) return;

    final appDir = await getApplicationDocumentsDirectory();
    final photoDir = Directory('${appDir.path}/photos');
    if (!await photoDir.exists()) await photoDir.create(recursive: true);

    final fileName =
        '${DateTime.now().millisecondsSinceEpoch}_${p.basename(image.path)}';
    final savedFile = await File(image.path).copy('${photoDir.path}/$fileName');

    setState(() {
      _photoPaths.add(savedFile.path);
      _hasChanges = true;
    });
  }

  Future<void> _takePhoto() async {
    final picker = ImagePicker();
    final image = await picker.pickImage(
      source: ImageSource.camera,
      maxWidth: 1920,
      maxHeight: 1920,
      imageQuality: 85,
    );
    if (image == null) return;

    final appDir = await getApplicationDocumentsDirectory();
    final photoDir = Directory('${appDir.path}/photos');
    if (!await photoDir.exists()) await photoDir.create(recursive: true);

    final fileName = '${DateTime.now().millisecondsSinceEpoch}.jpg';
    final savedFile = await File(image.path).copy('${photoDir.path}/$fileName');

    setState(() {
      _photoPaths.add(savedFile.path);
      _hasChanges = true;
    });
  }

  void _removePhoto(int index) {
    setState(() {
      _photoPaths.removeAt(index);
      _hasChanges = true;
    });
  }

  void _addTag(String tag) {
    final trimmed = tag.trim();
    if (trimmed.isEmpty || _tags.contains(trimmed)) return;
    setState(() {
      _tags.add(trimmed);
      _hasChanges = true;
    });
    _tagController.clear();
  }

  void _removeTag(String tag) {
    setState(() {
      _tags.remove(tag);
      _hasChanges = true;
    });
  }

  Future<bool> _onWillPop() async {
    if (!_hasChanges) return true;
    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Unsaved Changes'),
        content: const Text('You have unsaved changes. Save before leaving?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Discard'),
          ),
          FilledButton(
            onPressed: () async {
              await _saveEntry(showFeedback: false);
              if (ctx.mounted) Navigator.pop(ctx, true);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return PopScope(
      canPop: !_hasChanges,
      onPopInvokedWithResult: (didPop, _) async {
        if (!didPop) {
          final shouldPop = await _onWillPop();
          if (shouldPop && context.mounted) Navigator.of(context).pop();
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(_isEditing ? 'Edit Entry' : 'New Entry'),
          actions: [
            if (_isSaving)
              const Center(
                child: Padding(
                  padding: EdgeInsets.only(right: 16),
                  child: SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                ),
              )
            else
              TextButton.icon(
                onPressed: _hasContent
                    ? () async {
                        await _saveEntry();
                        if (context.mounted) context.pop();
                      }
                    : null,
                icon: const Icon(Icons.check_rounded, size: 18),
                label: const Text('Save'),
              ),
          ],
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: _titleController,
                style: GoogleFonts.playfairDisplay(
                  fontSize: 28,
                  fontWeight: FontWeight.w600,
                  color: cs.onSurface,
                ),
                decoration: InputDecoration(
                  hintText: 'Title',
                  hintStyle: GoogleFonts.playfairDisplay(
                    fontSize: 28,
                    fontWeight: FontWeight.w600,
                    color: cs.onSurface.withAlpha(78),
                  ),
                  border: InputBorder.none,
                  filled: false,
                  contentPadding: const EdgeInsets.symmetric(vertical: 8),
                ),
                maxLines: 1,
                textCapitalization: TextCapitalization.sentences,
              ),

              const SizedBox(height: 4),

              TextField(
                controller: _bodyController,
                style: GoogleFonts.inter(
                  fontSize: 16,
                  height: 1.7,
                  color: cs.onSurface.withAlpha(216),
                ),
                decoration: InputDecoration(
                  hintText: 'Start writing...',
                  hintStyle: GoogleFonts.inter(
                    fontSize: 16,
                    color: cs.onSurface.withAlpha(78),
                  ),
                  border: InputBorder.none,
                  filled: false,
                  contentPadding: EdgeInsets.zero,
                ),
                maxLines: null,
                minLines: 10,
                keyboardType: TextInputType.multiline,
                textCapitalization: TextCapitalization.sentences,
              ),

              const SizedBox(height: 16),

              if (_photoPaths.isNotEmpty) ...[
                SizedBox(
                  height: 100,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: _photoPaths.length,
                    separatorBuilder: (_, _) => const SizedBox(width: 8),
                    itemBuilder: (context, index) {
                      return Stack(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: Image.file(
                              File(_photoPaths[index]),
                              width: 100,
                              height: 100,
                              fit: BoxFit.cover,
                              errorBuilder: (_, _, _) => Container(
                                width: 100,
                                height: 100,
                                color: cs.surfaceContainerHighest,
                                child: const Icon(Icons.broken_image),
                              ),
                            ),
                          ),
                          Positioned(
                            top: 4,
                            right: 4,
                            child: GestureDetector(
                              onLongPress: () => _removePhoto(index),
                              child: Container(
                                padding: const EdgeInsets.all(4),
                                decoration: const BoxDecoration(
                                  color: Colors.black54,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.close,
                                  size: 14,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
                const SizedBox(height: 16),
              ],

              Text(
                'How are you feeling?',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  color: cs.onSurface.withAlpha(153),
                ),
              ),
              const SizedBox(height: 8),
              MoodPicker(
                selectedMood: _selectedMood,
                onMoodSelected: (mood) {
                  setState(() {
                    _selectedMood = mood;
                    _hasChanges = true;
                  });
                },
              ),

              const SizedBox(height: 20),

              Text(
                'Tags',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  color: cs.onSurface.withAlpha(153),
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: [
                  ..._tags.map(
                    (tag) => Chip(
                      label: Text(tag),
                      onDeleted: () => _removeTag(tag),
                      visualDensity: VisualDensity.compact,
                    ),
                  ),
                  SizedBox(
                    width: 120,
                    child: TextField(
                      controller: _tagController,
                      style: Theme.of(context).textTheme.bodySmall,
                      decoration: InputDecoration(
                        hintText: 'Add tag...',
                        isDense: true,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(
                            color: cs.outline.withAlpha(78),
                          ),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 8,
                        ),
                      ),
                      onSubmitted: _addTag,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              Row(
                children: [
                  Icon(
                    Icons.text_fields,
                    size: 14,
                    color: cs.onSurface.withAlpha(102),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '$_wordCount words • ${DateFormatter.readingTime(_wordCount)}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: cs.onSurface.withAlpha(102),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 80),
            ],
          ),
        ),

        bottomNavigationBar: Container(
          decoration: BoxDecoration(
            color: cs.surface,
            border: Border(
              top: BorderSide(color: cs.outlineVariant.withAlpha(78)),
            ),
          ),
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).padding.bottom,
            left: 8,
            right: 8,
            top: 4,
          ),
          child: Row(
            children: [
              IconButton(
                icon: const Icon(Icons.image_outlined),
                tooltip: 'Add photo from gallery',
                onPressed: _pickImage,
              ),
              IconButton(
                icon: const Icon(Icons.camera_alt_outlined),
                tooltip: 'Take photo',
                onPressed: _takePhoto,
              ),
              IconButton(
                icon: const Icon(Icons.format_bold_rounded),
                tooltip: 'Formatting (coming soon)',
                onPressed: () {},
              ),
              const Spacer(),
              if (_hasChanges)
                Text(
                  'Edited',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: cs.primary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
