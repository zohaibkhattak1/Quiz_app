import 'package:flutter/material.dart';
import 'quiz_screen.dart';

class CategoryScreen extends StatefulWidget {
  final String difficulty;

  const CategoryScreen({
    super.key,
    required this.difficulty,
  });

  @override
  State<CategoryScreen> createState() => _CategoryScreenState();
}

class _CategoryScreenState extends State<CategoryScreen> {
  String? selectedCategory;

  final List<Map<String, dynamic>> categories = [
    {
      "name": "💙 Flutter",
      "id": "flutter",
    },
    {
      "name": "🎯 Dart",
      "id": "dart",
    },
    {
      "name": "🗄️ Supabase",
      "id": "supabase",
    },
    {
      "name": "🔥 Firebase",
      "id": "firebase",
    },
  ];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text(
            "Select Category",
            style: TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
          centerTitle: true,
          backgroundColor: const Color(0xff6C5CE7),
          foregroundColor: Colors.white,
        ),
        body: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color(0xffF8F9FF),
                Color(0xffE8EAF6),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
            Text(
            "Difficulty: ${widget.difficulty.toUpperCase()}",
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Color(0xff2D3436),
            ),
          ),

          const SizedBox(height: 25),

          const Text(
            "Choose Category 🎯",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color(0xff6C5CE7),
            ),
          ),

          const SizedBox(height: 30),
                  Expanded(
                    child: ListView.builder(
                      itemCount: categories.length,
                      itemBuilder: (context, index) {
                        final category = categories[index];

                        return Padding(
                          padding: const EdgeInsets.only(bottom: 15),
                          child: ElevatedButton(
                            onPressed: () {
                              setState(() {
                                selectedCategory = category["id"].toString();
                              });
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor:
                              selectedCategory == category["id"]
                                  ? Colors.green
                                  : const Color(0xff6C5CE7),
                              foregroundColor: Colors.white,
                              minimumSize: const Size(
                                double.infinity,
                                65,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                            ),
                            child: Text(
                              category["name"].toString(),
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),

                  const SizedBox(height: 20),

                  Container(
                    height: 58,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [
                          Color(0xff8E2DE2),
                          Color(0xff4A00E0),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black26,
                          blurRadius: 8,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    child: ElevatedButton.icon(
                      onPressed: selectedCategory == null
                          ? null
                          : () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => QuizScreen(
                              difficulty: widget.difficulty,
                              category: selectedCategory!,
                            ),
                          ),
                        );
                      },
                      icon: const Icon(
                        Icons.play_arrow_rounded,
                        color: Colors.white,
                      ),
                      label: const Text(
                        "Start Quiz",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        foregroundColor: Colors.white,
                        disabledBackgroundColor: Colors.grey,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                    ),
                  ),
                ],
            ),
          ),
        ),
    );
  }
}