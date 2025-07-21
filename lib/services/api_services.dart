import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class ApiService {
  final String baseUrl = dotenv.env['BASE_URL']!;
  final String tokenSecret = dotenv.env['TOKEN_SECRET']!;

  Future<bool> enviarTokenFCM(String token) async {
    try {
      final url = Uri.parse('$baseUrl/api/notificar');

      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $tokenSecret',
        },
        body: jsonEncode({'token': token}),
      );

      if (response.statusCode == 200) {
        return true;
      } else {
        print('Error en servidor: ${response.statusCode} - ${response.body}');
        return false;
      }
    } catch (e) {
      print('Error enviando token FCM: $e');
      return false;
    }
  }
}
