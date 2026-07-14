import 'package:flutter/material.dart';
import 'package:quiz_app/document_upload_screen.dart';
import 'class_screen.dart';


class HomeScreen extends StatefulWidget {
  final VoidCallback changeTheme;
  final bool isDarkMode;

  const HomeScreen({
    super.key,
    required this.changeTheme,
    required this.isDarkMode,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController controller;
  late Animation<Offset> slideAnimation;
  late Animation<double> fadeAnimation;

  @override
  void initState() {
    super.initState();

    controller = AnimationController(
      duration: const Duration(milliseconds: 900),
      vsync: this,
    );

    slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.18),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: controller,
        curve: Curves.easeOutCubic,
      ),
    );

    fadeAnimation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(
      CurvedAnimation(
        parent: controller,
        curve: Curves.easeIn,
      ),
    );

    controller.forward();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = widget.isDarkMode;

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: isDark
            ? const Color(0xff020617)
            : const Color(0xff4F46E5),
        foregroundColor: Colors.white,
        centerTitle: false,
        titleSpacing: 20,
        title: const Row(
          children: [
            Icon(
              Icons.psychology_alt_rounded,
              color: Color(0xff22D3EE),
              size: 27,
            ),
            SizedBox(width: 9),
            Text(
              'Quizora AI',
              style: TextStyle(
                fontSize: 21,
                fontWeight: FontWeight.w900,
                letterSpacing: 0.2,
              ),
            ),
          ],
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(
              right: 14,
              top: 7,
              bottom: 7,
            ),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.18),
              ),
            ),
            child: IconButton(
              tooltip: isDark
                  ? 'Switch to Light Mode'
                  : 'Switch to Dark Mode',
              onPressed: widget.changeTheme,
              icon: Icon(
                isDark
                    ? Icons.light_mode_rounded
                    : Icons.dark_mode_rounded,
                size: 22,
              ),
            ),
          ),
        ],
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
          child: FadeTransition(
            opacity: fadeAnimation,
            child: SlideTransition(
              position: slideAnimation,
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(
                  20,
                  22,
                  20,
                  30,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    buildHeroSection(isDark),
                    const SizedBox(height: 24),
                    buildDocumentQuizCard(context, isDark),
                    const SizedBox(height: 28),
                    buildSectionTitle(
                      title: 'Choose Difficulty',
                      subtitle:
                      'Select a level and test your knowledge',
                      isDark: isDark,
                    ),
                    const SizedBox(height: 15),
                    difficultyCard(
                      context: context,
                      title: 'Easy',
                      description:
                      'Start with simple and beginner-friendly questions.',
                      difficulty: 'easy',
                      icon: Icons.sentiment_satisfied_alt_rounded,
                      iconColor: const Color(0xff10B981),
                      cardColor: const Color(0xffECFDF5),
                      darkCardColor: const Color(0xff064E3B),
                    ),
                    const SizedBox(height: 13),
                    difficultyCard(
                      context: context,
                      title: 'Medium',
                      description:
                      'Challenge yourself with balanced questions.',
                      difficulty: 'medium',
                      icon: Icons.local_fire_department_rounded,
                      iconColor: const Color(0xffF59E0B),
                      cardColor: const Color(0xffFFFBEB),
                      darkCardColor: const Color(0xff78350F),
                    ),
                    const SizedBox(height: 13),
                    difficultyCard(
                      context: context,
                      title: 'Hard',
                      description:
                      'Take on advanced and difficult questions.',
                      difficulty: 'hard',
                      icon: Icons.workspace_premium_rounded,
                      iconColor: const Color(0xffEF4444),
                      cardColor: const Color(0xffFEF2F2),
                      darkCardColor: const Color(0xff7F1D1D),
                    ),
                    const SizedBox(height: 26),
                    buildFooter(isDark),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget buildHeroSection(bool isDark) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark
              ? const [
            Color(0xff312E81),
            Color(0xff1E1B4B),
          ]
              : const [
            Color(0xff4F46E5),
            Color(0xff7C3AED),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: const Color(0xff4F46E5)
                .withValues(alpha: isDark ? 0.22 : 0.32),
            blurRadius: 30,
            offset: const Offset(0, 14),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            top: -35,
            right: -28,
            child: Container(
              width: 125,
              height: 125,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.08),
              ),
            ),
          ),
          Positioned(
            bottom: -40,
            left: -30,
            child: Container(
              width: 105,
              height: 105,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xff22D3EE)
                    .withValues(alpha: 0.12),
              ),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 62,
                height: 62,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [
                      Color(0xff22D3EE),
                      Color(0xff818CF8),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xff22D3EE)
                          .withValues(alpha: 0.25),
                      blurRadius: 20,
                      offset: const Offset(0, 7),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.auto_awesome_rounded,
                  color: Colors.white,
                  size: 32,
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Learn Smarter.\nQuiz Better.',
                style: TextStyle(
                  fontSize: 32,
                  height: 1.15,
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -0.7,
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'Practice ready-made quizzes or turn your own '
                    'notes into interactive AI questions.',
                style: TextStyle(
                  fontSize: 15,
                  height: 1.55,
                  color: Color(0xffE0E7FF),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget buildDocumentQuizCard(
      BuildContext context,
      bool isDark,
      ) {
    return InkWell(
      borderRadius: BorderRadius.circular(24),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) =>
            const DocumentUploadScreen(),
          ),
        );
      },
      child: Ink(
        width: double.infinity,
        padding: const EdgeInsets.all(19),
        decoration: BoxDecoration(
          color: isDark
              ? const Color(0xff0F172A)
              : Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: isDark
                ? const Color(0xff334155)
                : const Color(0xffE2E8F0),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(
                alpha: isDark ? 0.24 : 0.07,
              ),
              blurRadius: 22,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 61,
              height: 61,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [
                    Color(0xff6366F1),
                    Color(0xff22D3EE),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(19),
              ),
              child: const Icon(
                Icons.description_rounded,
                color: Colors.white,
                size: 31,
              ),
            ),
            const SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment:
                CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        'AI Document Quiz',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                          color: isDark
                              ? Colors.white
                              : const Color(0xff0F172A),
                        ),
                      ),
                      const SizedBox(width: 7),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 7,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xff22D3EE)
                              .withValues(alpha: 0.14),
                          borderRadius:
                          BorderRadius.circular(8),
                        ),
                        child: const Text(
                          'AI',
                          style: TextStyle(
                            color: Color(0xff0891B2),
                            fontSize: 11,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Upload PDF or TXT notes and generate a custom quiz.',
                    style: TextStyle(
                      fontSize: 13.5,
                      height: 1.4,
                      color: isDark
                          ? const Color(0xff94A3B8)
                          : const Color(0xff64748B),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            Container(
              width: 39,
              height: 39,
              decoration: BoxDecoration(
                color: const Color(0xff6366F1)
                    .withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(13),
              ),
              child: const Icon(
                Icons.arrow_forward_rounded,
                color: Color(0xff6366F1),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildSectionTitle({
    required String title,
    required String subtitle,
    required bool isDark,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w900,
            color: isDark
                ? Colors.white
                : const Color(0xff0F172A),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          subtitle,
          style: TextStyle(
            fontSize: 14,
            color: isDark
                ? const Color(0xff94A3B8)
                : const Color(0xff64748B),
          ),
        ),
      ],
    );
  }

  Widget difficultyCard({
    required BuildContext context,
    required String title,
    required String description,
    required String difficulty,
    required IconData icon,
    required Color iconColor,
    required Color cardColor,
    required Color darkCardColor,
  }) {
    final bool isDark = widget.isDarkMode;

    return InkWell(
      borderRadius: BorderRadius.circular(21),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ClassScreen(
              difficulty: difficulty,
            ),
          ),
        );
      },
      child: Ink(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark
              ? const Color(0xff0F172A)
              : Colors.white,
          borderRadius: BorderRadius.circular(21),
          border: Border.all(
            color: isDark
                ? const Color(0xff334155)
                : const Color(0xffE2E8F0),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(
                alpha: isDark ? 0.18 : 0.05,
              ),
              blurRadius: 15,
              offset: const Offset(0, 7),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 57,
              height: 57,
              decoration: BoxDecoration(
                color: isDark
                    ? darkCardColor.withValues(alpha: 0.55)
                    : cardColor,
                borderRadius: BorderRadius.circular(18),
              ),
              child: Icon(
                icon,
                color: iconColor,
                size: 29,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment:
                CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w900,
                      color: isDark
                          ? Colors.white
                          : const Color(0xff1E293B),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: TextStyle(
                      fontSize: 13,
                      height: 1.35,
                      color: isDark
                          ? const Color(0xff94A3B8)
                          : const Color(0xff64748B),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            Icon(
              Icons.chevron_right_rounded,
              color: iconColor,
              size: 30,
            ),
          ],
        ),
      ),
    );
  }

  Widget buildFooter(bool isDark) {
    return Center(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.bolt_rounded,
            size: 17,
            color: isDark
                ? const Color(0xff22D3EE)
                : const Color(0xff4F46E5),
          ),
          const SizedBox(width: 5),
          Text(
            'Learn • Practice • Improve',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: isDark
                  ? const Color(0xff64748B)
                  : const Color(0xff64748B),
            ),
          ),
        ],
      ),
    );
  }
}