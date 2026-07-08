import 'package:flutter/material.dart';

class QuizProvider extends ChangeNotifier {

  int _score = 0;

  int get score => _score;


  void addScore(){

    _score++;

    notifyListeners();

  }

}