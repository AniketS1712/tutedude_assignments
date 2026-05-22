class JournalModel {
  final String title;
  final String content;
  final DateTime date;

  JournalModel({
    required this.title,
    required this.content,
    required this.date,
  });

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'content': content,
      'date': date.toIso8601String(),
    };
  }

  factory JournalModel.fromJson(Map<String, dynamic> json) {
    return JournalModel(
      title: json['title'],
      content: json['content'],
      date: DateTime.parse(json['date']),
    );
  }
}
