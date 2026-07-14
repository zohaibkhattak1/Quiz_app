import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:quiz_app/home_screen.dart';
import 'package:quiz_app/quiz_provider.dart';
import 'package:quiz_app/supabase_service.dart';
import 'package:quiz_app/theme_provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

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
          create: (_) => QuizProvider(),
        ),
        ChangeNotifierProvider(
          create: (_) => ThemeProvider(),
        ),
      ],
      child: const QuizApp(),
    ),
  );
}

class QuizApp extends StatelessWidget {
  const QuizApp({super.key});

  @override
  Widget build(BuildContext context) {
    final ThemeProvider themeProvider =
    context.watch<ThemeProvider>();

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Quizora AI',

      // ================= LIGHT THEME =================

      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        scaffoldBackgroundColor: const Color(0xffF8FAFC),

        colorScheme: const ColorScheme.light(
          primary: Color(0xff6366F1),
          secondary: Color(0xff22D3EE),
          tertiary: Color(0xff10B981),
          surface: Colors.white,
          error: Color(0xffEF4444),
          onPrimary: Colors.white,
          onSecondary: Color(0xff0F172A),
          onSurface: Color(0xff1E293B),
        ),

        appBarTheme: const AppBarTheme(
          elevation: 0,
          centerTitle: true,
          scrolledUnderElevation: 0,
          backgroundColor: Color(0xff6366F1),
          foregroundColor: Colors.white,
          surfaceTintColor: Colors.transparent,
          titleTextStyle: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w800,
            letterSpacing: 0.2,
          ),
          iconTheme: IconThemeData(
            color: Colors.white,
          ),
        ),

