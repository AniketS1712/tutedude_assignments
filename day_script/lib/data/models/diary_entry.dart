import 'package:isar/isar.dart';

part 'diary_entry.g.dart';

@collection
class DiaryEntry {
  Id id = Isar.autoIncrement;

  @Index()
  late String title;

  late String bodyJson;

  @Index(type: IndexType.value)
  late String bodyPlainText;

  @Index()
  late DateTime createdAt;

  late DateTime updatedAt;

  @enumerated
  late MoodEnum mood;

  @Index(type: IndexType.value)
  late List<String> tags;

  late List<String> photoPaths;

  String? locationCity;

  @Index()
  late bool isFavorite;

  late int wordCount;
}

enum MoodEnum { none, happy, sad, angry, tired, excited, anxious }
