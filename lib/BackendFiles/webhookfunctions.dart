import 'dart:convert';

import 'package:http/http.dart' as http;

class Webhookfunctions {
  Future<void> sendPostRequest(
    Map<String, dynamic> requestBody,
    String link,
  ) async {
    try {
      // Encode the request body as JSON
      final body = jsonEncode(requestBody);

      // Make the POST request
      final response = await http.post(
        Uri.parse(link),
        headers: {'Content-Type': 'application/json'},
        body: body,
      );

      // Handle the response
      if (response.statusCode == 200 || response.statusCode == 201) {
        print('Response data: ${response.body}');
      } else {
        print('Failed to send request. Status code: ${response.statusCode}');
        print('Response body: ${response.body}');
      }
    } catch (error) {
      print('Error: $error');
    }
  }
}
