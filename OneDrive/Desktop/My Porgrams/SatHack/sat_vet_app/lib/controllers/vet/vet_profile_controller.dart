import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sat_vet_app/routes/app_routes.dart';

class VetProfileController extends GetxController {
  // State for editing
  var isEditing = false.obs;

  // Form controllers
  late TextEditingController nameController;
  late TextEditingController emailController;
  late TextEditingController clinicController;

  // Mock user data. In a real app, you'd fetch this from ApiService
  final vetUser = {
    'name': 'Dr. Priya Sharma',
    'email': 'priya@vet.com',
    'clinic': 'Sharma Vet Clinic',
    'regNo': 'VCI-12345',
  }.obs;

  @override
  void onInit() {
    super.onInit();
    // Initialize text controllers with current data
    nameController = TextEditingController(text: vetUser['name']);
    emailController = TextEditingController(text: vetUser['email']);
    clinicController = TextEditingController(text: vetUser['clinic']);
  }

  @override
  void onClose() {
    // Dispose controllers to prevent memory leaks
    nameController.dispose();
    emailController.dispose();
    clinicController.dispose();
    super.onClose();
  }

  void toggleEditMode() {
    isEditing.value = !isEditing.value;
    // If we're cancelling, reset text fields to original values
    if (!isEditing.value) {
      nameController.text = vetUser['name']!;
      emailController.text = vetUser['email']!;
      clinicController.text = vetUser['clinic']!;
    }
  }

  void saveProfileChanges() {
    // --- 1. Call API ---
    // TODO: Call ApiService to save data
    // await _api.updateProfile(
    //   name: nameController.text,
    //   email: emailController.text,
    //   clinic: clinicController.text,
    // );

    // --- 2. Update Local State ---
    vetUser['name'] = nameController.text;
    vetUser['email'] = emailController.text;
    vetUser['clinic'] = clinicController.text;

    // --- 3. Exit Edit Mode ---
    isEditing.value = false;
    Get.snackbar('Success', 'Profile updated successfully');
  }

  void goToSettings() {
    Get.toNamed(AppRoutes.VET_SETTINGS);
  }

  void goToHelp() {
    Get.toNamed(AppRoutes.VET_HELP);
  }

  void logout() {
    Get.dialog(
      AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(child: const Text('Cancel'), onPressed: () => Get.back()),
          TextButton(
            child: const Text('Logout'),
            onPressed: () {
              // TODO: Add actual logout logic (clear token)
              Get.back(); // Close dialog
              // Get.offAllNamed(AppRoutes.LOGIN); // Navigate to login
            },
          ),
        ],
      ),
    );
  }
}
