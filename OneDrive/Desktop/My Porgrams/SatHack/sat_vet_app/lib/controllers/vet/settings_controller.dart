import 'package:flutter/material.dart';
import 'package:get/get.dart';

class VetSettingsController extends GetxController {
  // GetX can tell us the current theme mode
  ThemeMode get currentTheme {
    return Get.theme.brightness == Brightness.dark
        ? ThemeMode.dark
        : ThemeMode.light;
    // Note: This is a simplified check. We'd use GetStorage
    // to perfectly save and retrieve the 'system' choice.
  }

  void changeTheme(ThemeMode mode) {
    // This is the GetX magic to change the theme
    Get.changeThemeMode(mode);
  }
}
