class Category {
  final String id;
  final String name;
  final List<HelpTopic> topics;

  const Category({
    required this.id,
    required this.name,
    required this.topics,
  });
}

class HelpTopic {
  final String title;
  final List<String> instructions;

  const HelpTopic({
    required this.title,
    required this.instructions,
  });
}

const List<Category> staticCategories = [
  Category(
    id: '1',
    name: 'Study Tips',
    topics: [
      HelpTopic(
        title: 'Make Notes',
        instructions: [
          'Write only important points',
          'Use headings and bullet points',
          'Highlight keywords',
          'Revise notes weekly',
        ],
      ),
      HelpTopic(
        title: 'Revise Daily',
        instructions: [
          'Review what you learned today before sleeping',
          'Spend 15-20 minutes on quick recall',
          'Use flashcards for difficult concepts',
        ],
      ),
      HelpTopic(
        title: 'Practice Questions',
        instructions: [
          'Solve previous years past papers',
          'Take mock tests regularly',
          'Analyze mistakes and learn from them',
        ],
      ),
      HelpTopic(
        title: 'Avoid Distractions',
        instructions: [
          'Keep your phone in another room or on silent mode',
          'Study in a quiet and well-lit place',
          'Use website blockers if studying online',
        ],
      ),
    ],
  ),
  Category(
    id: '2',
    name: 'Time Management',
    topics: [
      HelpTopic(
        title: 'Create Timetable',
        instructions: [
          'Allocate specific time slots for each subject',
          'Include short breaks between study sessions',
          'Stick to your schedule as strictly as possible',
        ],
      ),
      HelpTopic(
        title: 'Set Priorities',
        instructions: [
          'Identify the most important and urgent tasks',
          'Tackle the difficult subjects when you are most energetic',
          'Avoid multitasking to maintain focus',
        ],
      ),
      HelpTopic(
        title: 'Take Short Breaks',
        instructions: [
          'Use the Pomodoro technique (25 min study, 5 min break)',
          'Stretch or walk around during breaks',
          'Avoid screen time during your break periods',
        ],
      ),
      HelpTopic(
        title: 'Avoid Procrastination',
        instructions: [
          'Break large tasks into smaller, manageable steps',
          'Set early self-imposed deadlines',
          'Reward yourself after completing tasks',
        ],
      ),
    ],
  ),
  Category(
    id: '3',
    name: 'Exam Preparation',
    topics: [
      HelpTopic(
        title: 'Understand the Syllabus',
        instructions: [
          'Go through the entire syllabus before starting',
          'Mark topics based on their weightage',
          'Do not skip any important sections',
        ],
      ),
      HelpTopic(
        title: 'Healthy Diet and Sleep',
        instructions: [
          'Get at least 7-8 hours of sleep before the exam',
          'Eat healthy, light meals to stay active',
          'Stay hydrated throughout your study sessions',
        ],
      ),
      HelpTopic(
        title: 'Exam Day Strategy',
        instructions: [
          'Reach the exam center early to avoid panic',
          'Read all instructions on the question paper carefully',
          'Manage your time well during the exam',
        ],
      ),
    ],
  ),
  Category(
    id: '4',
    name: 'Concentration',
    topics: [
      HelpTopic(
        title: 'Meditation',
        instructions: [
          'Meditate for 10 minutes every morning',
          'Focus on your breathing to clear your mind',
          'Practice mindfulness throughout the day',
        ],
      ),
      HelpTopic(
        title: 'Active Listening',
        instructions: [
          'Pay close attention during lectures',
          'Take running notes to stay engaged',
          'Ask questions if you have doubts',
        ],
      ),
    ],
  ),
  Category(
    id: '5',
    name: 'Motivation',
    topics: [
      HelpTopic(
        title: 'Set Clear Goals',
        instructions: [
          'Define both short-term and long-term goals',
          'Write down your goals and place them where visible',
          'Track your progress regularly',
        ],
      ),
      HelpTopic(
        title: 'Stay Positive',
        instructions: [
          'Surround yourself with supportive friends',
          'Read or watch motivational content',
          'Do not let minor setbacks discourage you',
        ],
      ),
    ],
  ),
  Category(
    id: '6',
    name: 'Career Guidance',
    topics: [
      HelpTopic(
        title: 'Self-Assessment',
        instructions: [
          'Identify your strengths, interests, and skills',
          'Take online career aptitude tests',
          'Reflect on subjects you enjoy the most',
        ],
      ),
      HelpTopic(
        title: 'Explore Options',
        instructions: [
          'Research various career paths related to your interests',
          'Talk to professionals in fields you are considering',
          'Look for internships or shadowing opportunities',
        ],
      ),
    ],
  ),
];
