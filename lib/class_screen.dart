import 'package:flutter/material.dart';
import 'subject_screen.dart';

class ClassScreen extends StatefulWidget {
  final String difficulty;

  const ClassScreen({
    super.key,
    required this.difficulty,
  });

  @override
  State<ClassScreen> createState() => _ClassScreenState();
}

class _ClassScreenState extends State<ClassScreen> {
  int? selectedClass;

  final List<Map<String, dynamic>> classes = [
    {
      'classNumber': 9,
      'title': '9th Class',
      'subtitle': 'Matric Part 1',
      'icon': Icons.school_rounded,
    },
    {
      'classNumber': 10,
      'title': '10th Class',
      'subtitle': 'Matric Part 2',
      'icon': Icons.menu_book_rounded,
    },
    {
      'classNumber': 11,
      'title': '11th Class',
      'subtitle': 'Intermediate Part 1',
      'icon': Icons.auto_stories_rounded,
    },
    {
      'classNumber': 12,
      'title': '12th Class',
      'subtitle': 'Intermediate Part 2',
      'icon': Icons.workspace_premium_rounded,
    },
  ];

  void selectClass(int classNumber) {
    setState(() {
      selectedClass = classNumber;
    });

    debugPrint('Selected difficulty: ${widget.difficulty}');
    debugPrint('Selected class: $classNumber');

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SubjectScreen(
          difficulty: widget.difficulty,
          selectedClass: classNumber,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isDarkMode =
        Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Select Your Class',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: isDarkMode
              ? const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF171123),
              Color(0xFF241B35),
            ],
          )
              : const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFFF5F0FF),
              Color(0xFFE8DFFF),
            ],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                Text(
                  'Difficulty: ${widget.difficulty.toUpperCase()}',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: isDarkMode
                        ? Colors.white70
                        : const Color(0xFF6D4FC2),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Which class do you study in?',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: isDarkMode
                        ? Colors.white
                        : const Color(0xFF291B4D),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Select your class to continue',
                  style: TextStyle(
                    fontSize: 15,
                    color: isDarkMode
                        ? Colors.white60
                        : Colors.black54,
                  ),
                ),
                const SizedBox(height: 30),
                Expanded(
                  child: ListView.separated(
                    itemCount: classes.length,
                    separatorBuilder: (context, index) {
                      return const SizedBox(height: 16);
                    },
                    itemBuilder: (context, index) {
                      final classData = classes[index];

                      final int classNumber =
                      classData['classNumber'] as int;

                      final bool isSelected =
                          selectedClass == classNumber;

                      return InkWell(
                        borderRadius: BorderRadius.circular(22),
                        onTap: () {
                          selectClass(classNumber);
                        },
                        child: AnimatedContainer(
                          duration: const Duration(
                            milliseconds: 250,
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 18,
                            vertical: 20,
                          ),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? const Color(0xFF7654D1)
                                : isDarkMode
                                ? const Color(0xFF2B2340)
                                : Colors.white,
                            borderRadius: BorderRadius.circular(22),
                            border: Border.all(
                              color: isSelected
                                  ? const Color(0xFF9A7EF0)
                                  : isDarkMode
                                  ? Colors.white12
                                  : const Color(0xFFE4D9FF),
                              width: 1.5,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(
                                  alpha: 0.08,
                                ),
                                blurRadius: 12,
                                offset: const Offset(0, 6),
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              Container(
                                height: 58,
                                width: 58,
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? Colors.white.withValues(
                                    alpha: 0.18,
                                  )
                                      : const Color(0xFFECE4FF),
                                  borderRadius:
                                  BorderRadius.circular(18),
                                ),
                                child: Icon(
                                  classData['icon'] as IconData,
                                  size: 30,
                                  color: isSelected
                                      ? Colors.white
                                      : const Color(0xFF7654D1),
                                ),
                              ),
                              const SizedBox(width: 18),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment:
                                  CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      classData['title'] as String,
                                      style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                        color: isSelected
                                            ? Colors.white
                                            : isDarkMode
                                            ? Colors.white
                                            : const Color(
                                          0xFF291B4D,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 5),
                                    Text(
                                      classData['subtitle'] as String,
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: isSelected
                                            ? Colors.white70
                                            : isDarkMode
                                            ? Colors.white60
                                            : Colors.black54,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Icon(
                                isSelected
                                    ? Icons.check_circle_rounded
                                    : Icons.arrow_forward_ios_rounded,
                                color: isSelected
                                    ? Colors.white
                                    : const Color(0xFF7654D1),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}