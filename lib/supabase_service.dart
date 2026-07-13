import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseService {
  final SupabaseClient supabase = Supabase.instance.client;

  Future<List<Map<String, dynamic>>> fetchQuizzes() async {
    final response = await supabase
        .from('quizzes')
        .select();

    return List<Map<String, dynamic>>.from(response);
  }
}