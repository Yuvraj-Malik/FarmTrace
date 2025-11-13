// lib/main.dart (Complete Final Version)

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'bindings/app_bindings.dart';
import 'controllers/farmer/auth_controller.dart';
import 'screens/farmer/main_wrapper_view.dart';
import 'screens/farmer/login_view.dart'; // 🔑 Import Login
// import 'screens/cattle_detail_screen.dart';

void main() {
  AppBindings().dependencies();
  runApp(const CattleMarketplaceApp());
}

class CattleMarketplaceApp extends StatelessWidget {
  const CattleMarketplaceApp({super.key});

  @override
  Widget build(BuildContext context) {
    // 🔑 Find the AuthController, initialized via Bindings
    final authController = Get.find<AuthController>();

    return GetMaterialApp(
      title: 'Cattle Marketplace',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.green, useMaterial3: true),
      
      // 🔑 The Initial Route is determined by the Auth State
      home: Obx(() {
        // If still loading state (e.g., checking token)
        if (authController.isLoading.isTrue) {
          return const Center(child: CircularProgressIndicator());
        }
        
        // If authenticated, show the Main App
        if (authController.isAuthenticated.isTrue) {
          return const MainWrapperView();
        } else {
          // If not authenticated, show the Login screen
          return const LoginView();
        }
      }),
      
      // 🔑 Define all main screen routes for named navigation
      getPages: [
        // 🔑 Authentication Routes (For navigation during sign up/login)
        GetPage(name: '/login', page: () => const LoginView()),
        GetPage(name: '/signup', page: () => const SignupView()),
        
        // 🔑 Main Application Route (Target for post-login redirection)
        GetPage(name: '/main', page: () => const MainWrapperView()), 
        
        // Detail screen is still a separate route
        // GetPage(name: '/detail', page: () => CattleDetailScreen(cattle: Get.arguments)), 
      ],
    );
  }
}

// 🔑 Placeholder for Signup (create this file: lib/screens/signup_view.dart)
class SignupView extends StatelessWidget {
  const SignupView({super.key});
  @override
  Widget build(BuildContext context) {
    final controller = Get.find<AuthController>();
    return Scaffold(
      appBar: AppBar(title: const Text('Sign Up')),
      body: Center(
        child: Obx(() => ElevatedButton(
          onPressed: controller.isLoading.value ? null : controller.signUp,
          child: Text(controller.isLoading.value ? 'Signing Up...' : 'Create Account'),
        )),
      ),
    );
  }
}