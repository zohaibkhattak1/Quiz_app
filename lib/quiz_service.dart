import 'dart:convert';
import 'package:http/http.dart' as http;

class QuizService {
  Future<List<dynamic>> fetchQuestions({
    required String difficulty,
    required int category,
  }) async {
    final url = Uri.parse(
      "https://opentdb.com/api.php?amount=10&category=$category&difficulty=$difficulty&type=multiple",
    );

    final response = await http.get(url);

    print("Difficulty: $difficulty");
    print("Category: $category");
    print("Status Code: ${response.statusCode}");
    print("Response Body: ${response.body}");

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      if (data["response_code"] == 0) {
        return data["results"];
      } else {
        return [];
      }
    } else {
      throw Exception("Failed to load questions");
    }
  }
}