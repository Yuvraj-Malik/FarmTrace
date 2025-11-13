// lib/services/auth_api_service.dart

import 'package:get/get.dart';
// import 'dart:convert';
// import 'package:http/http.dart' as http;

class AuthApiService extends GetxService {

  // final String _baseUrl = 'https://your-hackathon-api.com/auth/v1';
  
  // 🔑 API KEY/TOKEN PLACEHOLDER
  // In a real app, this is often retrieved from secure storage after login.
  // final String _apiToken = 'YOUR_SECURE_AUTH_TOKEN_PLACEHOLDER'; 

  /// Future method to handle Login API call
  Future<Map<String, dynamic>> login({required String phone, required String password}) async {
    // ----------------------------------------------------
    // MOCK DATA FALLBACK (1.5 second delay)
    // ----------------------------------------------------
    await Future.delayed(const Duration(milliseconds: 1500));
    return {
      'token': 'mock_jwt_token',
      'user_id': 101,
      'role': 'farmer', // In a real app, the server returns the role
    };

    // ----------------------------------------------------
    // 🔑 Future Real API Implementation Snippet
    // ----------------------------------------------------
    /*
    final response = await http.post(
        Uri.parse('$_baseUrl/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'phone': phone, 'password': password})
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body) as Map<String, dynamic>;
    } else {
      throw Exception('Server rejected login attempt.');
    }
    */
  }

  /// Future method to handle Signup API call
  Future<void> signup(Map<String, dynamic> userData) async {
    await Future.delayed(const Duration(seconds: 1));
    // Implementation for signup
  }
}