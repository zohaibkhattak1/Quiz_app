import 'dart:convert';
import 'dart:io';

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
  static const String geminiApiKey = String.fromEnvironment(
    'GEMINI_API_KEY',
  );

  int selectedQuestionCount = 10;

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

  // ================= FILE SELECT =================

  Future<void> selectDocument() async {
    try {
      setState(() {
        isPickingFile = true;
        statusMessage = '';
        generatedQuestions = [];
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

  // ================= AI QUESTION GENERATION =================

  Future<List<Map<String, dynamic>>> generateQuestionsWithAI(
      String documentText,
      ) async {
    if (geminiApiKey.trim().isEmpty) {
      throw Exception(
        'Gemini API key nahi mili. App ko '
            '--dart-define=GEMINI_API_KEY=YOUR_KEY '
            'ke saath run karo.',
      );
    }

    // Bohat large document API request ko heavy bana sakta hai.
    // Beginner version mein pehle 25,000 characters use kar rahe hain.
    final String limitedText = documentText.length > 25000
        ? documentText.substring(0, 25000)
        : documentText;

    final Uri apiUrl = Uri.parse(
      'https://generativelanguage.googleapis.com/'
          'v1beta/models/gemini-2.5-flash:generateContent',
    );

    final String prompt = '''
You are an educational quiz generator.

Generate exactly $selectedQuestionCount multiple-choice questions
from the provided study document.

Rules:
1. Use only information found in the document.
2. Every question must have exactly four options.
3. Only one option must be correct.
4. Do not add markdown or explanation.
5. Return only a valid JSON array.
6. Use this exact structure:

[
  {
    "question": "Question text",
    "options": [
      "Option A",
      "Option B",
      "Option C",
      "Option D"
    ],
    "correct_answer": "Exact correct option text"
  }
]

DOCUMENT:

$limitedText
''';

    final http.Response response = await http
        .post(
      apiUrl,
      headers: {
        'Content-Type': 'application/json',
        'x-goog-api-key': geminiApiKey,
      },
      body: jsonEncode({
        'contents': [
          {
            'parts': [
              {
                'text': prompt,
              }
            ]
          }
        ],
        'generationConfig': {
          'temperature': 0.3,
          'responseMimeType': 'application/json',
        }
      }),
    )
        .timeout(
      const Duration(seconds: 90),
    );

    debugPrint('AI status code: ${response.statusCode}');
    debugPrint('AI response: ${response.body}');

    if (response.statusCode != 200) {
      String apiError = response.body;

      try {
        final dynamic errorJson = jsonDecode(
          response.body,
        );

        apiError =
            errorJson['error']?['message'] ?? response.body;
      } catch (_) {
        // Original response body use hogi.
      }

      throw Exception(
        'AI request failed: $apiError',
      );
    }

    final Map<String, dynamic> responseData =
    jsonDecode(response.body);

    final List<dynamic>? candidates =
    responseData['candidates'];

    if (candidates == null || candidates.isEmpty) {
      throw Exception(
        'AI ne koi question return nahi kiya.',
      );
    }

    final dynamic content = candidates.first['content'];

    final List<dynamic>? parts = content?['parts'];

    if (parts == null || parts.isEmpty) {
      throw Exception(
        'AI response mein content available nahi hai.',
      );
    }

    String aiText = parts.first['text']?.toString() ?? '';

    aiText = cleanJsonResponse(aiText);

    final dynamic decodedQuestions = jsonDecode(aiText);

    if (decodedQuestions is! List) {
      throw Exception(
        'AI response questions list ki form mein nahi hai.',
      );
    }

    final List<Map<String, dynamic>> questions =
    decodedQuestions.map<Map<String, dynamic>>(
          (dynamic item) {
        final Map<String, dynamic> question =
        Map<String, dynamic>.from(item);

        final List<String> options =
        List<String>.from(
          question['options'] ?? [],
        );

        if (question['question'] == null ||
            options.length != 4 ||
            question['correct_answer'] == null) {
          throw Exception(
            'AI ne invalid question format return kiya.',
          );
        }

        return {
          'question': question['question'].toString(),
          'options': options,
          'correct_answer':
          question['correct_answer'].toString(),
        };
      },
    ).toList();

    if (questions.isEmpty) {
      throw Exception(
        'Generated questions list empty hai.',
      );
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
        statusMessage = 'Document read ho raha hai...';
      });

      final String documentText =
      await extractDocumentText(selectedFile!);

      debugPrint('Extracted characters: ${documentText.length}');

      if (documentText.trim().isEmpty) {
        throw Exception(
          'Document se text nahi mila. '
              'PDF scanned image ho sakti hai.',
        );
      }

      if (documentText.trim().length < 50) {
        throw Exception(
          'Document mein quiz banane ke liye '
              'kaafi text available nahi hai.',
        );
      }

      if (!mounted) return;

      setState(() {
        statusMessage =
        'AI $selectedQuestionCount questions bana rahi hai...';
      });

      final List<Map<String, dynamic>> questions =
      await generateQuestionsWithAI(documentText);

      if (!mounted) return;

      setState(() {
        generatedQuestions = questions;
        statusMessage =
        '${questions.length} questions successfully generate ho gaye.';
      });

      showMessage(
        '${questions.length} questions generate ho gaye.',
      );
    } on SocketException {
      showMessage(
        'Internet connection available nahi hai.',
      );

      if (mounted) {
        setState(() {
          statusMessage =
          'Internet connection available nahi hai.';
        });
      }
    } on FormatException {
      showMessage(
        'AI ne invalid JSON response return kiya.',
      );

      if (mounted) {
        setState(() {
          statusMessage =
          'AI response samajhne mein problem hui.';
        });
      }
    } catch (error) {
      debugPrint('Generation error: $error');

      showMessage(
        'Questions generate nahi ho sake: $error',
      );

      if (mounted) {
        setState(() {
          statusMessage =
          'Questions generate nahi ho sake.';
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          isGeneratingQuestions = false;
        });
      }
    }
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

  // ================= UI =================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'AI Document Quiz',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        backgroundColor: const Color(0xff6C63FF),
        foregroundColor: Colors.white,
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xff6C5CE7),
              Color(0xffA29BFE),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(height: 20),

                const Icon(
                  Icons.auto_awesome_rounded,
                  size: 75,
                  color: Colors.white,
                ),

                const SizedBox(height: 15),

                const Text(
                  'Create Quiz From Document',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),

                const SizedBox(height: 10),

                const Text(
                  'PDF ya TXT document select karo aur '
                      'AI us se MCQs generate karegi.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 15,
                    color: Colors.white70,
                    height: 1.5,
                  ),
                ),

                const SizedBox(height: 25),

                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<int>(
                      value: selectedQuestionCount,
                      isExpanded: true,
                      items: questionCounts.map(
                            (int count) {
                          return DropdownMenuItem<int>(
                            value: count,
                            child: Text(
                              '$count Questions',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Color(0xff2C2C54),
                              ),
                            ),
                          );
                        },
                      ).toList(),
                      onChanged: isGeneratingQuestions
                          ? null
                          : (int? value) {
                        if (value == null) return;

                        setState(() {
                          selectedQuestionCount = value;
                          generatedQuestions = [];
                        });
                      },
                    ),
                  ),
                ),

                const SizedBox(height: 18),

                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton.icon(
                    onPressed:
                    isPickingFile || isGeneratingQuestions
                        ? null
                        : selectDocument,
                    icon: isPickingFile
                        ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                      ),
                    )
                        : const Icon(
                      Icons.folder_open_rounded,
                    ),
                    label: Text(
                      isPickingFile
                          ? 'Opening Files...'
                          : 'Select PDF or TXT',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor:
                      const Color(0xff6C5CE7),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                  ),
                ),

                if (selectedFile != null) ...[
                  const SizedBox(height: 18),

                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(15),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          getFileIcon(
                            selectedFile!.extension,
                          ),
                          size: 38,
                          color: const Color(0xff6C5CE7),
                        ),

                        const SizedBox(width: 12),

                        Expanded(
                          child: Column(
                            crossAxisAlignment:
                            CrossAxisAlignment.start,
                            children: [
                              Text(
                                selectedFile!.name,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xff2C2C54),
                                ),
                              ),

                              const SizedBox(height: 4),

                              Text(
                                '${selectedFile!.extension?.toUpperCase()}'
                                    ' • '
                                    '${getFileSize(selectedFile!.size)}',
                                style: TextStyle(
                                  color: Colors.grey.shade700,
                                ),
                              ),
                            ],
                          ),
                        ),

                        IconButton(
                          onPressed: isGeneratingQuestions
                              ? null
                              : () {
                            setState(() {
                              selectedFile = null;
                              generatedQuestions = [];
                              statusMessage = '';
                            });
                          },
                          icon: const Icon(
                            Icons.close_rounded,
                            color: Colors.redAccent,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 18),

                  SizedBox(
                    width: double.infinity,
                    height: 58,
                    child: ElevatedButton.icon(
                      onPressed: isGeneratingQuestions
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
                        Icons.auto_awesome_rounded,
                      ),
                      label: Text(
                        isGeneratingQuestions
                            ? 'Generating Questions...'
                            : 'Create $selectedQuestionCount Questions',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                        const Color(0xff00B894),
                        foregroundColor: Colors.white,
                        disabledBackgroundColor:
                        const Color(0xff00B894)
                            .withValues(alpha: 0.65),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                    ),
                  ),
                ],

                if (statusMessage.isNotEmpty) ...[
                  const SizedBox(height: 18),

                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(
                        alpha: 0.18,
                      ),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Text(
                      statusMessage,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],

                if (generatedQuestions.isNotEmpty) ...[
                  const SizedBox(height: 25),

                  const Text(
                    'Generated Questions',
                    style: TextStyle(
                      fontSize: 23,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),

                  const SizedBox(height: 15),

                  ...List.generate(
                    generatedQuestions.length,
                        (int index) {
                      final Map<String, dynamic> question =
                      generatedQuestions[index];

                      final List<String> options =
                      List<String>.from(
                        question['options'],
                      );

                      return Container(
                        width: double.infinity,
                        margin: const EdgeInsets.only(
                          bottom: 15,
                        ),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(18),
                        ),
                        child: Column(
                          crossAxisAlignment:
                          CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Question ${index + 1}',
                              style: const TextStyle(
                                color: Color(0xff6C5CE7),
                                fontWeight: FontWeight.bold,
                              ),
                            ),

                            const SizedBox(height: 8),

                            Text(
                              question['question'].toString(),
                              style: const TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.bold,
                                color: Color(0xff2C2C54),
                              ),
                            ),

                            const SizedBox(height: 12),

                            ...List.generate(
                              options.length,
                                  (int optionIndex) {
                                return Container(
                                  width: double.infinity,
                                  margin: const EdgeInsets.only(
                                    bottom: 8,
                                  ),
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: const Color(0xffF3F1FF),
                                    borderRadius:
                                    BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    '${String.fromCharCode(65 + optionIndex)}. '
                                        '${options[optionIndex]}',
                                    style: const TextStyle(
                                      color: Color(0xff2C2C54),
                                    ),
                                  ),
                                );
                              },
                            ),

                            const SizedBox(height: 5),

                            Text(
                              'Correct Answer: '
                                  '${question['correct_answer']}',
                              style: const TextStyle(
                                color: Color(0xff00A878),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ],

                const SizedBox(height: 20),

                const Text(
                  'Supported formats: PDF and TXT',
                  style: TextStyle(
                    color: Colors.white70,
                  ),
                ),

                const SizedBox(height: 25),
              ],
            ),
          ),
        ),
      ),
    );
  }
}