import 'package:supabase_flutter/supabase_flutter.dart';

final supabase = Supabase.instance.client;

class ShowService {
  Future<void> addShow({
    required String title,
    required String description,
    required DateTime date,
  }) async {
    final response = await supabase.from('shows').insert({
      'title': title,
      'description': description,
      'date': date.toIso8601String(),
    });

    if (response.error != null) {
      throw Exception('Failed to add show: ${response.error!.message}');
    }
  }



}

