// lib/controllers/auth_controller.dart (Updated)

import 'package:get/get.dart';
import '../../services/farmer/auth_api_service.dart'; // 🔑 New Service Import

class AuthController extends GetxController {
  // 🔑 Dependency Injection for the new API service
  // final AuthApiService _apiService = Get.find<AuthApiService>();

  // --- REACTIVE STATE ---
  var isAuthenticated = false.obs; 
  var phone = ''.obs; // 🔑 Changed from email
  var password = ''.obs;
  var isLoading = false.obs;
  
  // Placeholder for user details (role is critical for navigation)
  var userName = 'Ramesh Kumar'.obs; 
  var userRole = ''.obs; // To store the role received from the API

  @override
  void onInit() {
    super.onInit();
    checkLoginStatus();
  }

  void checkLoginStatus() async {
    // Check local token/status
    await Future.delayed(const Duration(milliseconds: 500)); 
    isAuthenticated.value = false;
  }

  // 🔑 LOGIN METHOD with Role parameter
  Future<void> login({required String role}) async {
    isLoading.value = true;
    
    // 1. Call API Service
    try {
      // In the future, you'll call a service method like:
      // final response = await _apiService.login(phone: phone.value, password: password.value);
      
      // MOCK LOGIC for role-based testing
      await Future.delayed(const Duration(seconds: 2));
      
      if (phone.value == '9056103026' && password.value == '12345') {
        isAuthenticated.value = true;
        userRole.value = role; // Store the selected role
        
        // 2. Role-based Navigation using GetX
        if (role == 'veteran') {
          // Navigate to the Veteran/Admin entry point
          Get.offAllNamed('/admin_main'); 
        } else { // Farmer role
          // Navigate to the main Farmer app entry point
          Get.offAllNamed('/main'); 
        }
      } else {
        Get.snackbar('Login Failed', 'Invalid credentials or role mismatch.', snackPosition: SnackPosition.BOTTOM);
      }
    } catch (e) {
      Get.snackbar('Error', 'Network or server error during login.', snackPosition: SnackPosition.BOTTOM);
    }
    
    isLoading.value = false;
  }

  // 🔑 SIGN UP METHOD (simplified)
  Future<void> signUp() async {
    isLoading.value = true;
    // Call signup service here...
    await Future.delayed(const Duration(seconds: 2));

    isAuthenticated.value = true;
    Get.offAllNamed('/main'); 

    isLoading.value = false;
  }
  
  void logout() {
    isAuthenticated.value = false;
    Get.offAllNamed('/login');
  }
}