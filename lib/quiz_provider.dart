import 'package:flutter/material.dart';

class QuizProvider extends ChangeNotifier {

  int _score = 0;
  int _currentQuestion = 0;
  int _totalQuestions = 0;

  int get score => _score;

  int get currentQuestion => _currentQuestion;

  int get totalQuestions => _totalQuestions;

  void setTotalQuestions(int value) {
    _totalQuestions = value;
    notifyListeners();
  }

  void nextQuestion() {
    _currentQuestion++;
    notifyListeners();
  }

  void addScore() {
    _score++;
    notifyListeners();
  }

  void resetQuiz() {
    _score = 0;
    _currentQuestion = 0;
    _totalQuestions = 0;

    notifyListeners();
  }
}