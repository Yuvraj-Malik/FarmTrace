import 'package:get/get.dart';
import 'package:sat_vet_app/bindings/vet/vet_animal_detail_binding.dart';
import 'package:sat_vet_app/bindings/vet/vet_home_binding.dart';
import 'package:sat_vet_app/bindings/vet/vet_new_prescription_binding.dart';
import 'package:sat_vet_app/bindings/vet/vet_notifications_binding.dart';
import 'package:sat_vet_app/bindings/vet/vet_settings_binding.dart';
import 'package:sat_vet_app/bindings/vet/vet_farm_detail_binding.dart'; // <-- 1. IMPORT
import 'package:sat_vet_app/models/farm_model.dart';
import 'package:sat_vet_app/routes/app_routes.dart';
import 'package:sat_vet_app/screens/vet/new_prescription_screen.dart';
import 'package:sat_vet_app/screens/vet/vet_animal_detail_screen.dart';
import 'package:sat_vet_app/screens/vet/vet_farm_detail_screen.dart';
import 'package:sat_vet_app/screens/vet/vet_home_screen.dart';
import 'package:sat_vet_app/screens/vet/settings_screen.dart';
import 'package:sat_vet_app/screens/vet/help_screen.dart';
import 'package:sat_vet_app/screens/vet/vet_notifications_screen.dart';

class AppPages {
  static const INITIAL = AppRoutes.VET_HOME;

  static final routes = [
    // ... (VET_HOME, VET_NEW_PRESCRIPTION are unchanged) ...
    GetPage(
      name: AppRoutes.VET_HOME,
      page: () => const VetHomeScreen(),
      binding: VetHomeBinding(),
    ),
    GetPage(
      name: AppRoutes.VET_NEW_PRESCRIPTION,
      page: () => const NewPrescriptionScreen(),
      binding: VetNewPrescriptionBinding(),
      fullscreenDialog: true,
    ),

    // --- 2. THIS IS THE FIX ---
    GetPage(
      name: AppRoutes.VET_FARM_DETAIL,
      page: () =>
          const VetFarmDetailScreen(), // The screen no longer takes arguments
      binding:
          VetFarmDetailBinding(), // It will get its args via the controller
    ),

    // --- END OF FIX ---
    GetPage(
      name: AppRoutes.VET_ANIMAL_DETAIL,
      page: () => const VetAnimalDetailScreen(),
      binding: VetAnimalDetailBinding(),
    ),
    GetPage(
      name: AppRoutes.VET_SETTINGS,
      page: () => const SettingsScreen(),
      binding: VetSettingsBinding(),
    ),
    GetPage(name: AppRoutes.VET_HELP, page: () => const HelpScreen()),
    GetPage(
      name: AppRoutes.VET_NOTIFICATIONS,
      page: () => const VetNotificationsScreen(),
      binding: VetNotificationsBinding(),
    ),
  ];
}
