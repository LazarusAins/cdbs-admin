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

  /*Stream<List<Map<String, dynamic>>> streamAdmissionForms(String supabaseUrl, String supabaseKey) async* {
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
  }*/
  Stream<List<Map<String, dynamic>>> streamAdmissionForms(String supabaseUrl, String supabaseKey) async* {
  while (true) {
    try {
      // Fetch the admission forms (assuming fetchAdmissionForms is already defined)
      final members = await fetchAdmissionForms(supabaseUrl, supabaseKey);
      
      // Filter out the members where db_admission_table is null
      final filteredMembers = members.where((member) {
        // Ensure db_admission_table is not null
        return member['db_admission_table'] != null;
      }).toList(); // Convert the iterable to a list

      // Emit the filtered list of members
      yield filteredMembers;
    } catch (e) {
      print('Error fetching members: $e');
      yield []; // Emit an empty list on error
    }

    // Delay the next fetch
    await Future.delayed(const Duration(seconds: 3)); // Refresh every 3 seconds
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


  Future<List<Map<String, dynamic>>> getDetailsById(int admissionId, String supabaseUrl, String supabaseKey) async {
  try {
    final response = await http.post(
      Uri.parse('$apiUrl/api/admin/get_admission_details'),
      headers: {
        'Content-Type': 'application/json',
        'supabase-url': supabaseUrl,
        'supabase-key': supabaseKey,
      },
      body: json.encode({
        'admission_id': admissionId,  // Send customer_id in the request body
      }),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);

      //print('Response data: $data');  // Debugging output

      // Check if 'members' is a list or a map
      if (data['detail'] is List) {
        // If it's already a list, return it as a List<Map<String, dynamic>>
        return List<Map<String, dynamic>>.from(data['detail']);
      } else if (data['detail'] is Map) {
        // If it's a map (single member), convert it to a list with that single map
        return [data['detail']];
      } else {
        // Return an empty list if 'members' is neither a List nor a Map
        return [];
      }
    } else {
      throw Exception('Failed to load member');
    }
  } catch (e) {
    print('Error: $e');
    return []; // Return an empty list on error
  }
}



Future<List<Map<String, dynamic>>> getUserAllRequest(int userId, String supabaseUrl, String supabaseKey) async {
  try {
    final response = await http.post(
      Uri.parse('$apiUrl/api/admin/get_admission_details'),
      headers: {
        'Content-Type': 'application/json',
        'supabase-url': supabaseUrl,
        'supabase-key': supabaseKey,
      },
      body: json.encode({
        'user_id': userId,  // Send customer_id in the request body
      }),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);

      //print('Response data: $data');  // Debugging output

      // Check if 'members' is a list or a map
      if (data['detail'] is List) {
        // If it's already a list, return it as a List<Map<String, dynamic>>
        return List<Map<String, dynamic>>.from(data['detail'].where((entry) => entry['db_admission_table'] != null),);
      } else if (data['detail'] is Map) {
        // If it's a map (single member), convert it to a list with that single map
        return [data['detail']];
      } else {
        // Return an empty list if 'members' is neither a List nor a Map
        return [];
      }
    } else {
      throw Exception('Failed to load member');
    }
  } catch (e) {
    print('Error: $e');
    return []; // Return an empty list on error
  }
}


Future<List<Map<String, dynamic>>> getFormsDetailsById(int admissionId, String supabaseUrl, String supabaseKey) async {
  try {
    final response = await http.post(
      Uri.parse('$apiUrl/api/admin/get_requirements_details'),
      headers: {
        'Content-Type': 'application/json',
        'supabase-url': supabaseUrl,
        'supabase-key': supabaseKey,
      },
      body: json.encode({
        'admission_id': admissionId,  // Send customer_id in the request body
      }),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);

      //print('Response data: $data');  // Debugging output

      // Check if 'members' is a list or a map
      if (data['detail'] is List) {
        // If it's already a list, return it as a List<Map<String, dynamic>>
        return List<Map<String, dynamic>>.from(data['detail']);
      } else if (data['detail'] is Map) {
        // If it's a map (single member), convert it to a list with that single map
        return [data['detail']];
      } else {
        // Return an empty list if 'members' is neither a List nor a Map
        return [];
      }
    } else {
      throw Exception('Failed to load member');
    }
  } catch (e) {
    print('Error: $e');
    return []; // Return an empty list on error
  }
}



}
