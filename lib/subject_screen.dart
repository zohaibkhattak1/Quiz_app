import 'package:flutter/material.dart';

class SubjectScreen extends StatelessWidget {
  final String difficulty;
  final int selectedClass;

  const SubjectScreen({
    super.key,
    required this.difficulty,
    required this.selectedClass,
  });

  @override
  Widget build(BuildContext context) {
    final List<String> subjects = [
      "Computer",
      "Mathematics",
      "Physics",
      "Chemistry",
      "Biology",
      "English",
      "Urdu",
      "Islamiyat",
      "Pak Studies",
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text("Choose Subject"),
        centerTitle: true,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: subjects.length,
        itemBuilder: (context, index) {
          return Card(
            child: ListTile(
              leading: const Icon(Icons.menu_book),
              title: Text(subjects[index]),
              subtitle: Text(
                "Class $selectedClass • ${difficulty.toUpperCase()}",
              ),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: () {
                print("Subject: ${subjects[index]}");
              },
            ),
          );
        },
      ),
    );
  }
}