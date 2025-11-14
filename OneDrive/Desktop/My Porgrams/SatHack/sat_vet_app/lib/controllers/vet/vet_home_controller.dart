import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sat_vet_app/screens/vet/vet_dashboard_screen.dart';
import 'package:sat_vet_app/screens/vet/vet_farms_screen.dart';
import 'package:sat_vet_app/screens/vet/vet_profile_screen.dart';

class VetHomeController extends GetxController
    with GetSingleTickerProviderStateMixin {
  var selectedIndex = 0.obs;
  late TabController tabController;

  // --- 1. FIX: Make the list non-final and empty ---
  late List<Widget> pages;

  @override
  void onInit() {
    super.onInit();
    tabController = TabController(length: 2, vsync: this);

    // --- 2. FIX: Initialize the pages list HERE ---
    // Now, tabController exists and can be found by VetFarmsScreen
    pages = [
      const VetDashboardScreen(),
      const VetFarmsScreen(), // This will now work
      const VetProfileScreen(),
    ];
  }

  @override
  void onClose() {
    tabController.dispose();
    super.onClose();
  }

  void onItemTapped(int index) {
    selectedIndex.value = index;
  }
}
