import 'package:flutter/material.dart';
import 'quiz_screen.dart';

class CategoryScreen extends StatefulWidget {
  final String difficulty;

  const CategoryScreen({
    super.key,
    required this.difficulty,
  });

  @override
  State<CategoryScreen> createState() => _CategoryScreenState();
}

class _CategoryScreenState extends State<CategoryScreen> {
  String? selectedCategory;

  final List<Map<String, dynamic>> categories = [
    {
      'name': 'Flutter',
      'description': 'Widgets, layouts and mobile development',
      'id': 'flutter',
      'icon': Icons.flutter_dash_rounded,
      'color': const Color(0xff42A5F5),
      'lightColor': const Color(0xffE3F2FD),
      'darkColor': const Color(0xff0C4A6E),
    },
    {
      'name': 'Dart',
      'description': 'Variables, OOP, functions and logic',
      'id': 'dart',
      'icon': Icons.code_rounded,
      'color': const Color(0xff6366F1),
      'lightColor': const Color(0xffEEF2FF),
      'darkColor': const Color(0xff312E81),
    },
    {
      'name': 'Supabase',
      'description': 'Database, authentication and backend',
      'id': 'supabase',
      'icon': Icons.storage_rounded,
      'color': const Color(0xff10B981),
      'lightColor': const Color(0xffECFDF5),
      'darkColor': const Color(0xff064E3B),
    },
    {
      'name': 'Firebase',
      'description': 'Cloud services and app integration',
      'id': 'firebase',
      'icon': Icons.local_fire_department_rounded,
      'color': const Color(0xffF59E0B),
      'lightColor': const Color(0xffFFFBEB),
      'darkColor': const Color(0xff78350F),
    },
  ];