        cardTheme: CardThemeData(
          elevation: 0,
          color: Colors.white,
          surfaceTintColor: Colors.transparent,
          margin: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(22),
            side: const BorderSide(
              color: Color(0xffE2E8F0),
            ),
          ),
        ),

        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            elevation: 0,
            minimumSize: const Size(
              double.infinity,
              56,
            ),
            backgroundColor: const Color(0xff6366F1),
            foregroundColor: Colors.white,
            disabledBackgroundColor:
            const Color(0xff6366F1)
                .withValues(alpha: 0.45),
            disabledForegroundColor:
            Colors.white.withValues(alpha: 0.75),
            textStyle: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.2,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18),
            ),
          ),
        ),

        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            minimumSize: const Size(
              double.infinity,
              56,
            ),
            foregroundColor: const Color(0xff4F46E5),
            side: const BorderSide(
              color: Color(0xff818CF8),
              width: 1.5,
            ),
            textStyle: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18),
            ),
          ),
        ),

        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            foregroundColor: const Color(0xff4F46E5),
            textStyle: const TextStyle(
              fontWeight: FontWeight.w700,
            ),
          ),
        ),

        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          hintStyle: const TextStyle(
            color: Color(0xff94A3B8),
          ),
          labelStyle: const TextStyle(
            color: Color(0xff475569),
            fontWeight: FontWeight.w600,
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 18,
            vertical: 17,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(18),
            borderSide: const BorderSide(
              color: Color(0xffCBD5E1),
            ),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(18),
            borderSide: const BorderSide(
              color: Color(0xffCBD5E1),
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(18),
            borderSide: const BorderSide(
              color: Color(0xff6366F1),
              width: 2,
            ),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(18),
            borderSide: const BorderSide(
              color: Color(0xffEF4444),
            ),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(18),
            borderSide: const BorderSide(
              color: Color(0xffEF4444),
              width: 2,
            ),
          ),
        ),

        snackBarTheme: SnackBarThemeData(
          backgroundColor: const Color(0xff1E293B),
          contentTextStyle: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
          behavior: SnackBarBehavior.floating,
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),

        dialogTheme: DialogThemeData(
          backgroundColor: Colors.white,
          surfaceTintColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
        ),

        progressIndicatorTheme:
        const ProgressIndicatorThemeData(
          color: Color(0xff6366F1),
          linearTrackColor: Color(0xffE2E8F0),
          circularTrackColor: Color(0xffE2E8F0),
        ),

        iconTheme: const IconThemeData(
          color: Color(0xff475569),
        ),

        dividerTheme: const DividerThemeData(
          color: Color(0xffE2E8F0),
          thickness: 1,
        ),

        textTheme: const TextTheme(
          displayLarge: TextStyle(
            color: Color(0xff0F172A),
            fontWeight: FontWeight.w900,
          ),
          displayMedium: TextStyle(
            color: Color(0xff0F172A),
            fontWeight: FontWeight.w900,
          ),
          headlineLarge: TextStyle(
            color: Color(0xff0F172A),
            fontWeight: FontWeight.w800,
          ),
          headlineMedium: TextStyle(
            color: Color(0xff0F172A),
            fontWeight: FontWeight.w800,
          ),
          titleLarge: TextStyle(
            color: Color(0xff1E293B),
            fontWeight: FontWeight.w800,
          ),
          titleMedium: TextStyle(
            color: Color(0xff1E293B),
            fontWeight: FontWeight.w700,
          ),
          bodyLarge: TextStyle(
            color: Color(0xff334155),
            height: 1.5,
          ),
          bodyMedium: TextStyle(
            color: Color(0xff475569),
            height: 1.5,
          ),
          bodySmall: TextStyle(
            color: Color(0xff64748B),
          ),
        ),
      ),

      // ================= DARK THEME =================

      darkTheme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xff020617),

        colorScheme: const ColorScheme.dark(
          primary: Color(0xff818CF8),
          secondary: Color(0xff22D3EE),
          tertiary: Color(0xff34D399),
          surface: Color(0xff0F172A),
          error: Color(0xffF87171),
          onPrimary: Colors.white,
          onSecondary: Color(0xff020617),
          onSurface: Color(0xffF8FAFC),
        ),

        appBarTheme: const AppBarTheme(
          elevation: 0,
          centerTitle: true,
          scrolledUnderElevation: 0,
          backgroundColor: Color(0xff0F172A),
          foregroundColor: Colors.white,
          surfaceTintColor: Colors.transparent,
          titleTextStyle: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w800,
            letterSpacing: 0.2,
          ),
          iconTheme: IconThemeData(
            color: Colors.white,
          ),
        ),

        cardTheme: CardThemeData(
          elevation: 0,
          color: const Color(0xff0F172A),
          surfaceTintColor: Colors.transparent,
          margin: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(22),
            side: const BorderSide(
              color: Color(0xff334155),
            ),
          ),
        ),

        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            elevation: 0,
            minimumSize: const Size(
              double.infinity,
              56,
            ),
            backgroundColor: const Color(0xff6366F1),
            foregroundColor: Colors.white,
            disabledBackgroundColor:
            const Color(0xff6366F1)
                .withValues(alpha: 0.40),
            disabledForegroundColor:
            Colors.white.withValues(alpha: 0.70),
            textStyle: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.2,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18),
            ),
          ),
        ),

        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            minimumSize: const Size(
              double.infinity,
              56,
            ),
            foregroundColor: const Color(0xffA5B4FC),
            side: const BorderSide(
              color: Color(0xff6366F1),
              width: 1.5,
            ),
            textStyle: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18),
            ),
          ),
        ),

        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            foregroundColor: const Color(0xffA5B4FC),
            textStyle: const TextStyle(
              fontWeight: FontWeight.w700,
            ),
          ),
        ),

        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: const Color(0xff0F172A),
          hintStyle: const TextStyle(
            color: Color(0xff64748B),
          ),
          labelStyle: const TextStyle(
            color: Color(0xffCBD5E1),
            fontWeight: FontWeight.w600,
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 18,
            vertical: 17,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(18),
            borderSide: const BorderSide(
              color: Color(0xff334155),
            ),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(18),
            borderSide: const BorderSide(
              color: Color(0xff334155),
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(18),
            borderSide: const BorderSide(
              color: Color(0xff818CF8),
              width: 2,
            ),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(18),
            borderSide: const BorderSide(
              color: Color(0xffF87171),
            ),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(18),
            borderSide: const BorderSide(
              color: Color(0xffF87171),
              width: 2,
            ),
          ),
        ),

        snackBarTheme: SnackBarThemeData(
          backgroundColor: const Color(0xff1E293B),
          contentTextStyle: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
          behavior: SnackBarBehavior.floating,
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),

        dialogTheme: DialogThemeData(
          backgroundColor: const Color(0xff0F172A),
          surfaceTintColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
        ),

        progressIndicatorTheme:
        const ProgressIndicatorThemeData(
          color: Color(0xff818CF8),
          linearTrackColor: Color(0xff334155),
          circularTrackColor: Color(0xff334155),
        ),

        iconTheme: const IconThemeData(
          color: Color(0xffCBD5E1),
        ),

        dividerTheme: const DividerThemeData(
          color: Color(0xff334155),
          thickness: 1,
        ),

        textTheme: const TextTheme(
          displayLarge: TextStyle(
            color: Color(0xffF8FAFC),
            fontWeight: FontWeight.w900,
          ),
          displayMedium: TextStyle(
            color: Color(0xffF8FAFC),
            fontWeight: FontWeight.w900,
          ),
          headlineLarge: TextStyle(
            color: Color(0xffF8FAFC),
            fontWeight: FontWeight.w800,
          ),
          headlineMedium: TextStyle(
            color: Color(0xffF8FAFC),
            fontWeight: FontWeight.w800,
          ),
          titleLarge: TextStyle(
            color: Color(0xffF1F5F9),
            fontWeight: FontWeight.w800,
          ),
          titleMedium: TextStyle(
            color: Color(0xffE2E8F0),
            fontWeight: FontWeight.w700,
          ),
          bodyLarge: TextStyle(
            color: Color(0xffCBD5E1),
            height: 1.5,
          ),
          bodyMedium: TextStyle(
            color: Color(0xff94A3B8),
            height: 1.5,
          ),
          bodySmall: TextStyle(
            color: Color(0xff64748B),
          ),
        ),
      ),

      // Provider se theme control hogi.
      themeMode: themeProvider.themeMode,

      // Filhaal existing HomeScreen constructor same rakha hai.
      home: HomeScreen(
        changeTheme: themeProvider.toggleTheme,
        isDarkMode: themeProvider.isDarkMode,
      ),
    );
  }
}