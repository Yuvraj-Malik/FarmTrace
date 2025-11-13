// lib/controllers/app_nav_controller.dart

import 'package:get/get.dart';

class AppNavController extends GetxController {
  // 🔑 0.obs is Dashboard, 1.obs is Marketplace, 2.obs is Profile, 3.obs is LiveStock
  var currentIndex = 0.obs; 

  void changePage(int index) {
    currentIndex.value = index;
  }
}