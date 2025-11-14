import 'package:get/get.dart';
import 'package:sat_vet_app/controllers/vet/vet_dashboard_controller.dart';
import 'package:sat_vet_app/controllers/vet/vet_farms_controller.dart';
import 'package:sat_vet_app/controllers/vet/vet_home_controller.dart';
import 'package:sat_vet_app/controllers/vet/vet_profile_controller.dart';

class VetHomeBinding extends Bindings {
  @override
  void dependencies() {
    // This binding loads all controllers for the 3 main tabs
    Get.lazyPut<VetHomeController>(() => VetHomeController());
    Get.lazyPut<VetDashboardController>(() => VetDashboardController());
    Get.lazyPut<VetFarmsController>(() => VetFarmsController());
    Get.lazyPut<VetProfileController>(() => VetProfileController());
  }
}
