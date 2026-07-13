import 'dart:async';
import 'dart:io';

import 'package:supabase_flutter/supabase_flutter.dart';

class QuizService {
  final SupabaseClient _supabase = Supabase.instance.client;

  Future<List<dynamic>> fetchQuestions({
    required String difficulty,
    required String category,
  }) async {
    try {
      print("========== SUPABASE ==========");
      print("Difficulty: $difficulty");
      print("Category: $category");

      final List<Map<String, dynamic>> response =
      await _supabase
          .from('quizzes')
          .select();

      print("Rows Found: ${response.length}");
      print("RAW SUPABASE DATA: $response");

      if (response.isEmpty) {
        throw Exception(
          "No questions found for this difficulty and category.",
        );
      }

      final List<dynamic> formattedQuestions =
      response.map((quiz) {
        final String optionA =
        (quiz['option_a'] ?? '').toString().trim();

        final String optionB =
        (quiz['option_b'] ?? '').toString().trim();

        final String optionC =
        (quiz['option_c'] ?? '').toString().trim();

        final String optionD =
        (quiz['option_d'] ?? '').toString().trim();

        final List<String> allOptions = [
          optionA,
          optionB,
          optionC,
          optionD,
        ].where((option) => option.isNotEmpty).toList();

        final String databaseCorrectAnswer =
        (quiz['correct_answer'] ?? '')
            .toString()
            .trim();

        print("DATABASE CORRECT ANSWER: >>>$databaseCorrectAnswer<<<");
        print("ALL OPTIONS: $allOptions");

        /*
         Supabase mein Google likha ho aur option mein google/Google ho,
         to correct option ka original text options list se uthaya jayega.
        */
        final String correctAnswer =
        allOptions.firstWhere(
              (option) =>
          normalizeAnswer(option) ==
              normalizeAnswer(databaseCorrectAnswer),
          orElse: () => databaseCorrectAnswer,
        );

        final List<String> incorrectAnswers =
        allOptions.where((option) {
          return normalizeAnswer(option) !=
              normalizeAnswer(correctAnswer);
        }).toList();

        print("FINAL CORRECT ANSWER: >>>$correctAnswer<<<");
        print("INCORRECT ANSWERS: $incorrectAnswers");

        return {
          'question':
          (quiz['question'] ?? '').toString().trim(),
          'correct_answer': correctAnswer,
          'incorrect_answers': incorrectAnswers,
        };
      }).toList();

      return formattedQuestions;
    } on SocketException {
      throw Exception("No Internet Connection");
    } on TimeoutException {
      throw Exception("Request Timed Out");
    } catch (error) {
      print("Quiz Service Error: $error");

      if (error is Exception) {
        rethrow;
      }

      throw Exception("Something went wrong");
    }
  }

  String normalizeAnswer(String answer) {
    return answer
        .replaceAll('\u00A0', ' ')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim()
        .toLowerCase();
  }
}