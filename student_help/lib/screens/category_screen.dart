import 'package:flutter/material.dart';
import '../models/data_models.dart';
import 'topic_list_screen.dart';

class CategoryScreen extends StatelessWidget {
  const CategoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final List<List<Color>> gradients = [
      [const Color(0xFFFF9A9E), const Color(0xFF873B6F)],
      [const Color(0xFFa18cd1), const Color(0xFF85376F)],
      [const Color(0xFF84fab0), const Color(0xFF2C556A)],
      [const Color(0xFFfccb90), const Color(0xFF754D7E)],
      [const Color(0xFFe0c3fc), const Color(0xFF4A6A8A)],
      [const Color(0xFF4facfe), const Color(0xFF007980)],
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Student Help Center',
          style: TextStyle(fontWeight: FontWeight.w800, letterSpacing: 1.2),
        ),
        centerTitle: true,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        foregroundColor: Colors.white,
      ),
      body: Container(
        color: Theme.of(context).scaffoldBackgroundColor,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: GridView.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.9,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
            ),
            itemCount: staticCategories.length,
            itemBuilder: (context, index) {
              final category = staticCategories[index];
              final gradient = gradients[index % gradients.length];

              return InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => TopicListScreen(
                        category: category,
                        themeGradient: gradient,
                      ),
                    ),
                  );
                },
                borderRadius: BorderRadius.circular(24),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(24),
                    gradient: LinearGradient(
                      colors: gradient,
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: gradient.last.withOpacity(0.4),
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.3),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          _getIconForCategory(category.name),
                          size: 48,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        category.name,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  IconData _getIconForCategory(String name) {
    switch (name) {
      case 'Study Tips':
        return Icons.menu_book;
      case 'Time Management':
        return Icons.access_time;
      case 'Exam Preparation':
        return Icons.assignment;
      case 'Concentration':
        return Icons.psychology;
      case 'Motivation':
        return Icons.emoji_events;
      case 'Career Guidance':
        return Icons.explore;
      default:
        return Icons.help_outline;
    }
  }
}
