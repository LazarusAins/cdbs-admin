import 'dart:convert';
import 'package:http/http.dart' as http;
import 'dart:async';

class ApiService {
  final String apiUrl;

  ApiService(this.apiUrl);

  Future<List<Map<String, dynamic>>> fetchAdmissionForms(String supabaseUrl, String supabaseKey) async {
    final response = await http.get(
      Uri.parse('$apiUrl/api/admin/get_admission'),
      headers: {
        "supabase-url": supabaseUrl,
        "supabase-key": supabaseKey,
      },
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      
      // Ensure the type safety by converting to List<Map<String, dynamic>>
      return List<Map<String, dynamic>>.from(data['user'] ?? []);
      
    } else {
      throw Exception('Failed to form data');
    }
  }

  Stream<List<Map<String, dynamic>>> streamAdmissionForms(String supabaseUrl, String supabaseKey) async* {
    while (true) {
      try {
        final members = await fetchAdmissionForms(supabaseUrl, supabaseKey);
        yield members; // Emit the list of members
      } catch (e) {
        print('Error fetching members: $e');
        yield []; // Emit an empty list on error
      }

      await Future.delayed(const Duration(seconds: 3)); // Refresh every 10 seconds
    }
  }

  /*Stream<List<Map<String, dynamic>>> streamMembers(String supabaseUrl, String supabaseKey) async* {
    while (true) {
      try {
        final response = await http.get(
          Uri.parse('https://medicareplus-api.vercel.app/api/admin/get_all_members'),
          headers: {
            'Content-Type': 'application/json',
            'supabase-url': supabaseUrl,
            'supabase-key': supabaseKey,
          },
        );

        if (response.statusCode == 200) {
          final data = json.decode(response.body);
          yield List<Map<String, dynamic>>.from(data['members'] ?? []);
        } else {
          throw Exception('Failed to load status count');
        }
      } catch (e) {
        print('Error: $e');
        yield []; // Emit an empty list on error
      }

      await Future.delayed(const Duration(seconds: 5)); // Refresh every 5 seconds
    }
  }*/

}
