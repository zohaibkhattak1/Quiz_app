import 'package:flutter/material.dart';
import 'package:quiz_app/home_screen.dart';

void main() {
  runApp(const QuizApp());
}

class QuizApp extends StatefulWidget {
  const QuizApp({super.key});

  @override
  State<QuizApp> createState() => _QuizAppState();
}

class _QuizAppState extends State<QuizApp> {

  bool isDarkMode = false;

  void changeTheme() {
    setState(() {
      isDarkMode = !isDarkMode;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,

      title: "Quiz App",

      theme: ThemeData.light(),

      darkTheme: ThemeData.dark(),

      themeMode: isDarkMode
          ? ThemeMode.dark
          : ThemeMode.light,

      home: HomeScreen(
        changeTheme: changeTheme,
        isDarkMode: isDarkMode,
      ),
    );
  }
}