import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseService {
  final SupabaseClient _supabase =
      Supabase.instance.client;

  // Sab quizzes fetch karne ke liye
  Future<List<Map<String, dynamic>>> fetchQuizzes() async {
    try {
      debugPrint(
        '========== SUPABASE ==========',
      );

      final List<Map<String, dynamic>> response =
      await _supabase
          .from('quizzes')
          .select()
          .order(
        'created_at',
        ascending: false,
      )
          .timeout(
        const Duration(seconds: 20),
      );

      debugPrint(
        'Total Quizzes: ${response.length}',
      );

      return response;
    } on TimeoutException {
      throw Exception(
        'Supabase request timed out.',
      );
    } on PostgrestException catch (error) {
      debugPrint(
        'Supabase Error: ${error.message}',
      );

      throw Exception(error.message);
    } catch (error) {
      debugPrint(
        'Unexpected Error: $error',
      );

      throw Exception(
        'Unable to fetch quizzes.',
      );
    }
  }

  // ID ke through single quiz fetch karne ke liye
  Future<Map<String, dynamic>?> fetchQuizById(
      int id,
      ) async {
    try {
      final response = await _supabase
          .from('quizzes')
          .select()
          .eq('id', id)
          .maybeSingle();

      return response;
    } catch (error) {
      debugPrint(
        'Fetch quiz by ID error: $error',
      );

      return null;
    }
  }

  // Total quizzes count karne ke liye
  Future<int> getQuizCount() async {
    try {
      final response = await _supabase
          .from('quizzes')
          .select();

      return response.length;
    } catch (error) {
      debugPrint(
        'Quiz count error: $error',
      );

      throw Exception(
        'Unable to count quizzes.',
      );
    }
  }

  // Multiple questions ko Supabase me save karne ke liye
  Future<void> saveQuestions(
      List<Map<String, dynamic>> questions,
      ) async {
    try {
      if (questions.isEmpty) {
        throw Exception(
          'Save karne ke liye koi question nahi hai.',
        );
      }

      await _supabase
          .from('quizzes')
          .insert(questions)
          .timeout(
        const Duration(seconds: 20),
      );

      debugPrint(
        '${questions.length} questions Supabase me save ho gaye.',
      );
    } on TimeoutException {
      throw Exception(
        'Questions save request timed out.',
      );
    } on PostgrestException catch (error) {
      debugPrint(
        'Save Supabase Error: ${error.message}',
      );

      throw Exception(error.message);
    } catch (error) {
      debugPrint(
        'Save Questions Error: $error',
      );

      throw Exception(
        'Questions save nahi ho sake.',
      );
    }
  }

  // Testing ke liye ready-made Flutter questions
  Future<void> saveSampleFlutterQuestions() async {
    final List<Map<String, dynamic>> questions = [
      {
        'question':
        'Flutter is developed by which company?',
        'option_a': 'Google',
        'option_b': 'Microsoft',
        'option_c': 'Apple',
        'option_d': 'Meta',
        'correct_answer': 'Google',
        'difficulty': 'easy',
        'category': 'flutter',
      },
      {
        'question':
        'Which programming language is used by Flutter?',
        'option_a': 'Java',
        'option_b': 'Dart',
        'option_c': 'Python',
        'option_d': 'Kotlin',
        'correct_answer': 'Dart',
        'difficulty': 'easy',
        'category': 'flutter',
      },
      {
        'question':
        'Which widget is immutable in Flutter?',
        'option_a': 'StatefulWidget',
        'option_b': 'StatelessWidget',
        'option_c': 'State',
        'option_d': 'ChangeNotifier',
        'correct_answer': 'StatelessWidget',
        'difficulty': 'medium',
        'category': 'flutter',
      },
      {
        'question':
        'Which method is used to rebuild a StatefulWidget?',
        'option_a': 'dispose',
        'option_b': 'initState',
        'option_c': 'setState',
        'option_d': 'main',
        'correct_answer': 'setState',
        'difficulty': 'medium',
        'category': 'flutter',
      },
      {
        'question':
        'Which method runs when a State object is permanently removed?',
        'option_a': 'build',
        'option_b': 'dispose',
        'option_c': 'setState',
        'option_d': 'createState',
        'correct_answer': 'dispose',
        'difficulty': 'hard',
        'category': 'flutter',
      },
      {
        'question':
        'Which key can access a widget State from another location?',
        'option_a': 'ValueKey',
        'option_b': 'UniqueKey',
        'option_c': 'GlobalKey',
        'option_d': 'ObjectKey',
        'correct_answer': 'GlobalKey',
        'difficulty': 'hard',
        'category': 'flutter',
      },
    ];

    await saveQuestions(questions);
  }
}