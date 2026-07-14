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
  String? selectedAnswer;

  Timer? timer;

  @override
  void initState() {
    super.initState();
    loadQuestions();
  }

  Future<void> loadQuestions() async {
    try {
      final fetchedQuestions =
      await _quizService.fetchQuestions(
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
    if (questions.isEmpty ||
        questionIndex >= questions.length) {
      return;
    }

    final dynamic currentQuestion =
    questions[questionIndex];

    final String correctAnswer =
    (currentQuestion['correct_answer'] ?? '')
        .toString()
        .trim();

    final List<String> incorrectAnswers =
    List<dynamic>.from(
      currentQuestion['incorrect_answers'] ?? [],
    )
        .map(
          (dynamic answer) =>
          answer.toString().trim(),
    )
        .where(
          (String answer) => answer.isNotEmpty,
    )
        .toList();

    final List<String> generatedOptions = [
      correctAnswer,
      ...incorrectAnswers,
    ]
        .where(
          (String option) => option.isNotEmpty,
    )
        .toSet()
        .toList();

    generatedOptions.shuffle();

    if (!mounted) return;

    setState(() {
      options = generatedOptions;
      answerSelected = false;
      selectedAnswer = null;
    });
  }

  void startTimer() {
    timer?.cancel();

    if (!mounted) return;

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

  Future<void> checkAnswer(
      String selectedOption,
      ) async {
    if (answerSelected) return;

    timer?.cancel();

    final String normalizedSelectedAnswer =
    selectedOption.trim().toLowerCase();

    final String normalizedCorrectAnswer =
    questions[questionIndex]['correct_answer']
        .toString()
        .trim()
        .toLowerCase();

    setState(() {
      answerSelected = true;
      selectedAnswer = selectedOption;
    });

    if (normalizedSelectedAnswer ==
        normalizedCorrectAnswer) {
      score++;
    }

    await Future<void>.delayed(
      const Duration(milliseconds: 900),
    );

    if (!mounted) return;

    nextQuestion();
  }

  void nextQuestion() {
    timer?.cancel();

    if (questionIndex < questions.length - 1) {
      setState(() {
        questionIndex++;
        selectedAnswer = null;
        answerSelected = false;
      });

      generateOptions();
      startTimer();
    } else {
      showResult();
    }
  }

  void showResult() {
    timer?.cancel();

    final double percentage = questions.isEmpty
        ? 0
        : score / questions.length;

    String message;
    IconData resultIcon;
    Color resultColor;

    if (percentage >= 0.8) {
      message = 'Excellent Work!';
      resultIcon = Icons.emoji_events_rounded;
      resultColor = const Color(0xffF59E0B);
    } else if (percentage >= 0.5) {
      message = 'Good Attempt!';
      resultIcon = Icons.thumb_up_alt_rounded;
      resultColor = const Color(0xff10B981);
    } else {
      message = 'Keep Practicing!';
      resultIcon = Icons.school_rounded;
      resultColor = const Color(0xff6366F1);
    }

    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        final bool isDark =
            Theme.of(dialogContext).brightness ==
                Brightness.dark;

        return Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: isDark
                  ? const Color(0xff0F172A)
                  : Colors.white,
              borderRadius: BorderRadius.circular(28),
              border: Border.all(
                color: isDark
                    ? const Color(0xff334155)
                    : const Color(0xffE2E8F0),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(
                    alpha: 0.25,
                  ),
                  blurRadius: 30,
                  offset: const Offset(0, 14),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 90,
                  height: 90,
                  decoration: BoxDecoration(
                    color: resultColor.withValues(
                      alpha: 0.14,
                    ),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    resultIcon,
                    color: resultColor,
                    size: 48,
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  'Quiz Completed!',
                  style: TextStyle(
                    fontSize: 25,
                    fontWeight: FontWeight.w900,
                    color: isDark
                        ? Colors.white
                        : const Color(0xff0F172A),
                  ),
                ),
                const SizedBox(height: 7),
                Text(
                  message,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: resultColor,
                  ),
                ),
                const SizedBox(height: 22),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 20,
                  ),
                  decoration: BoxDecoration(
                    color: isDark
                        ? const Color(0xff1E293B)
                        : const Color(0xffF8FAFC),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    children: [
                      Text(
                        '$score',
                        style: const TextStyle(
                          fontSize: 43,
                          fontWeight: FontWeight.w900,
                          color: Color(0xff6366F1),
                        ),
                      ),
                      Text(
                        'out of ${questions.length}',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: isDark
                              ? const Color(0xff94A3B8)
                              : const Color(0xff64748B),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 22),
                SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pop(dialogContext);
                      Navigator.pop(context);
                    },
                    icon: const Icon(
                      Icons.arrow_back_rounded,
                    ),
                    label: const Text(
                      'Back to Categories',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                      const Color(0xff6366F1),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius:
                        BorderRadius.circular(17),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
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
    final bool isDark =
        Theme.of(context).brightness == Brightness.dark;

    if (loading) {
      return buildLoadingScreen(isDark);
    }

    if (errorMessage.isNotEmpty) {
      return buildErrorScreen(isDark);
    }

    if (questions.isEmpty) {
      return buildEmptyScreen(isDark);
    }

    final dynamic currentQuestion =
    questions[questionIndex];

    return Scaffold(
      appBar: AppBar(
        title: Text(
          '${widget.category.toUpperCase()} Quiz',
          style: const TextStyle(
            fontWeight: FontWeight.w800,
          ),
        ),
        centerTitle: true,
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: isDark
                ? const [
              Color(0xff020617),
              Color(0xff0F172A),
              Color(0xff1E1B4B),
            ]
                : const [
              Color(0xffEEF2FF),
              Color(0xffF8FAFC),
              Color(0xffECFEFF),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(
              20,
              20,
              20,
              30,
            ),
            child: Column(
              children: [
                buildTopInformation(isDark),
                const SizedBox(height: 18),
                buildProgressBar(),
                const SizedBox(height: 22),
                buildQuestionCard(
                  currentQuestion,
                  isDark,
                ),
                const SizedBox(height: 22),
                buildOptions(isDark),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget buildTopInformation(bool isDark) {
    Color timerColor;

    if (timeLeft <= 5) {
      timerColor = const Color(0xffEF4444);
    } else if (timeLeft <= 10) {
      timerColor = const Color(0xffF59E0B);
    } else {
      timerColor = const Color(0xff10B981);
    }

    return Row(
      children: [
        Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 15,
              vertical: 13,
            ),
            decoration: BoxDecoration(
              color: isDark
                  ? const Color(0xff0F172A)
                  : Colors.white,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: isDark
                    ? const Color(0xff334155)
                    : const Color(0xffE2E8F0),
              ),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.help_outline_rounded,
                  color: Color(0xff6366F1),
                ),
                const SizedBox(width: 8),
                Text(
                  '${questionIndex + 1} of ${questions.length}',
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    color: isDark
                        ? Colors.white
                        : const Color(0xff1E293B),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 12),
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 15,
            vertical: 13,
          ),
          decoration: BoxDecoration(
            color: timerColor.withValues(alpha: 0.13),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: timerColor.withValues(alpha: 0.35),
            ),
          ),
          child: Row(
            children: [
              Icon(
                Icons.timer_outlined,
                color: timerColor,
              ),
              const SizedBox(width: 7),
              Text(
                '${timeLeft}s',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                  color: timerColor,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget buildProgressBar() {
    final double progress =
        (questionIndex + 1) / questions.length;

    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: LinearProgressIndicator(
        value: progress,
        minHeight: 9,
        backgroundColor:
        const Color(0xffCBD5E1).withValues(
          alpha: 0.55,
        ),
        valueColor:
        const AlwaysStoppedAnimation<Color>(
          Color(0xff6366F1),
        ),
      ),
    );
  }

  Widget buildQuestionCard(
      dynamic currentQuestion,
      bool isDark,
      ) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 350),
      transitionBuilder: (
          Widget child,
          Animation<double> animation,
          ) {
        return FadeTransition(
          opacity: animation,
          child: ScaleTransition(
            scale: Tween<double>(
              begin: 0.97,
              end: 1,
            ).animate(animation),
            child: child,
          ),
        );
      },
      child: Container(
        key: ValueKey<int>(questionIndex),
        width: double.infinity,
        padding: const EdgeInsets.all(23),
        decoration: BoxDecoration(
          color: isDark
              ? const Color(0xff0F172A)
              : Colors.white,
          borderRadius: BorderRadius.circular(25),
          border: Border.all(
            color: isDark
                ? const Color(0xff334155)
                : const Color(0xffE2E8F0),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(
                alpha: isDark ? 0.22 : 0.07,
              ),
              blurRadius: 24,
              offset: const Offset(0, 11),
            ),
          ],
        ),
        child: Column(
          children: [
            Container(
              width: 55,
              height: 55,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [
                    Color(0xff6366F1),
                    Color(0xff22D3EE),
                  ],
                ),
                borderRadius: BorderRadius.circular(18),
              ),
              child: const Icon(
                Icons.psychology_alt_rounded,
                color: Colors.white,
                size: 29,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              currentQuestion['question'].toString(),
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 21,
                height: 1.45,
                fontWeight: FontWeight.w900,
                color: isDark
                    ? Colors.white
                    : const Color(0xff0F172A),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildOptions(bool isDark) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 350),
      child: Column(
        key: ValueKey<int>(questionIndex),
        children: List.generate(
          options.length,
              (int index) {
            final String option = options[index];

            return Padding(
              padding: const EdgeInsets.only(bottom: 13),
              child: buildOptionCard(
                option: option,
                optionIndex: index,
                isDark: isDark,
              ),
            );
          },
        ),
      ),
    );
  }

  Widget buildOptionCard({
    required String option,
    required int optionIndex,
    required bool isDark,
  }) {
    final String correctAnswer =
    questions[questionIndex]['correct_answer']
        .toString()
        .trim();

    final bool isSelected =
        selectedAnswer == option;

    final bool isCorrectOption =
        option.trim().toLowerCase() ==
            correctAnswer.toLowerCase();

    Color backgroundColor;
    Color borderColor;
    Color textColor;
    IconData? trailingIcon;

    if (answerSelected && isCorrectOption) {
      backgroundColor = const Color(0xff10B981);
      borderColor = const Color(0xff10B981);
      textColor = Colors.white;
      trailingIcon = Icons.check_circle_rounded;
    } else if (answerSelected &&
        isSelected &&
        !isCorrectOption) {
      backgroundColor = const Color(0xffEF4444);
      borderColor = const Color(0xffEF4444);
      textColor = Colors.white;
      trailingIcon = Icons.cancel_rounded;
    } else {
      backgroundColor = isDark
          ? const Color(0xff0F172A)
          : Colors.white;

      borderColor = isSelected
          ? const Color(0xff6366F1)
          : isDark
          ? const Color(0xff334155)
          : const Color(0xffE2E8F0);

      textColor = isDark
          ? const Color(0xffE2E8F0)
          : const Color(0xff1E293B);
    }

    return InkWell(
      onTap: answerSelected
          ? null
          : () => checkAnswer(option),
      borderRadius: BorderRadius.circular(19),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        width: double.infinity,
        padding: const EdgeInsets.symmetric(
          horizontal: 15,
          vertical: 15,
        ),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(19),
          border: Border.all(
            color: borderColor,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(
                alpha: isDark ? 0.15 : 0.045,
              ),
              blurRadius: 13,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: answerSelected &&
                    (isCorrectOption ||
                        (isSelected &&
                            !isCorrectOption))
                    ? Colors.white.withValues(
                  alpha: 0.18,
                )
                    : const Color(0xff6366F1)
                    .withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(13),
              ),
              alignment: Alignment.center,
              child: Text(
                String.fromCharCode(
                  65 + optionIndex,
                ),
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                  color: answerSelected &&
                      (isCorrectOption ||
                          (isSelected &&
                              !isCorrectOption))
                      ? Colors.white
                      : const Color(0xff6366F1),
                ),
              ),
            ),
            const SizedBox(width: 13),
            Expanded(
              child: Text(
                option,
                style: TextStyle(
                  fontSize: 15.5,
                  height: 1.35,
                  fontWeight: FontWeight.w700,
                  color: textColor,
                ),
              ),
            ),
            if (trailingIcon != null) ...[
              const SizedBox(width: 8),
              Icon(
                trailingIcon,
                color: Colors.white,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget buildLoadingScreen(bool isDark) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: isDark
                ? const [
              Color(0xff020617),
              Color(0xff0F172A),
            ]
                : const [
              Color(0xffEEF2FF),
              Color(0xffF8FAFC),
            ],
          ),
        ),
        child: Center(
          child: Container(
            margin: const EdgeInsets.all(25),
            padding: const EdgeInsets.all(28),
            decoration: BoxDecoration(
              color: isDark
                  ? const Color(0xff0F172A)
                  : Colors.white,
              borderRadius: BorderRadius.circular(26),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const CircularProgressIndicator(),
                const SizedBox(height: 22),
                Text(
                  'Loading Quiz...',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                    color: isDark
                        ? Colors.white
                        : const Color(0xff0F172A),
                  ),
                ),
                const SizedBox(height: 7),
                const Text(
                  'Questions are being prepared.',
                  style: TextStyle(
                    color: Color(0xff64748B),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget buildErrorScreen(bool isDark) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Quiz Error'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(22),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(25),
            decoration: BoxDecoration(
              color: isDark
                  ? const Color(0xff0F172A)
                  : Colors.white,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: const Color(0xffEF4444)
                    .withValues(alpha: 0.35),
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.error_outline_rounded,
                  size: 60,
                  color: Color(0xffEF4444),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Questions Could Not Load',
                  style: TextStyle(
                    fontSize: 21,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  errorMessage,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Color(0xff64748B),
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 20),
                ElevatedButton.icon(
                  onPressed: () {
                    setState(() {
                      loading = true;
                      errorMessage = '';
                    });

                    loadQuestions();
                  },
                  icon: const Icon(Icons.refresh_rounded),
                  label: const Text('Try Again'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget buildEmptyScreen(bool isDark) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Quiz'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(22),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.quiz_outlined,
                size: 70,
                color: Color(0xff6366F1),
              ),
              const SizedBox(height: 17),
              Text(
                'No Questions Found',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  color: isDark
                      ? Colors.white
                      : const Color(0xff0F172A),
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Is category aur difficulty ke questions database mein available nahi hain.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Color(0xff64748B),
                  height: 1.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}