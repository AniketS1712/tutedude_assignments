import 'package:flutter/material.dart';
import 'screens/category_screen.dart';

void main() {
  runApp(const StudentHelpApp());
}

class StudentHelpApp extends StatelessWidget {
  const StudentHelpApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Student Help',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.deepPurple,
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
        appBarTheme: const AppBarTheme(centerTitle: true, elevation: 0),
        cardTheme: const CardThemeData(clipBehavior: Clip.antiAlias),
      ),
      home: const CategoryScreen(),
    );
  }
}
