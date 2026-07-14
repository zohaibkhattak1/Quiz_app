import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'supabase_service.dart';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:syncfusion_flutter_pdf/pdf.dart';

class DocumentUploadScreen extends StatefulWidget {
  const DocumentUploadScreen({super.key});

  @override
  State<DocumentUploadScreen> createState() =>
      _DocumentUploadScreenState();
}

class _DocumentUploadScreenState
    extends State<DocumentUploadScreen> {
  // API key flutter run command se receive hogi.
  static const String geminiApiKey =
  String.fromEnvironment('GEMINI_API_KEY');

  static const String openRouterApiKey =
  String.fromEnvironment('OPENROUTER_API_KEY');

  int selectedQuestionCount = 10;

  String selectedDifficulty = 'medium';

  int easyPercentage = 30;
  int mediumPercentage = 40;
  int hardPercentage = 30;

  int get totalMixPercentage =>
      easyPercentage + mediumPercentage + hardPercentage;

  final List<int> percentageOptions = [
    0, 10, 20, 30, 40, 50, 60, 70, 80, 90, 100,
  ];

  final List<Map<String, dynamic>> difficulties = [
    {
      'name': 'Easy',
      'value': 'easy',
      'icon': Icons.sentiment_satisfied_alt_rounded,
      'description': 'Basic understanding',
    },
    {
      'name': 'Medium',
      'value': 'medium',
      'icon': Icons.psychology_alt_rounded,
      'description': 'Conceptual questions',
    },
    {
      'name': 'Hard',
      'value': 'hard',
      'icon': Icons.local_fire_department_rounded,
      'description': 'Analytical questions',
    },
    {
      'name': 'Mix',
      'value': 'mix',
      'icon': Icons.shuffle_rounded,
      'description': 'Easy, medium and hard',
    },
  ];

  final List<int> questionCounts = [
    10,
    20,
    30,
    40,
    50,
  ];

  PlatformFile? selectedFile;

  bool isPickingFile = false;
  bool isGeneratingQuestions = false;

  String statusMessage = '';

  List<Map<String, dynamic>> generatedQuestions = [];

  int currentQuestionIndex = 0;
  final Map<int, String> selectedAnswers = {};
  bool quizFinished = false;

  // ================= FILE SELECT =================

  Future<void> selectDocument() async {
    try {
      setState(() {
        isPickingFile = true;
        statusMessage = '';
        generatedQuestions = [];
        currentQuestionIndex = 0;
        selectedAnswers.clear();
        quizFinished = false;
      });

      final FilePickerResult? result =
      await FilePicker.pickFiles(
        type: FileType.custom,
        allowedExtensions: [
          'pdf',
          'txt',
        ],
        allowMultiple: false,
        withData: false,
      );

      if (result == null || result.files.isEmpty) {
        return;
      }

      final PlatformFile file = result.files.single;

      if (file.path == null) {
        throw Exception('Selected file ka path nahi mila.');
      }

      setState(() {
        selectedFile = file;
        statusMessage = '${file.name} successfully select ho gayi.';
      });

      debugPrint('Selected file: ${file.name}');
      debugPrint('File path: ${file.path}');
      debugPrint('File extension: ${file.extension}');
    } catch (error) {
      showMessage(
        'Document select nahi ho saka: $error',
      );
    } finally {
      if (mounted) {
        setState(() {
          isPickingFile = false;
        });
      }
    }
  }

  // ================= TEXT EXTRACTION =================

  Future<String> extractDocumentText(
      PlatformFile file,
      ) async {
    final String? filePath = file.path;

    if (filePath == null) {
      throw Exception('Document ka path available nahi hai.');
    }

    final String extension =
        file.extension?.toLowerCase() ?? '';

    if (extension == 'txt') {
      final File textFile = File(filePath);

      final String text = await textFile.readAsString();

      return text.trim();
    }

    if (extension == 'pdf') {
      final File pdfFile = File(filePath);

      final List<int> pdfBytes =
      await pdfFile.readAsBytes();

      final PdfDocument pdfDocument = PdfDocument(
        inputBytes: pdfBytes,
      );

      try {
        final String extractedText =
        PdfTextExtractor(
          pdfDocument,
        ).extractText();

        return extractedText.trim();
      } finally {
        pdfDocument.dispose();
      }
    }

    throw Exception(
      'Abhi sirf PDF aur TXT files supported hain.',
    );
  }

  String getDifficultyInstructions() {
    switch (selectedDifficulty) {
      case 'easy':
        return '''
Create EASY difficulty questions.

The questions should:
- Test basic understanding
- Focus on simple facts and definitions
- Avoid confusing or tricky wording
- Be suitable for beginners
''';

      case 'hard':
        return '''
Create HARD difficulty questions.

The questions should:
- Require deep understanding
- Include analytical and reasoning-based questions
- Include scenario-based questions where possible
- Use challenging but fair options
- Avoid questions that can be answered through simple guessing
''';

      case 'mix':
        return '''
Create a MIXED difficulty quiz.

Use this exact difficulty distribution:
- $easyPercentage% Easy questions
- $mediumPercentage% Medium questions
- $hardPercentage% Hard questions

The total distribution is 100%. Follow these percentages as closely as possible based on the selected question count.

Mix and shuffle all difficulty levels.
Do not arrange questions from easy to hard.
''';

      case 'medium':
      default:
        return '''
Create MEDIUM difficulty questions.

The questions should:
- Test conceptual understanding
- Include basic application-based questions
- Be moderately challenging
- Avoid questions that are too simple or too advanced
''';
    }
  }

  // ================= AI QUESTION GENERATION =================
  Future<List<Map<String, dynamic>>> generateQuestionsWithAI(
      PlatformFile file,
      ) async {
    if (geminiApiKey.trim().isEmpty &&
        openRouterApiKey.trim().isEmpty) {
      throw Exception(
        'Gemini aur OpenRouter dono API keys missing hain.',
      );
    }

    final String? filePath = file.path;

    if (filePath == null) {
      throw Exception('Selected file ka path nahi mila.');
    }

    final String extension = file.extension?.toLowerCase() ?? '';

    final String difficultyInstructions =
    getDifficultyInstructions();

    final String prompt = '''
Generate exactly $selectedQuestionCount multiple-choice questions
ONLY from the MAIN EDUCATIONAL CONTENT of the document.

SELECTED DIFFICULTY:
${selectedDifficulty.toUpperCase()}

DIFFICULTY INSTRUCTIONS:

$difficultyInstructions

IMPORTANT CONTENT RULES:

DO NOT create questions about:
- Author name
- Document title
- File name
- Number of pages
- Page numbers
- Headers
- Footers
- References
- Table of contents
- Copyright
- Publisher

Create questions ONLY from:
- Concepts
- Definitions
- Facts
- Explanations
- Processes
- Examples
- Causes
- Effects

Ignore all metadata and document information.

QUESTION RULES:

- Every question must have exactly 4 options.
- Only one option must be correct.
- correct_answer must exactly match one option.
- Do not create duplicate questions.
- Do not create meaningless or unrelated questions.
- Keep the language clear and grammatically correct.

Return ONLY valid JSON.
Do not include markdown.
Do not include explanations.
Do not include text before or after the JSON.

JSON format:

[
  {
    "question": "Question",
    "options": [
      "Option A",
      "Option B",
      "Option C",
      "Option D"
    ],
    "correct_answer": "Correct Option"
  }
]
''';

    if (geminiApiKey.trim().isNotEmpty) {
      try {
        if (mounted) {
          setState(() {
            statusMessage = 'Gemini se quiz generate ho raha hai...';
          });
        }

        return await generateWithGemini(
          file: file,
          prompt: prompt,
        );
      } catch (error) {
        debugPrint('Gemini failed: $error');

        final String errorText = error.toString().toLowerCase();

        final bool shouldUseFallback =
            errorText.contains('quota') ||
                errorText.contains('too_many_requests') ||
                errorText.contains('429') ||
                errorText.contains('rate limit') ||
                errorText.contains('server busy') ||
                errorText.contains('timeout');

        if (!shouldUseFallback ||
            openRouterApiKey.trim().isEmpty) {
          rethrow;
        }

        if (mounted) {
          setState(() {
            statusMessage =
            'Gemini limit complete hai. Free fallback AI try ho rahi hai...';
          });
        }
      }
    }

    if (openRouterApiKey.trim().isEmpty) {
      throw Exception(
        'Gemini unavailable hai aur OpenRouter key nahi mili.',
      );
    }

    return generateWithOpenRouter(
      file: file,
      prompt: prompt,
      extension: extension,
      filePath: filePath,
    );
  }

  Future<List<Map<String, dynamic>>> generateWithGemini({
    required PlatformFile file,
    required String prompt,
  }) async {
    final String? filePath = file.path;

    if (filePath == null) {
      throw Exception('Selected file ka path nahi mila.');
    }

    final String extension = file.extension?.toLowerCase() ?? '';
    final List<Map<String, dynamic>> input = [];

    if (extension == 'pdf') {
      final List<int> pdfBytes = await File(filePath).readAsBytes();

      if (pdfBytes.isEmpty) {
        throw Exception('PDF file read nahi ho saki.');
      }

      if (pdfBytes.length > 20 * 1024 * 1024) {
        throw Exception(
          'PDF bohat bari hai. 20 MB se choti PDF select karo.',
        );
      }

      input.add({
        'type': 'document',
        'data': base64Encode(pdfBytes),
        'mime_type': 'application/pdf',
      });

      input.add({
        'type': 'text',
        'text': prompt,
      });
    } else if (extension == 'txt') {
      final String documentText =
      (await File(filePath).readAsString()).trim();

      if (documentText.isEmpty) {
        throw Exception('TXT document empty hai.');
      }

      final String limitedText = documentText.length > 18000
          ? documentText.substring(0, 18000)
          : documentText;

      input.add({
        'type': 'text',
        'text': '''
$prompt

DOCUMENT:
$limitedText
''',
      });
    } else {
      throw Exception('Abhi sirf PDF aur TXT files supported hain.');
    }

    final Uri apiUrl = Uri.parse(
      'https://generativelanguage.googleapis.com/v1beta/interactions',
    );

    final http.Response response = await http
        .post(
      apiUrl,
      headers: {
        'Content-Type': 'application/json',
        'x-goog-api-key': geminiApiKey,
      },
      body: jsonEncode({
        'model': 'gemini-3.5-flash',
        'input': input,
        'generation_config': {
          'temperature': 0.2,
        },
      }),
    )
        .timeout(const Duration(seconds: 60));

    if (response.statusCode != 200) {
      String apiError = response.body;

      try {
        final dynamic errorJson = jsonDecode(response.body);
        apiError =
            errorJson['error']?['message']?.toString() ??
                response.body;
      } catch (_) {}

      throw Exception(
        'Gemini request failed (${response.statusCode}): $apiError',
      );
    }

    final Map<String, dynamic> responseData =
    Map<String, dynamic>.from(jsonDecode(response.body));

    final List<dynamic> outputs =
        responseData['outputs'] as List<dynamic>? ?? [];

    String aiText = '';

    for (final dynamic output in outputs) {
      if (output is Map &&
          output['type'] == 'text' &&
          output['text'] != null) {
        aiText += output['text'].toString();
      }
    }

    if (aiText.trim().isEmpty) {
      final List<dynamic> steps =
          responseData['steps'] as List<dynamic>? ?? [];

      for (final dynamic step in steps.reversed) {
        if (step is! Map) continue;

        final List<dynamic> content =
            step['content'] as List<dynamic>? ?? [];

        for (final dynamic item in content) {
          if (item is Map &&
              item['type'] == 'text' &&
              item['text'] != null) {
            aiText += item['text'].toString();
          }
        }

        if (aiText.trim().isNotEmpty) break;
      }
    }

    return parseQuestions(aiText);
  }

  Future<List<Map<String, dynamic>>> generateWithOpenRouter({
    required PlatformFile file,
    required String prompt,
    required String extension,
    required String filePath,
  }) async {
    final List<dynamic> content = [
      {
        'type': 'text',
        'text': prompt,
      },
    ];

    if (extension == 'pdf') {
      final List<int> pdfBytes = await File(filePath).readAsBytes();

      if (pdfBytes.isEmpty) {
        throw Exception('PDF file read nahi ho saki.');
      }

      if (pdfBytes.length > 10 * 1024 * 1024) {
        throw Exception(
          'Fallback ke liye PDF 10 MB se choti honi chahiye.',
        );
      }

      content.add({
        'type': 'file',
        'file': {
          'filename': file.name,
          'file_data':
          'data:application/pdf;base64,${base64Encode(pdfBytes)}',
        },
      });
    } else if (extension == 'txt') {
      final String documentText =
      (await File(filePath).readAsString()).trim();

      if (documentText.isEmpty) {
        throw Exception('TXT document empty hai.');
      }

      final String limitedText = documentText.length > 18000
          ? documentText.substring(0, 18000)
          : documentText;

      content.add({
        'type': 'text',
        'text': 'DOCUMENT:\n$limitedText',
      });
    } else {
      throw Exception('Abhi sirf PDF aur TXT files supported hain.');
    }

    final http.Response response = await http
        .post(
      Uri.parse(
        'https://openrouter.ai/api/v1/chat/completions',
      ),
      headers: {
        'Authorization': 'Bearer $openRouterApiKey',
        'Content-Type': 'application/json',
        'X-OpenRouter-Title': 'AI Document Quiz',
      },
      body: jsonEncode({
        'model': 'openrouter/free',
        'messages': [
          {
            'role': 'user',
            'content': content,
          },
        ],
        'temperature': 0.2,
        'plugins': [
          {
            'id': 'file-parser',
            'pdf': {
              'engine': 'cloudflare-ai',
            },
          },
        ],
      }),
    )
        .timeout(const Duration(seconds: 90));

    if (response.statusCode != 200) {
      String apiError = response.body;

      try {
        final dynamic errorJson = jsonDecode(response.body);
        apiError =
            errorJson['error']?['message']?.toString() ??
                response.body;
      } catch (_) {}

      throw Exception(
        'Fallback AI failed (${response.statusCode}): $apiError',
      );
    }

    final Map<String, dynamic> responseData =
    Map<String, dynamic>.from(jsonDecode(response.body));

    final List<dynamic> choices =
        responseData['choices'] as List<dynamic>? ?? [];

    if (choices.isEmpty) {
      throw Exception('Fallback AI response empty hai.');
    }

    final dynamic message = choices.first['message'];
    final dynamic messageContent =
    message is Map ? message['content'] : null;

    String aiText = '';

    if (messageContent is String) {
      aiText = messageContent;
    } else if (messageContent is List) {
      for (final dynamic item in messageContent) {
        if (item is Map &&
            item['type'] == 'text' &&
            item['text'] != null) {
          aiText += item['text'].toString();
        }
      }
    }

    return parseQuestions(aiText);
  }

  List<Map<String, dynamic>> parseQuestions(String aiText) {
    if (aiText.trim().isEmpty) {
      throw Exception('AI response mein questions nahi mile.');
    }

    final String cleanedText = cleanJsonResponse(aiText);
    final dynamic decodedQuestions = jsonDecode(cleanedText);

    if (decodedQuestions is! List) {
      throw Exception(
        'AI response questions list ki form mein nahi hai.',
      );
    }

    final List<Map<String, dynamic>> questions =
    decodedQuestions.map<Map<String, dynamic>>((dynamic item) {
      if (item is! Map) {
        throw Exception('AI ne invalid question return kiya.');
      }

      final Map<String, dynamic> question =
      Map<String, dynamic>.from(item);

      final List<String> options =
      List<String>.from(question['options'] ?? []);

      final String questionText =
          question['question']?.toString().trim() ?? '';

      final String correctAnswer =
          question['correct_answer']?.toString().trim() ?? '';

      if (questionText.isEmpty ||
          options.length != 4 ||
          correctAnswer.isEmpty) {
        throw Exception('AI ne invalid question format return kiya.');
      }

      if (!options.contains(correctAnswer)) {
        throw Exception(
          'Correct answer options mein available nahi hai.',
        );
      }

      return {
        'question': questionText,
        'options': options,
        'correct_answer': correctAnswer,
      };
    }).toList();

    if (questions.isEmpty) {
      throw Exception('Generated questions list empty hai.');
    }

    return questions;
  }

  String cleanJsonResponse(String response) {
    String cleanResponse = response.trim();

    cleanResponse = cleanResponse
        .replaceFirst(
      RegExp(r'^```json\s*'),
      '',
    )
        .replaceFirst(
      RegExp(r'^```\s*'),
      '',
    )
        .replaceFirst(
      RegExp(r'\s*```$'),
      '',
    )
        .trim();

    final int arrayStart = cleanResponse.indexOf('[');
    final int arrayEnd = cleanResponse.lastIndexOf(']');

    if (arrayStart != -1 &&
        arrayEnd != -1 &&
        arrayEnd > arrayStart) {
      cleanResponse = cleanResponse.substring(
        arrayStart,
        arrayEnd + 1,
      );
    }

    return cleanResponse;
  }

  // ================= MAIN BUTTON FUNCTION =================
  Future<void> continueToQuizGeneration() async {
    if (selectedDifficulty == 'mix' && totalMixPercentage != 100) {
      showMessage(
        'Mix percentages ka total 100% hona chahiye. Abhi $totalMixPercentage% hai.',
      );
      return;
    }

    if (selectedFile == null) {
      showMessage(
        'Pehle koi PDF ya TXT document select karo.',
      );
      return;
    }

    try {
      setState(() {
        isGeneratingQuestions = true;
        generatedQuestions = [];
        currentQuestionIndex = 0;
        selectedAnswers.clear();
        quizFinished = false;
        statusMessage =
        'AI document read karke questions bana rahi hai...';
      });

      debugPrint(
        'Selected extension: ${selectedFile!.extension}',
      );

      // Pehle AI se questions generate honge
      final List<Map<String, dynamic>> questions =
      await generateQuestionsWithAI(
        selectedFile!,
      );

      // AI questions ko Supabase table format me convert karo
      final List<Map<String, dynamic>> supabaseQuestions =
      questions.map((question) {
        final List<String> options =
        List<String>.from(
          question['options'] ?? [],
        );

        return {
          'question': question['question'],
          'option_a': options[0],
          'option_b': options[1],
          'option_c': options[2],
          'option_d': options[3],
          'correct_answer': question['correct_answer'],
          'difficulty': selectedDifficulty,
          'category': 'document',
        };
      }).toList();

      // Supabase me permanently save karo
      await SupabaseService().saveQuestions(
        supabaseQuestions,
      );

      if (!mounted) return;

      setState(() {
        generatedQuestions = questions;
        currentQuestionIndex = 0;
        selectedAnswers.clear();
        quizFinished = false;
        statusMessage =
        '${questions.length} questions generate aur Supabase me save ho gaye.';
      });

      showMessage(
        '${questions.length} questions generate aur save ho gaye.',
      );
    } on SocketException {
      if (!mounted) return;

      setState(() {
        statusMessage =
        'Internet connection available nahi hai.';
      });

      showMessage(
        'Internet connection available nahi hai.',
      );
    } on TimeoutException {
      if (!mounted) return;

      setState(() {
        statusMessage =
        'AI ne response dene mein bohat time laga diya.';
      });

      showMessage(
        'Request timeout ho gayi. Dobara try karo.',
      );
    } on FormatException catch (error) {
      debugPrint(
        'JSON format error: $error',
      );

      if (!mounted) return;

      setState(() {
        statusMessage =
        'AI response samajhne mein problem hui.';
      });

      showMessage(
        'AI ne invalid JSON response return kiya.',
      );
    } catch (error) {
      debugPrint(
        'Generation error: $error',
      );

      if (!mounted) return;

      setState(() {
        statusMessage =
        'Questions generate ya save nahi ho sake.';
      });

      showMessage(
        'Questions generate ya save nahi ho sake: $error',
      );
    } finally {
      if (mounted) {
        setState(() {
          isGeneratingQuestions = false;
        });
      }
    }
  }


  void selectAnswer(String answer) {
    if (quizFinished) return;

    setState(() {
      selectedAnswers[currentQuestionIndex] = answer;
    });
  }

  void goToNextQuestion() {
    if (!selectedAnswers.containsKey(currentQuestionIndex)) {
      showMessage('Pehle koi option select karo.');
      return;
    }

    if (currentQuestionIndex < generatedQuestions.length - 1) {
      setState(() {
        currentQuestionIndex++;
      });
    } else {
      setState(() {
        quizFinished = true;
      });
    }
  }

  int calculateScore() {
    int score = 0;

    for (int index = 0; index < generatedQuestions.length; index++) {
      final String correctAnswer =
      generatedQuestions[index]['correct_answer'].toString();

      if (selectedAnswers[index] == correctAnswer) {
        score++;
      }
    }

    return score;
  }

  void restartGeneratedQuiz() {
    setState(() {
      currentQuestionIndex = 0;
      selectedAnswers.clear();
      quizFinished = false;
    });
  }

  Widget buildGeneratedQuiz() {
    final bool isDark =
        Theme.of(context).brightness == Brightness.dark;

    final Map<String, dynamic> question =
    generatedQuestions[currentQuestionIndex];

    final List<String> options =
    List<String>.from(question['options'] ?? []);

    final String? selectedAnswer =
    selectedAnswers[currentQuestionIndex];

    final double progress =
        (currentQuestionIndex + 1) / generatedQuestions.length;

    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                'Question ${currentQuestionIndex + 1} of ${generatedQuestions.length}',
                style: TextStyle(
                  color: isDark
                      ? const Color(0xffA5B4FC)
                      : const Color(0xff4F46E5),
                  fontWeight: FontWeight.w800,
                  fontSize: 15,
                ),
              ),
            ),
            Text(
              '${(progress * 100).round()}%',
              style: TextStyle(
                color: isDark
                    ? const Color(0xff94A3B8)
                    : const Color(0xff64748B),
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: LinearProgressIndicator(
            value: progress,
            minHeight: 9,
            backgroundColor: isDark
                ? const Color(0xff334155)
                : const Color(0xffE2E8F0),
            valueColor: const AlwaysStoppedAnimation<Color>(
              Color(0xff6366F1),
            ),
          ),
        ),
        const SizedBox(height: 18),
        Container(
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
                  size: 30,
                ),
              ),
              const SizedBox(height: 18),
              Text(
                question['question'].toString(),
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 20,
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
        const SizedBox(height: 18),
        ...List.generate(options.length, (int optionIndex) {
          final String option = options[optionIndex];
          final bool isSelected = selectedAnswer == option;

          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: InkWell(
              onTap: () => selectAnswer(option),
              borderRadius: BorderRadius.circular(19),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 220),
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 15,
                  vertical: 15,
                ),
                decoration: BoxDecoration(
                  color: isSelected
                      ? const Color(0xff6366F1)
                      : isDark
                      ? const Color(0xff0F172A)
                      : Colors.white,
                  borderRadius: BorderRadius.circular(19),
                  border: Border.all(
                    color: isSelected
                        ? const Color(0xff818CF8)
                        : isDark
                        ? const Color(0xff334155)
                        : const Color(0xffE2E8F0),
                    width: isSelected ? 2 : 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(
                        alpha: isDark ? 0.16 : 0.05,
                      ),
                      blurRadius: 14,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: isSelected
                            ? Colors.white.withValues(alpha: 0.18)
                            : const Color(0xff6366F1)
                            .withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(13),
                      ),
                      child: Text(
                        String.fromCharCode(65 + optionIndex),
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w900,
                          color: isSelected
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
                          color: isSelected
                              ? Colors.white
                              : isDark
                              ? const Color(0xffE2E8F0)
                              : const Color(0xff1E293B),
                        ),
                      ),
                    ),
                    if (isSelected)
                      const Icon(
                        Icons.check_circle_rounded,
                        color: Colors.white,
                      ),
                  ],
                ),
              ),
            ),
          );
        }),
        const SizedBox(height: 6),
        SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton.icon(
            onPressed: goToNextQuestion,
            icon: Icon(
              currentQuestionIndex ==
                  generatedQuestions.length - 1
                  ? Icons.flag_rounded
                  : Icons.arrow_forward_rounded,
            ),
            label: Text(
              currentQuestionIndex ==
                  generatedQuestions.length - 1
                  ? 'Finish Quiz'
                  : 'Next Question',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xff6366F1),
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget buildQuizResult() {
    final bool isDark =
        Theme.of(context).brightness == Brightness.dark;

    final int score = calculateScore();
    final double percentage = generatedQuestions.isEmpty
        ? 0
        : score / generatedQuestions.length;

    final String resultMessage = percentage >= 0.8
        ? 'Excellent work!'
        : percentage >= 0.5
        ? 'Good attempt!'
        : 'Keep practicing!';

    return Column(
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [
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
                    .withValues(alpha: 0.28),
                blurRadius: 28,
                offset: const Offset(0, 12),
              ),
            ],
          ),
          child: Column(
            children: [
              Container(
                width: 88,
                height: 88,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.22),
                  ),
                ),
                child: const Icon(
                  Icons.emoji_events_rounded,
                  size: 48,
                  color: Color(0xffFDE68A),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Quiz Completed!',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                resultMessage,
                style: const TextStyle(
                  fontSize: 15,
                  color: Color(0xffE0E7FF),
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 16,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '$score / ${generatedQuestions.length}',
                  style: const TextStyle(
                    fontSize: 34,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        Row(
          children: [
            Icon(
              Icons.fact_check_rounded,
              color: isDark
                  ? const Color(0xffA5B4FC)
                  : const Color(0xff4F46E5),
            ),
            const SizedBox(width: 8),
            Text(
              'Answer Review',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w900,
                color: isDark
                    ? Colors.white
                    : const Color(0xff0F172A),
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        ...List.generate(generatedQuestions.length, (int index) {
          final Map<String, dynamic> question =
          generatedQuestions[index];

          final String correctAnswer =
          question['correct_answer'].toString();

          final String selectedAnswer =
              selectedAnswers[index] ?? 'Not Answered';

          final bool isCorrect =
              selectedAnswer == correctAnswer;

          return Container(
            width: double.infinity,
            margin: const EdgeInsets.only(bottom: 13),
            padding: const EdgeInsets.all(17),
            decoration: BoxDecoration(
              color: isDark
                  ? const Color(0xff0F172A)
                  : Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isCorrect
                    ? const Color(0xff10B981)
                    .withValues(alpha: 0.35)
                    : const Color(0xffEF4444)
                    .withValues(alpha: 0.30),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 31,
                      height: 31,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: isCorrect
                            ? const Color(0xff10B981)
                            .withValues(alpha: 0.13)
                            : const Color(0xffEF4444)
                            .withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        isCorrect
                            ? Icons.check_rounded
                            : Icons.close_rounded,
                        size: 19,
                        color: isCorrect
                            ? const Color(0xff10B981)
                            : const Color(0xffEF4444),
                      ),
                    ),
                    const SizedBox(width: 11),
                    Expanded(
                      child: Text(
                        '${index + 1}. ${question['question']}',
                        style: TextStyle(
                          fontSize: 15.5,
                          height: 1.4,
                          fontWeight: FontWeight.w800,
                          color: isDark
                              ? Colors.white
                              : const Color(0xff1E293B),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 13),
                Text(
                  'Your answer: $selectedAnswer',
                  style: TextStyle(
                    color: isCorrect
                        ? const Color(0xff10B981)
                        : const Color(0xffEF4444),
                    fontWeight: FontWeight.w700,
                  ),
                ),
                if (!isCorrect) ...[
                  const SizedBox(height: 6),
                  Text(
                    'Correct answer: $correctAnswer',
                    style: const TextStyle(
                      color: Color(0xff10B981),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ],
            ),
          );
        }),
        const SizedBox(height: 8),
        SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton.icon(
            onPressed: restartGeneratedQuiz,
            icon: const Icon(Icons.refresh_rounded),
            label: const Text(
              'Restart Quiz',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xff6366F1),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ================= HELPER FUNCTIONS =================

  void showMessage(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
      ),
    );
  }

  String getFileSize(int bytes) {
    if (bytes < 1024) {
      return '$bytes Bytes';
    }

    final double kilobytes = bytes / 1024;

    if (kilobytes < 1024) {
      return '${kilobytes.toStringAsFixed(1)} KB';
    }

    final double megabytes = kilobytes / 1024;

    return '${megabytes.toStringAsFixed(1)} MB';
  }

  IconData getFileIcon(String? extension) {
    switch (extension?.toLowerCase()) {
      case 'pdf':
        return Icons.picture_as_pdf_rounded;
      case 'txt':
        return Icons.text_snippet_rounded;
      default:
        return Icons.insert_drive_file_rounded;
    }
  }

  Widget buildHeaderCard(bool isDark) {
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
            color: const Color(0xff4F46E5).withValues(
              alpha: isDark ? 0.20 : 0.30,
            ),
            blurRadius: 28,
            offset: const Offset(0, 13),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            right: -30,
            top: -38,
            child: Container(
              width: 130,
              height: 130,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.08),
              ),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 65,
                height: 65,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [
                      Color(0xff22D3EE),
                      Color(0xff818CF8),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(21),
                ),
                child: const Icon(
                  Icons.auto_awesome_rounded,
                  size: 34,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 19),
              const Text(
                'Turn Your Notes\nInto Smart Quizzes',
                style: TextStyle(
                  fontSize: 29,
                  height: 1.18,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -0.5,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                'Upload a PDF or TXT file and create an interactive quiz from its learning content.',
                style: TextStyle(
                  fontSize: 14.5,
                  height: 1.55,
                  color: Color(0xffE0E7FF),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget buildQuestionCountCard(bool isDark) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        color: isDark
            ? const Color(0xff0F172A)
            : Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: isDark
              ? const Color(0xff334155)
              : const Color(0xffE2E8F0),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 49,
            height: 49,
            decoration: BoxDecoration(
              color: const Color(0xff6366F1)
                  .withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(
              Icons.format_list_numbered_rounded,
              color: Color(0xff6366F1),
            ),
          ),
          const SizedBox(width: 13),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Number of Questions',
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    color: isDark
                        ? Colors.white
                        : const Color(0xff1E293B),
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  'Choose how many MCQs to create',
                  style: TextStyle(
                    fontSize: 12.5,
                    color: isDark
                        ? const Color(0xff94A3B8)
                        : const Color(0xff64748B),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          DropdownButtonHideUnderline(
            child: DropdownButton<int>(
              value: selectedQuestionCount,
              borderRadius: BorderRadius.circular(16),
              dropdownColor: isDark
                  ? const Color(0xff0F172A)
                  : Colors.white,
              icon: const Icon(
                Icons.keyboard_arrow_down_rounded,
                color: Color(0xff6366F1),
              ),
              items: questionCounts.map((int count) {
                return DropdownMenuItem<int>(
                  value: count,
                  child: Text(
                    '$count',
                    style: TextStyle(
                      fontWeight: FontWeight.w900,
                      color: isDark
                          ? Colors.white
                          : const Color(0xff1E293B),
                    ),
                  ),
                );
              }).toList(),
              onChanged: isGeneratingQuestions
                  ? null
                  : (int? value) {
                if (value == null) return;

                setState(() {
                  selectedQuestionCount = value;
                  generatedQuestions = [];
                  currentQuestionIndex = 0;
                  selectedAnswers.clear();
                  quizFinished = false;
                });
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget buildDifficultyCard(bool isDark) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        color: isDark
            ? const Color(0xff0F172A)
            : Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: isDark
              ? const Color(0xff334155)
              : const Color(0xffE2E8F0),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(
              alpha: isDark ? 0.16 : 0.04,
            ),
            blurRadius: 16,
            offset: const Offset(0, 7),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 49,
                height: 49,
                decoration: BoxDecoration(
                  color: const Color(0xff7C3AED)
                      .withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(
                  Icons.tune_rounded,
                  color: Color(0xff7C3AED),
                ),
              ),
              const SizedBox(width: 13),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Question Difficulty',
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 16,
                        color: isDark
                            ? Colors.white
                            : const Color(0xff1E293B),
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      'Choose the level of generated questions',
                      style: TextStyle(
                        fontSize: 12.5,
                        color: isDark
                            ? const Color(0xff94A3B8)
                            : const Color(0xff64748B),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 17),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: difficulties.length,
            gridDelegate:
            const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 11,
              mainAxisSpacing: 11,
              childAspectRatio: 1.65,
            ),
            itemBuilder: (BuildContext context, int index) {
              final Map<String, dynamic> difficulty =
              difficulties[index];

              final String difficultyValue =
              difficulty['value'].toString();

              final bool isSelected =
                  selectedDifficulty == difficultyValue;

              return InkWell(
                onTap: isGeneratingQuestions
                    ? null
                    : () {
                  setState(() {
                    selectedDifficulty = difficultyValue;
                    generatedQuestions = [];
                    currentQuestionIndex = 0;
                    selectedAnswers.clear();
                    quizFinished = false;
                  });
                },
                borderRadius: BorderRadius.circular(17),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 220),
                  padding: const EdgeInsets.all(13),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? const Color(0xff6366F1)
                        : isDark
                        ? const Color(0xff1E293B)
                        : const Color(0xffF8FAFC),
                    borderRadius: BorderRadius.circular(17),
                    border: Border.all(
                      color: isSelected
                          ? const Color(0xff818CF8)
                          : isDark
                          ? const Color(0xff334155)
                          : const Color(0xffE2E8F0),
                      width: isSelected ? 2 : 1,
                    ),
                    boxShadow: isSelected
                        ? [
                      BoxShadow(
                        color: const Color(0xff6366F1)
                            .withValues(alpha: 0.24),
                        blurRadius: 15,
                        offset: const Offset(0, 7),
                      ),
                    ]
                        : [],
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 38,
                        height: 38,
                        decoration: BoxDecoration(
                          color: isSelected
                              ? Colors.white.withValues(alpha: 0.18)
                              : const Color(0xff6366F1)
                              .withValues(alpha: 0.11),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          difficulty['icon'] as IconData,
                          size: 21,
                          color: isSelected
                              ? Colors.white
                              : const Color(0xff6366F1),
                        ),
                      ),
                      const SizedBox(width: 9),
                      Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              difficulty['name'].toString(),
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w900,
                                color: isSelected
                                    ? Colors.white
                                    : isDark
                                    ? Colors.white
                                    : const Color(0xff1E293B),
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              difficulty['description'].toString(),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 10.5,
                                height: 1.2,
                                color: isSelected
                                    ? const Color(0xffE0E7FF)
                                    : isDark
                                    ? const Color(0xff94A3B8)
                                    : const Color(0xff64748B),
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (isSelected)
                        const Icon(
                          Icons.check_circle_rounded,
                          color: Colors.white,
                          size: 19,
                        ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget buildMixPercentageCard(bool isDark) {
    Widget percentageRow({
      required String title,
      required int value,
      required IconData icon,
      required ValueChanged<int?> onChanged,
    }) {
      return Container(
        margin: const EdgeInsets.only(bottom: 11),
        padding: const EdgeInsets.symmetric(
          horizontal: 13,
          vertical: 10,
        ),
        decoration: BoxDecoration(
          color: isDark
              ? const Color(0xff1E293B)
              : const Color(0xffF8FAFC),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isDark
                ? const Color(0xff334155)
                : const Color(0xffE2E8F0),
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 39,
              height: 39,
              decoration: BoxDecoration(
                color: const Color(0xff6366F1)
                    .withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                size: 21,
                color: const Color(0xff6366F1),
              ),
            ),
            const SizedBox(width: 11),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontWeight: FontWeight.w800,
                  color: isDark
                      ? Colors.white
                      : const Color(0xff1E293B),
                ),
              ),
            ),
            DropdownButtonHideUnderline(
              child: DropdownButton<int>(
                value: value,
                borderRadius: BorderRadius.circular(14),
                dropdownColor: isDark
                    ? const Color(0xff0F172A)
                    : Colors.white,
                items: percentageOptions.map((int percentage) {
                  return DropdownMenuItem<int>(
                    value: percentage,
                    child: Text(
                      '$percentage%',
                      style: TextStyle(
                        fontWeight: FontWeight.w900,
                        color: isDark
                            ? Colors.white
                            : const Color(0xff1E293B),
                      ),
                    ),
                  );
                }).toList(),
                onChanged: isGeneratingQuestions ? null : onChanged,
              ),
            ),
          ],
        ),
      );
    }

    final bool isValidTotal = totalMixPercentage == 100;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      width: double.infinity,
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        color: isDark
            ? const Color(0xff0F172A)
            : Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: isValidTotal
              ? const Color(0xff10B981).withValues(alpha: 0.45)
              : const Color(0xffEF4444).withValues(alpha: 0.45),
          width: 1.4,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 49,
                height: 49,
                decoration: BoxDecoration(
                  color: const Color(0xff7C3AED)
                      .withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(
                  Icons.pie_chart_rounded,
                  color: Color(0xff7C3AED),
                ),
              ),
              const SizedBox(width: 13),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Mix Distribution',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                        color: isDark
                            ? Colors.white
                            : const Color(0xff1E293B),
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      'Easy, medium aur hard ka percentage select karo',
                      style: TextStyle(
                        fontSize: 12.5,
                        color: isDark
                            ? const Color(0xff94A3B8)
                            : const Color(0xff64748B),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          percentageRow(
            title: 'Easy Questions',
            value: easyPercentage,
            icon: Icons.sentiment_satisfied_alt_rounded,
            onChanged: (int? value) {
              if (value == null) return;
              setState(() {
                easyPercentage = value;
                generatedQuestions = [];
              });
            },
          ),
          percentageRow(
            title: 'Medium Questions',
            value: mediumPercentage,
            icon: Icons.psychology_alt_rounded,
            onChanged: (int? value) {
              if (value == null) return;
              setState(() {
                mediumPercentage = value;
                generatedQuestions = [];
              });
            },
          ),
          percentageRow(
            title: 'Hard Questions',
            value: hardPercentage,
            icon: Icons.local_fire_department_rounded,
            onChanged: (int? value) {
              if (value == null) return;
              setState(() {
                hardPercentage = value;
                generatedQuestions = [];
              });
            },
          ),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(
              horizontal: 13,
              vertical: 11,
            ),
            decoration: BoxDecoration(
              color: isValidTotal
                  ? const Color(0xff10B981).withValues(alpha: 0.11)
                  : const Color(0xffEF4444).withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              children: [
                Icon(
                  isValidTotal
                      ? Icons.check_circle_rounded
                      : Icons.error_rounded,
                  color: isValidTotal
                      ? const Color(0xff10B981)
                      : const Color(0xffEF4444),
                ),
                const SizedBox(width: 9),
                Expanded(
                  child: Text(
                    isValidTotal
                        ? 'Total: 100% — distribution ready hai.'
                        : 'Total: $totalMixPercentage% — isay 100% karo.',
                    style: TextStyle(
                      fontWeight: FontWeight.w800,
                      color: isValidTotal
                          ? const Color(0xff059669)
                          : const Color(0xffDC2626),
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

  Widget buildUploadCard(bool isDark) {
    return InkWell(
      onTap: isPickingFile || isGeneratingQuestions
          ? null
          : selectDocument,
      borderRadius: BorderRadius.circular(24),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(22),
        decoration: BoxDecoration(
          color: isDark
              ? const Color(0xff0F172A)
              : Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: const Color(0xff818CF8),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(
                alpha: isDark ? 0.18 : 0.05,
              ),
              blurRadius: 18,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: const Color(0xff6366F1)
                    .withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: isPickingFile
                  ? const Padding(
                padding: EdgeInsets.all(22),
                child: CircularProgressIndicator(
                  strokeWidth: 3,
                ),
              )
                  : const Icon(
                Icons.cloud_upload_rounded,
                size: 36,
                color: Color(0xff6366F1),
              ),
            ),
            const SizedBox(height: 15),
            Text(
              isPickingFile
                  ? 'Opening your files...'
                  : 'Select your document',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w900,
                color: isDark
                    ? Colors.white
                    : const Color(0xff0F172A),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Tap here to choose a PDF or TXT file',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: isDark
                    ? const Color(0xff94A3B8)
                    : const Color(0xff64748B),
              ),
            ),
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 7,
              ),
              decoration: BoxDecoration(
                color: const Color(0xff22D3EE)
                    .withValues(alpha: 0.11),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text(
                'PDF • TXT',
                style: TextStyle(
                  color: Color(0xff0891B2),
                  fontWeight: FontWeight.w900,
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildSelectedFileCard(bool isDark) {
    final PlatformFile file = selectedFile!;

    return Container(
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
      ),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: file.extension?.toLowerCase() == 'pdf'
                  ? const Color(0xffEF4444)
                  .withValues(alpha: 0.12)
                  : const Color(0xff22D3EE)
                  .withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Icon(
              getFileIcon(file.extension),
              size: 30,
              color: file.extension?.toLowerCase() == 'pdf'
                  ? const Color(0xffEF4444)
                  : const Color(0xff0891B2),
            ),
          ),
          const SizedBox(width: 13),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  file.name,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w900,
                    color: isDark
                        ? Colors.white
                        : const Color(0xff1E293B),
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  '${file.extension?.toUpperCase()} • ${getFileSize(file.size)}',
                  style: TextStyle(
                    color: isDark
                        ? const Color(0xff94A3B8)
                        : const Color(0xff64748B),
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            tooltip: 'Remove file',
            onPressed: isGeneratingQuestions
                ? null
                : () {
              setState(() {
                selectedFile = null;
                generatedQuestions = [];
                currentQuestionIndex = 0;
                selectedAnswers.clear();
                quizFinished = false;
                statusMessage = '';
              });
            },
            icon: const Icon(
              Icons.close_rounded,
              color: Color(0xffEF4444),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildStatusCard(bool isDark) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: isGeneratingQuestions
            ? const Color(0xff6366F1)
            .withValues(alpha: 0.12)
            : const Color(0xff22D3EE)
            .withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(17),
        border: Border.all(
          color: isGeneratingQuestions
              ? const Color(0xff6366F1)
              .withValues(alpha: 0.30)
              : const Color(0xff22D3EE)
              .withValues(alpha: 0.24),
        ),
      ),
      child: Row(
        children: [
          if (isGeneratingQuestions)
            const SizedBox(
              width: 22,
              height: 22,
              child: CircularProgressIndicator(
                strokeWidth: 2.5,
              ),
            )
          else
            const Icon(
              Icons.info_outline_rounded,
              color: Color(0xff0891B2),
            ),
          const SizedBox(width: 11),
          Expanded(
            child: Text(
              statusMessage,
              style: TextStyle(
                color: isDark
                    ? const Color(0xffE2E8F0)
                    : const Color(0xff334155),
                fontWeight: FontWeight.w700,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ================= UI =================

  @override
  Widget build(BuildContext context) {
    final bool isDark =
        Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'AI Document Quiz',
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
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(
              20,
              20,
              20,
              30,
            ),
            child: Column(
              children: [
                if (generatedQuestions.isEmpty) ...[
                  buildHeaderCard(isDark),
                  const SizedBox(height: 22),
                  buildQuestionCountCard(isDark),
                  const SizedBox(height: 16),
                  buildDifficultyCard(isDark),
                  if (selectedDifficulty == 'mix') ...[
                    const SizedBox(height: 16),
                    buildMixPercentageCard(isDark),
                  ],
                  const SizedBox(height: 16),
                  buildUploadCard(isDark),
                  if (selectedFile != null) ...[
                    const SizedBox(height: 16),
                    buildSelectedFileCard(isDark),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      height: 58,
                      child: ElevatedButton.icon(
                        onPressed: isGeneratingQuestions ||
                            (selectedDifficulty == 'mix' &&
                                totalMixPercentage != 100)
                            ? null
                            : continueToQuizGeneration,
                        icon: isGeneratingQuestions
                            ? const SizedBox(
                          width: 23,
                          height: 23,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            color: Colors.white,
                          ),
                        )
                            : const Icon(
                          Icons.bolt_rounded,
                        ),
                        label: Text(
                          isGeneratingQuestions
                              ? 'Generating Questions...'
                              : 'Create $selectedQuestionCount ${selectedDifficulty.toUpperCase()} Questions',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                          const Color(0xff6366F1),
                          foregroundColor: Colors.white,
                          disabledBackgroundColor:
                          const Color(0xff6366F1)
                              .withValues(alpha: 0.55),
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius:
                            BorderRadius.circular(18),
                          ),
                        ),
                      ),
                    ),
                  ],
                  if (statusMessage.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    buildStatusCard(isDark),
                  ],
                  const SizedBox(height: 22),
                  Row(
                    mainAxisAlignment:
                    MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.verified_user_outlined,
                        size: 16,
                        color: isDark
                            ? const Color(0xff64748B)
                            : const Color(0xff64748B),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'Supported formats: PDF and TXT',
                        style: TextStyle(
                          fontSize: 13,
                          color: isDark
                              ? const Color(0xff64748B)
                              : const Color(0xff64748B),
                        ),
                      ),
                    ],
                  ),
                ] else ...[
                  if (!quizFinished)
                    buildGeneratedQuiz()
                  else
                    buildQuizResult(),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}


