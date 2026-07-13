import 'package:flutter/material.dart';
import 'package:quiz_app/home_screen.dart';
import 'package:quiz_app/quiz_provider.dart';
import 'package:provider/provider.dart';
import 'package:quiz_app/theme_provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:quiz_app/supabase_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://lvxkidlecnxdokeqwpvb.supabase.co',
    publishableKey:
    'sb_publishable_ebaVhcONDCGMT0iKMvfChA_07KoXsds',
  );

  try {
    final quizzes = await SupabaseService().fetchQuizzes();

    debugPrint('Supabase quizzes: $quizzes');
    debugPrint('Total quizzes: ${quizzes.length}');
  } catch (error) {
    debugPrint('Supabase error: $error');
  }
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (context) => QuizProvider(),
        ),
        ChangeNotifierProvider(
          create: (context) => ThemeProvider(),
        ),
      ],
      child: const QuizApp(),
    ),
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
      title: 'Quiz App',
      theme: ThemeData.light(),
      darkTheme: ThemeData.dark(),
      themeMode:
      isDarkMode ? ThemeMode.dark : ThemeMode.light,
      home: HomeScreen(
        changeTheme: changeTheme,
        isDarkMode: isDarkMode,
      ),
    );
  }
}