  @override
  Widget build(BuildContext context) {
    final bool isDark =
        Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Select Category',
          style: TextStyle(
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
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
              20,
              20,
              20,
              18,
            ),
            child: Column(
              children: [
                buildHeader(isDark),
                const SizedBox(height: 22),
                Expanded(
                  child: GridView.builder(
                    physics: const BouncingScrollPhysics(),
                    itemCount: categories.length,
                    gridDelegate:
                    const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 14,
                      mainAxisSpacing: 14,
                      childAspectRatio: 0.88,
                    ),
                    itemBuilder: (context, index) {
                      return buildCategoryCard(
                        category: categories[index],
                        isDark: isDark,
                      );
                    },
                  ),
                ),
                const SizedBox(height: 18),
                buildStartButton(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget buildHeader(bool isDark) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
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
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: const Color(0xff4F46E5).withValues(
              alpha: isDark ? 0.18 : 0.28,
            ),
            blurRadius: 25,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 62,
            height: 62,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.18),
              ),
            ),
            child: const Icon(
              Icons.category_rounded,
              color: Color(0xff22D3EE),
              size: 32,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Choose Your Topic',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Select a category to begin your quiz.',
                  style: TextStyle(
                    fontSize: 13.5,
                    height: 1.4,
                    color: Color(0xffE0E7FF),
                  ),
                ),
                const SizedBox(height: 11),
                buildDifficultyBadge(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget buildDifficultyBadge() {
    final String difficulty = widget.difficulty.toLowerCase();

    Color badgeColor;
    IconData badgeIcon;

    switch (difficulty) {
      case 'easy':
        badgeColor = const Color(0xff10B981);
        badgeIcon = Icons.sentiment_satisfied_alt_rounded;
        break;

      case 'medium':
        badgeColor = const Color(0xffF59E0B);
        badgeIcon = Icons.local_fire_department_rounded;
        break;

      case 'hard':
        badgeColor = const Color(0xffEF4444);
        badgeIcon = Icons.workspace_premium_rounded;
        break;

      default:
        badgeColor = const Color(0xff22D3EE);
        badgeIcon = Icons.bolt_rounded;
    }

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 11,
        vertical: 7,
      ),
      decoration: BoxDecoration(
        color: badgeColor.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: badgeColor.withValues(alpha: 0.45),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            badgeIcon,
            size: 17,
            color: badgeColor,
          ),
          const SizedBox(width: 6),
          Text(
            '${widget.difficulty.toUpperCase()} LEVEL',
            style: TextStyle(
              color: badgeColor,
              fontSize: 12,
              fontWeight: FontWeight.w900,
              letterSpacing: 0.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget buildCategoryCard({
    required Map<String, dynamic> category,
    required bool isDark,
  }) {
    final String categoryId = category['id'].toString();
    final bool isSelected = selectedCategory == categoryId;

    final Color accentColor = category['color'] as Color;
    final Color lightColor = category['lightColor'] as Color;
    final Color darkColor = category['darkColor'] as Color;
    final IconData icon = category['icon'] as IconData;

    return InkWell(
      borderRadius: BorderRadius.circular(23),
      onTap: () {
        setState(() {
          selectedCategory = categoryId;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOut,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected
              ? accentColor
              : isDark
              ? const Color(0xff0F172A)
              : Colors.white,
          borderRadius: BorderRadius.circular(23),
          border: Border.all(
            color: isSelected
                ? accentColor
                : isDark
                ? const Color(0xff334155)
                : const Color(0xffE2E8F0),
            width: isSelected ? 2 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: isSelected
                  ? accentColor.withValues(alpha: 0.30)
                  : Colors.black.withValues(
                alpha: isDark ? 0.20 : 0.06,
              ),
              blurRadius: isSelected ? 22 : 15,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Stack(
          children: [
            if (isSelected)
              Positioned(
                right: -22,
                bottom: -28,
                child: Container(
                  width: 95,
                  height: 95,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withValues(alpha: 0.10),
                  ),
                ),
              ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment:
                  MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      width: 55,
                      height: 55,
                      decoration: BoxDecoration(
                        color: isSelected
                            ? Colors.white.withValues(alpha: 0.18)
                            : isDark
                            ? darkColor.withValues(alpha: 0.70)
                            : lightColor,
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: Icon(
                        icon,
                        color: isSelected
                            ? Colors.white
                            : accentColor,
                        size: 29,
                      ),
                    ),
                    AnimatedContainer(
                      duration:
                      const Duration(milliseconds: 220),
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        color: isSelected
                            ? Colors.white
                            : Colors.transparent,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isSelected
                              ? Colors.white
                              : const Color(0xff94A3B8),
                          width: 2,
                        ),
                      ),
                      child: isSelected
                          ? Icon(
                        Icons.check_rounded,
                        size: 19,
                        color: accentColor,
                      )
                          : null,
                    ),
                  ],
                ),
                const Spacer(),
                Text(
                  category['name'].toString(),
                  style: TextStyle(
                    fontSize: 19,
                    fontWeight: FontWeight.w900,
                    color: isSelected
                        ? Colors.white
                        : isDark
                        ? Colors.white
                        : const Color(0xff0F172A),
                  ),
                ),
                const SizedBox(height: 7),
                Text(
                  category['description'].toString(),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 12.5,
                    height: 1.4,
                    color: isSelected
                        ? Colors.white.withValues(alpha: 0.82)
                        : isDark
                        ? const Color(0xff94A3B8)
                        : const Color(0xff64748B),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget buildStartButton() {
    final bool isEnabled = selectedCategory != null;

    return Container(
      width: double.infinity,
      height: 58,
      decoration: BoxDecoration(
        gradient: isEnabled
            ? const LinearGradient(
          colors: [
            Color(0xff6366F1),
            Color(0xff7C3AED),
          ],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        )
            : null,
        color: isEnabled
            ? null
            : const Color(0xff94A3B8),
        borderRadius: BorderRadius.circular(19),
        boxShadow: isEnabled
            ? [
          BoxShadow(
            color: const Color(0xff6366F1)
                .withValues(alpha: 0.30),
            blurRadius: 20,
            offset: const Offset(0, 9),
          ),
        ]
            : [],
      ),
      child: ElevatedButton.icon(
        onPressed: !isEnabled
            ? null
            : () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => QuizScreen(
                difficulty: widget.difficulty,
                category: selectedCategory!,
              ),
            ),
          );
        },
        icon: Icon(
          isEnabled
              ? Icons.play_arrow_rounded
              : Icons.touch_app_rounded,
          color: Colors.white,
        ),
        label: Text(
          isEnabled
              ? 'Start ${selectedCategory!.toUpperCase()} Quiz'
              : 'Select a Category',
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w800,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          disabledBackgroundColor: Colors.transparent,
          foregroundColor: Colors.white,
          disabledForegroundColor:
          Colors.white.withValues(alpha: 0.85),
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(19),
          ),
        ),
      ),
    );
  }
}