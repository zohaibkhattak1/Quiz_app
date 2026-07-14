import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class QuizService {
  final SupabaseClient _supabase = Supabase.instance.client;

  Future<List<dynamic>> fetchQuestions({
    required String difficulty,
    required String category,
  }) async {
    try {
      final String normalizedDifficulty =
      difficulty.trim().toLowerCase();

      final String normalizedCategory =
      category.trim().toLowerCase();

      debugPrint('========== SUPABASE QUIZ ==========');
      debugPrint('Difficulty: $normalizedDifficulty');
      debugPrint('Category: $normalizedCategory');

      final List<Map<String, dynamic>> response =
      await _supabase
          .from('quizzes')
          .select()
          .eq(
        'difficulty',
        normalizedDifficulty,
      )
          .eq(
        'category',
        normalizedCategory,
      )
          .timeout(
        const Duration(seconds: 20),
      );

      debugPrint('Rows Found: ${response.length}');

      if (response.isEmpty) {
        throw Exception(
          'No questions found for '
              '$normalizedCategory - $normalizedDifficulty.',
        );
      }

      final List<dynamic> formattedQuestions = [];

      for (final Map<String, dynamic> quiz in response) {
        final String questionText =
        (quiz['question'] ?? '')
            .toString()
            .trim();

        final String optionA =
        (quiz['option_a'] ?? '')
            .toString()
            .trim();

        final String optionB =
        (quiz['option_b'] ?? '')
            .toString()
            .trim();

        final String optionC =
        (quiz['option_c'] ?? '')
            .toString()
            .trim();

        final String optionD =
        (quiz['option_d'] ?? '')
            .toString()
            .trim();

        final String databaseCorrectAnswer =
        (quiz['correct_answer'] ?? '')
            .toString()
            .trim();

        final List<String> allOptions = [
          optionA,
          optionB,
          optionC,
          optionD,
        ]
            .where(
              (String option) =>
          option.isNotEmpty,
        )
            .toSet()
            .toList();

        if (questionText.isEmpty) {
          debugPrint(
            'Skipped row: question empty hai.',
          );
          continue;
        }

        if (allOptions.length < 2) {
          debugPrint(
            'Skipped question: options complete nahi hain.',
          );
          continue;
        }

        if (databaseCorrectAnswer.isEmpty) {
          debugPrint(
            'Skipped question: correct answer empty hai.',
          );
          continue;
        }

        final String correctAnswer =
        allOptions.firstWhere(
              (String option) {
            return normalizeAnswer(option) ==
                normalizeAnswer(
                  databaseCorrectAnswer,
                );
          },
          orElse: () => '',
        );

        if (correctAnswer.isEmpty) {
          debugPrint(
            'Skipped question: correct answer '
                'options mein match nahi hua.',
          );
          debugPrint(
            'Database answer: $databaseCorrectAnswer',
          );
          debugPrint(
            'Options: $allOptions',
          );
          continue;
        }

        final List<String> incorrectAnswers =
        allOptions.where(
              (String option) {
            return normalizeAnswer(option) !=
                normalizeAnswer(correctAnswer);
          },
        ).toList();

        formattedQuestions.add({
          'question': questionText,
          'correct_answer': correctAnswer,
          'incorrect_answers': incorrectAnswers,
        });
      }

      if (formattedQuestions.isEmpty) {
        throw Exception(
          'Questions mili hain, lekin unka data '
              'complete ya valid nahi hai.',
        );
      }

      formattedQuestions.shuffle();

      debugPrint(
        'Valid Questions: ${formattedQuestions.length}',
      );

      return formattedQuestions;
    } on SocketException {
      throw Exception(
        'No Internet Connection',
      );
    } on TimeoutException {
      throw Exception(
        'Request Timed Out',
      );
    } on PostgrestException catch (error) {
      debugPrint(
        'Supabase Database Error: ${error.message}',
      );

      throw Exception(
        'Database error: ${error.message}',
      );
    } catch (error) {
      debugPrint(
        'Quiz Service Error: $error',
      );

      if (error is Exception) {
        rethrow;
      }

      throw Exception(
        'Something went wrong while loading questions.',
      );
    }
  }

  String normalizeAnswer(String answer) {
    return answer
        .replaceAll('\u00A0', ' ')
        .replaceAll(
      RegExp(r'\s+'),
      ' ',
    )
        .trim()
        .toLowerCase();
  }
}