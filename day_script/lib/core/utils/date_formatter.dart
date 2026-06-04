import 'package:intl/intl.dart';

class DateFormatter {
  DateFormatter._();

  static final DateFormat _fullDate = DateFormat('MMMM d, yyyy');
  static final DateFormat _shortDate = DateFormat('MMM d');
  static final DateFormat _time = DateFormat('h:mm a');
  static final DateFormat _dayOfWeek = DateFormat('EEEE');
  static final DateFormat _monthYear = DateFormat('MMMM yyyy');
  static final DateFormat _yearMonthDay = DateFormat('yyyy-MM-dd');

  static String relative(DateTime dateTime) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final date = DateTime(dateTime.year, dateTime.month, dateTime.day);

    final diff = today.difference(date).inDays;

    if (diff == 0) {
      return 'Today ${_time.format(dateTime)}';
    } else if (diff == 1) {
      return 'Yesterday ${_time.format(dateTime)}';
    } else if (diff < 7) {
      return '${_dayOfWeek.format(dateTime)} ${_time.format(dateTime)}';
    } else {
      return '${_fullDate.format(dateTime)} ${_time.format(dateTime)}';
    }
  }

  static String fullDate(DateTime dateTime) => _fullDate.format(dateTime);

  static String shortDate(DateTime dateTime) => _shortDate.format(dateTime);

  static String time(DateTime dateTime) => _time.format(dateTime);

  static String monthYear(DateTime dateTime) => _monthYear.format(dateTime);

  static String isoDate(DateTime dateTime) => _yearMonthDay.format(dateTime);

  static String groupHeader(DateTime dateTime) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final date = DateTime(dateTime.year, dateTime.month, dateTime.day);

    final diff = today.difference(date).inDays;
    if (diff == 0) return 'Today';
    if (diff == 1) return 'Yesterday';
    return _fullDate.format(dateTime);
  }

  static String readingTime(int wordCount) {
    final minutes = (wordCount / 200).ceil();
    if (minutes <= 0) return 'Less than a minute';
    if (minutes == 1) return '1 min read';
    return '$minutes min read';
  }
}
