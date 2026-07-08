import 'package:flutter/material.dart';
import 'package:quiz_app/home_screen.dart';
import 'package:quiz_app/quiz_provider.dart';
import 'package:provider/provider.dart';
import 'package:quiz_app/theme_provider.dart';

void main() {
  runApp
    (
      MultiProvider(
        providers: [
          ChangeNotifierProvider(
            create:(context)=> QuizProvider(),
          ),
          ChangeNotifierProvider(
            create:(context)=> ThemeProvider(),
          ),

        ],

        child: QuizApp(),

      )

  );

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