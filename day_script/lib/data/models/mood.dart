enum Mood {
  none('None', '😶', 0xFF9E9E9E),
  happy('Happy', '😊', 0xFF4CAF50),
  sad('Sad', '😢', 0xFF2196F3),
  angry('Angry', '😡', 0xFFF44336),
  tired('Tired', '😴', 0xFF9C27B0),
  excited('Excited', '🤩', 0xFFFF9800),
  anxious('Anxious', '😰', 0xFFFF5722);

  const Mood(this.label, this.emoji, this.colorValue);

  final String label;
  final String emoji;
  final int colorValue;
}
