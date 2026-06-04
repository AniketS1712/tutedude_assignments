import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';

import '../constants/app_constants.dart';

extension BuildContextExtensions on BuildContext {
  ThemeData get theme => Theme.of(this);
  ColorScheme get colorScheme => theme.colorScheme;
  TextTheme get textTheme => theme.textTheme;
  MediaQueryData get mq => MediaQuery.of(this);
  double get screenWidth => mq.size.width;
  double get screenHeight => mq.size.height;
  bool get isTablet => screenWidth >= AppConstants.tabletBreakpoint;
  bool get isLandscape => mq.orientation == Orientation.landscape;
  bool get reduceMotion => mq.disableAnimations;
}

extension StringExtensions on String {
  String get sha256Hash {
    final bytes = utf8.encode(this);
    return sha256.convert(bytes).toString();
  }

  Color get toColor {
    String hex = replaceFirst('#', '');
    if (hex.length == 6) hex = 'FF$hex';
    return Color(int.parse(hex, radix: 16));
  }
}

extension ColorExtensions on Color {
  String get toHex {
    return '#${toARGB32().toRadixString(16).padLeft(8, '0').substring(2).toUpperCase()}';
  }
}

extension DateTimeExtensions on DateTime {
  DateTime get dateOnly => DateTime(year, month, day);

  bool isSameDay(DateTime other) {
    return year == other.year && month == other.month && day == other.day;
  }
}
