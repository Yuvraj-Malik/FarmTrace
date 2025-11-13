// lib/screens/main_wrapper_view.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/farmer/app_nav_controller.dart';
// Import your other screens (placeholders for now)
import 'placeholder_screen.dart'; 

class MainWrapperView extends StatelessWidget {
  const MainWrapperView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<AppNavController>();

    // 🔑 Screens mapped to Bottom Nav Indices
    final List<Widget> screens = [
      const PlaceholderScreen(title: 'DashBoard'),   // Index 0
      const PlaceholderScreen(title: 'MarketPlace'),   // Index 1
      const PlaceholderScreen(title: 'Camera'),   // Index 2
      const PlaceholderScreen(title: 'Veterns'),      // Index 3
      const PlaceholderScreen(title: 'Profile'),      // Index 3
    ];
  
    return Scaffold(
      body: Obx(() => screens[controller.currentIndex.value]),
      bottomNavigationBar: Obx(
        () => BottomNavigationBar(
          currentIndex: controller.currentIndex.value,
          onTap: controller.changePage,
          selectedItemColor: Colors.green,
          unselectedItemColor: Colors.grey,
          type: BottomNavigationBarType.fixed,
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
            BottomNavigationBarItem(icon: Icon(Icons.store), label: 'Marketplace'), // Index 1
            BottomNavigationBarItem(icon: Icon(Icons.pets), label: 'Livestock'),
            BottomNavigationBarItem(icon: Icon(Icons.camera_enhance), label: 'camera'),
            BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),

          ],
        ),
      ),
    );
  }
}