import 'package:flutter/material.dart';
import 'home_screen.dart';

class ResultScreen extends StatelessWidget {
  final int score;

  // Total questions na bhejo to default 10 use honge.
  final int totalQuestions;

  // Tumhare current HomeScreen structure ke liye rehne diye hain.
  final VoidCallback changeTheme;
  final bool isDarkMode;

  const ResultScreen({
    super.key,
    required this.score,
    required this.changeTheme,
    required this.isDarkMode,
    this.totalQuestions = 10,
  });

  @override
  Widget build(BuildContext context) {
    final bool isDark =
        Theme.of(context).brightness == Brightness.dark;

    final double percentage = totalQuestions == 0
        ? 0
        : score / totalQuestions;

    final int percentageValue =
    (percentage * 100).round();

    final ResultDetails result =
    getResultDetails(percentage);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Quiz Result',
          style: TextStyle(
            fontWeight: FontWeight.w800,
          ),
        ),
        centerTitle: true,
        automaticallyImplyLeading: false,
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
              24,
              20,
              30,
            ),
            child: Column(
              children: [
                buildResultHeader(
                  result: result,
                  percentageValue: percentageValue,
                  isDark: isDark,
                ),

                const SizedBox(height: 22),

                buildScoreCard(
                  isDark: isDark,
                  percentageValue: percentageValue,
                  resultColor: result.color,
                ),

                const SizedBox(height: 18),

                buildPerformanceCard(
                  isDark: isDark,
                  result: result,
                ),

                const SizedBox(height: 25),

                buildButtons(context),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget buildResultHeader({
    required ResultDetails result,
    required int percentageValue,
    required bool isDark,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(25),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xff4F46E5),
            Color(0xff7C3AED),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: const Color(0xff4F46E5)
                .withValues(alpha: 0.30),
            blurRadius: 30,
            offset: const Offset(0, 14),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            right: -35,
            top: -45,
            child: Container(
              width: 140,
              height: 140,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(
                  alpha: 0.08,
                ),
              ),
            ),
          ),

          Column(
            children: [
              Container(
                width: 98,
                height: 98,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(
                    alpha: 0.15,
                  ),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.white.withValues(
                      alpha: 0.22,
                    ),
                    width: 2,
                  ),
                ),
                child: Icon(
                  result.icon,
                  size: 52,
                  color: result.iconColor,
                ),
              ),

              const SizedBox(height: 18),

              const Text(
                'Quiz Completed!',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                ),
              ),

              const SizedBox(height: 7),

              Text(
                result.title,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: result.iconColor,
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                ),
              ),

              const SizedBox(height: 9),

              Text(
                result.message,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Color(0xffE0E7FF),
                  fontSize: 14,
                  height: 1.5,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget buildScoreCard({
    required bool isDark,
    required int percentageValue,
    required Color resultColor,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
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
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        children: [
          SizedBox(
            width: 112,
            height: 112,
            child: Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 106,
                  height: 106,
                  child: CircularProgressIndicator(
                    value: totalQuestions == 0
                        ? 0
                        : score / totalQuestions,
                    strokeWidth: 10,
                    backgroundColor: isDark
                        ? const Color(0xff334155)
                        : const Color(0xffE2E8F0),
                    valueColor:
                    AlwaysStoppedAnimation<Color>(
                      resultColor,
                    ),
                    strokeCap: StrokeCap.round,
                  ),
                ),

                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '$percentageValue%',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w900,
                        color: isDark
                            ? Colors.white
                            : const Color(0xff0F172A),
                      ),
                    ),
                    Text(
                      'Accuracy',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: isDark
                            ? const Color(0xff94A3B8)
                            : const Color(0xff64748B),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(width: 20),

          Expanded(
            child: Column(
              crossAxisAlignment:
              CrossAxisAlignment.start,
              children: [
                Text(
                  'Your Score',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: isDark
                        ? const Color(0xff94A3B8)
                        : const Color(0xff64748B),
                  ),
                ),

                const SizedBox(height: 5),

                Text(
                  '$score / $totalQuestions',
                  style: TextStyle(
                    fontSize: 33,
                    fontWeight: FontWeight.w900,
                    color: resultColor,
                  ),
                ),

                const SizedBox(height: 7),

                Text(
                  '$score correct answers out of '
                      '$totalQuestions questions.',
                  style: TextStyle(
                    fontSize: 13,
                    height: 1.4,
                    color: isDark
                        ? const Color(0xffCBD5E1)
                        : const Color(0xff475569),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget buildPerformanceCard({
    required bool isDark,
    required ResultDetails result,
  }) {
    final int wrongAnswers =
    (totalQuestions - score).clamp(
      0,
      totalQuestions,
    );

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(19),
      decoration: BoxDecoration(
        color: isDark
            ? const Color(0xff0F172A)
            : Colors.white,
        borderRadius: BorderRadius.circular(23),
        border: Border.all(
          color: isDark
              ? const Color(0xff334155)
              : const Color(0xffE2E8F0),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Performance Summary',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w900,
              color: isDark
                  ? Colors.white
                  : const Color(0xff0F172A),
            ),
          ),

          const SizedBox(height: 17),

          Row(
            children: [
              Expanded(
                child: buildStatItem(
                  icon: Icons.check_circle_rounded,
                  title: 'Correct',
                  value: '$score',
                  color: const Color(0xff10B981),
                  isDark: isDark,
                ),
              ),

              const SizedBox(width: 12),

              Expanded(
                child: buildStatItem(
                  icon: Icons.cancel_rounded,
                  title: 'Incorrect',
                  value: '$wrongAnswers',
                  color: const Color(0xffEF4444),
                  isDark: isDark,
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: result.color.withValues(
                alpha: 0.10,
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: result.color.withValues(
                  alpha: 0.25,
                ),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.tips_and_updates_rounded,
                  color: result.color,
                ),

                const SizedBox(width: 11),

                Expanded(
                  child: Text(
                    result.tip,
                    style: TextStyle(
                      fontSize: 13,
                      height: 1.45,
                      fontWeight: FontWeight.w600,
                      color: isDark
                          ? const Color(0xffE2E8F0)
                          : const Color(0xff334155),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget buildStatItem({
    required IconData icon,
    required String title,
    required String value,
    required Color color,
    required bool isDark,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 13,
        vertical: 15,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(17),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            color: color,
            size: 27,
          ),

          const SizedBox(height: 7),

          Text(
            value,
            style: TextStyle(
              fontSize: 23,
              fontWeight: FontWeight.w900,
              color: color,
            ),
          ),

          const SizedBox(height: 2),

          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: isDark
                  ? const Color(0xffCBD5E1)
                  : const Color(0xff475569),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildButtons(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          height: 57,
          child: ElevatedButton.icon(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: const Icon(
              Icons.refresh_rounded,
            ),
            label: const Text(
              'Try Another Quiz',
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
                borderRadius: BorderRadius.circular(18),
              ),
            ),
          ),
        ),

        const SizedBox(height: 12),

        SizedBox(
          width: double.infinity,
          height: 57,
          child: OutlinedButton.icon(
            onPressed: () {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(
                  builder: (context) => HomeScreen(
                    changeTheme: changeTheme,
                    isDarkMode: isDarkMode,
                  ),
                ),
                    (route) => false,
              );
            },
            icon: const Icon(
              Icons.home_rounded,
            ),
            label: const Text(
              'Back to Home',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
              ),
            ),
            style: OutlinedButton.styleFrom(
              foregroundColor:
              const Color(0xff6366F1),
              side: const BorderSide(
                color: Color(0xff6366F1),
                width: 1.5,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
              ),
            ),
          ),
        ),
      ],
    );
  }

  ResultDetails getResultDetails(
      double percentage,
      ) {
    if (percentage >= 0.80) {
      return const ResultDetails(
        title: 'Outstanding Performance!',
        message:
        'You have a strong understanding of this topic.',
        tip:
        'Keep practicing regularly to maintain this excellent performance.',
        icon: Icons.emoji_events_rounded,
        color: Color(0xffF59E0B),
        iconColor: Color(0xffFDE68A),
      );
    }

    if (percentage >= 0.50) {
      return const ResultDetails(
        title: 'Good Attempt!',
        message:
        'You are doing well, but there is still room to improve.',
        tip:
        'Review the questions you missed and try the quiz again.',
        icon: Icons.thumb_up_alt_rounded,
        color: Color(0xff10B981),
        iconColor: Color(0xff6EE7B7),
      );
    }

    return const ResultDetails(
      title: 'Keep Practicing!',
      message:
      'Every attempt helps you learn and become better.',
      tip:
      'Revise the topic, understand the concepts, and attempt the quiz again.',
      icon: Icons.school_rounded,
      color: Color(0xff6366F1),
      iconColor: Color(0xffA5B4FC),
    );
  }
}

class ResultDetails {
  final String title;
  final String message;
  final String tip;
  final IconData icon;
  final Color color;
  final Color iconColor;

  const ResultDetails({
    required this.title,
    required this.message,
    required this.tip,
    required this.icon,
    required this.color,
    required this.iconColor,
  });
}