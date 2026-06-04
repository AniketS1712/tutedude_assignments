import 'package:isar/isar.dart';

import '../models/tag.dart';

class TagRepository {
  final Isar _isar;

  TagRepository(this._isar);

  Future<List<Tag>> getAllTags() async {
    return _isar.tags.where().sortByUsageCountDesc().findAll();
  }

  Future<Tag> getOrCreateTag(String name, {String colorHex = '#E8A838'}) async {
    final existing = await _isar.tags
        .where()
        .filter()
        .nameEqualTo(name, caseSensitive: false)
        .findFirst();

    if (existing != null) return existing;

    final tag = Tag()
      ..name = name
      ..colorHex = colorHex
      ..usageCount = 0;

    await _isar.writeTxn(() async {
      await _isar.tags.put(tag);
    });

    return tag;
  }

  Future<void> incrementUsage(String name) async {
    final tag = await _isar.tags
        .where()
        .filter()
        .nameEqualTo(name, caseSensitive: false)
        .findFirst();

    if (tag != null) {
      tag.usageCount++;
      await _isar.writeTxn(() async {
        await _isar.tags.put(tag);
      });
    }
  }

  Future<void> decrementUsage(String name) async {
    final tag = await _isar.tags
        .where()
        .filter()
        .nameEqualTo(name, caseSensitive: false)
        .findFirst();

    if (tag != null) {
      tag.usageCount = (tag.usageCount - 1).clamp(0, tag.usageCount);
      await _isar.writeTxn(() async {
        await _isar.tags.put(tag);
      });
    }
  }

  Future<bool> deleteTag(int id) async {
    return _isar.writeTxn(() async {
      return _isar.tags.delete(id);
    });
  }

  Future<List<Tag>> searchTags(String query) async {
    if (query.isEmpty) return getAllTags();
    return _isar.tags
        .where()
        .filter()
        .nameContains(query, caseSensitive: false)
        .sortByUsageCountDesc()
        .findAll();
  }
}
