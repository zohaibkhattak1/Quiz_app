import 'dart:async';

import 'package:flutter/material.dart';
import 'quiz_service.dart';

class QuizScreen extends StatefulWidget {
  final String difficulty;
  final String category;

  const QuizScreen({
    super.key,
    required this.difficulty,
    required this.category,
  });

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  final QuizService _quizService = QuizService();

  List<dynamic> questions = [];
  List<String> options = [];

  int questionIndex = 0;
  int score = 0;
  int timeLeft = 15;

  bool loading = true;
  bool answerSelected = false;

  String errorMessage = '';

  Timer? timer;

  @override
  void initState() {
    super.initState();
    loadQuestions();
  }

  Future<void> loadQuestions() async {
    try {
      final fetchedQuestions = await _quizService.fetchQuestions(
        difficulty: widget.difficulty,
        category: widget.category,
      );

      if (!mounted) return;

      setState(() {
        questions = fetchedQuestions;
        loading = false;
      });

      generateOptions();
      startTimer();
    } catch (error) {
      if (!mounted) return;

      setState(() {
        loading = false;
        errorMessage = error.toString().replaceFirst(
          'Exception: ',
          '',
        );
      });
    }
  }

  void generateOptions() {
    if (questions.isEmpty || questionIndex >= questions.length) {
      return;
    }

    final currentQuestion = questions[questionIndex];

    final String correctAnswer =
    (currentQuestion['correct_answer'] ?? '').toString().trim();

    final List<String> incorrectAnswers =
    List<dynamic>.from(
      currentQuestion['incorrect_answers'] ?? [],
    )
        .map((answer) => answer.toString().trim())
        .where((answer) => answer.isNotEmpty)
        .toList();

    final List<String> generatedOptions = [
      correctAnswer,
      ...incorrectAnswers,
    ]
        .where((option) => option.isNotEmpty)
        .toSet()
        .toList();

    generatedOptions.shuffle();

    setState(() {
      options = generatedOptions;
      answerSelected = false;
    });

    print("Correct Answer: $correctAnswer");
    print("Incorrect Answers: $incorrectAnswers");
    print("Final Options: $generatedOptions");
  }
  void startTimer() {
    timer?.cancel();

    setState(() {
      timeLeft = 15;
    });

    timer = Timer.periodic(
      const Duration(seconds: 1),
          (Timer currentTimer) {
        if (!mounted) {
          currentTimer.cancel();
          return;
        }

        if (timeLeft > 1) {
          setState(() {
            timeLeft--;
          });
        } else {
          currentTimer.cancel();
          nextQuestion();
        }
      },
    );
  }

  void checkAnswer(String selectedAnswer) {
    timer?.cancel();

    final String normalizedSelectedAnswer =
    selectedAnswer.trim().toLowerCase();

    final String normalizedCorrectAnswer =
    questions[questionIndex]['correct_answer']
        .toString()
        .trim()
        .toLowerCase();

    print("Selected Answer: '$normalizedSelectedAnswer'");
    print("Correct Answer: '$normalizedCorrectAnswer'");

    if (normalizedSelectedAnswer == normalizedCorrectAnswer) {
      score++;

      print("Answer Correct");
    } else {
      print("Answer Wrong");
    }

    nextQuestion();
  }
  void nextQuestion() {
    timer?.cancel();

    if (questionIndex < questions.length - 1) {
      setState(() {
        questionIndex++;
      });

      generateOptions();
      startTimer();
    } else {
      showResult();
    }
  }

  void showResult() {
    timer?.cancel();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          title: const Text(
            "Quiz Completed 🎉",
            textAlign: TextAlign.center,
          ),
          content: Text(
            "Your Score: $score / ${questions.length}",
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          actionsAlignment: MainAxisAlignment.center,
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.pop(context);
              },
              child: const Text("Go Back"),
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (errorMessage.isNotEmpty) {
      return Scaffold(
        appBar: AppBar(
          title: const Text("Quiz"),
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Text(
              errorMessage,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 18,
                color: Colors.red,
              ),
            ),
          ),
        ),
      );
    }

    if (questions.isEmpty) {
      return const Scaffold(
        body: Center(
          child: Text(
            "No Questions Found",
            style: TextStyle(fontSize: 18),
          ),
        ),
      );
    }

    final currentQuestion = questions[questionIndex];

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Question ${questionIndex + 1}/${questions.length}",
        ),
        centerTitle: true,
        backgroundColor: const Color(0xff6C5CE7),
        foregroundColor: Colors.white,
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xffF8F9FF),
              Color(0xffE8EAF6),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          children: [
            Text(
              "Time Left: $timeLeft",
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xff6C5CE7),
              ),
            ),

            const SizedBox(height: 25),

            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 10,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Text(
                currentQuestion['question'].toString(),
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Color(0xff2D3436),
                ),
              ),
            ),

            const SizedBox(height: 30),

            Expanded(
              child: ListView.builder(
                itemCount: options.length,
                itemBuilder: (context, index) {
                  final option = options[index];

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 14),
                    child: ElevatedButton(
                      onPressed:
                      answerSelected ? null : () => checkAnswer(option),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xff6C5CE7),
                        foregroundColor: Colors.white,
                        minimumSize: const Size(
                          double.infinity,
                          58,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18),
                        ),
                      ),
                      child: Text(
                        option,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}