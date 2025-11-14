import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sat_vet_app/bindings/vet/app_binding.dart';
import 'package:sat_vet_app/routes/app_pages.dart';

void main() {
  runApp(const VetApp());
}

class VetApp extends StatelessWidget {
  const VetApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // --- 1. Define Your Vet Theme Colors ---
    final Color vetPrimaryColor = Colors.cyan.shade800;
    final Color vetPrimaryDarkColor = Colors.cyan.shade300;

    // --- 2. Define Your Light Theme (Off-White) ---
    final ThemeData lightTheme = ThemeData(
      brightness: Brightness.light,
      primarySwatch: Colors.cyan,
      primaryColor: vetPrimaryColor,
      scaffoldBackgroundColor: const Color(0xFFF8F9FA), // Off-white
      cardColor: Colors.white,
      appBarTheme: AppBarTheme(
        backgroundColor: vetPrimaryColor,
        elevation: 1,
        titleTextStyle: const TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: vetPrimaryColor,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
        ),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        selectedItemColor: vetPrimaryColor,
        unselectedItemColor: Colors.grey.shade600,
      ),
      dividerTheme: DividerThemeData(color: Colors.grey.shade300, space: 1),
    );

    // --- 3. Define Your Dark Theme (Complementary) ---
    final ThemeData darkTheme = ThemeData(
      brightness: Brightness.dark,
      primarySwatch: Colors.cyan,
      primaryColor: vetPrimaryDarkColor, // Lighter cyan for dark
      scaffoldBackgroundColor: const Color(0xFF121212), // True dark
      cardColor: const Color(0xFF1E1E1E), // Lighter dark for cards
      appBarTheme: AppBarTheme(
        backgroundColor: const Color(0xFF1E1E1E),
        elevation: 1,
        titleTextStyle: const TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: vetPrimaryDarkColor, // Lighter cyan
          foregroundColor: Colors.black, // Dark text on light button
          padding: const EdgeInsets.symmetric(vertical: 16),
        ),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        selectedItemColor: vetPrimaryDarkColor,
        unselectedItemColor: Colors.grey.shade400,
        backgroundColor: const Color(0xFF1E1E1E),
      ),
      dividerTheme: DividerThemeData(color: Colors.grey.shade800, space: 1),
    );

    // --- 4. Use GetMaterialApp ---
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Vet Platform',
      theme: lightTheme,
      darkTheme: darkTheme,
      themeMode: ThemeMode.system,

      // --- GetX Routing ---
      // This tells GetX to use your routes file
      initialRoute: AppPages.INITIAL,
      getPages: AppPages.routes,
      initialBinding: AppBinding(),
    );
  }
}
