import 'package:get/get.dart';
import 'package:sat_vet_app/models/farm_model.dart';
import 'package:sat_vet_app/routes/app_routes.dart';
import 'package:sat_vet_app/services/api_service.dart';
import 'package:sat_vet_app/controllers/vet/vet_home_controller.dart';

class VetDashboardController extends GetxController {
  final ApiService _api = Get.find<ApiService>();

  var pendingRequests = <Farm>[].obs;
  var linkedFarms = <Farm>[].obs;
  var isLoading = true.obs;

  @override
  void onReady() {
    super.onReady();
    fetchDashboardData();
  }

  void fetchDashboardData() async {
    try {
      isLoading(true);
      final results = await Future.wait([
        _api.getPendingRequests(),
        _api.getLinkedFarms(),
      ]);
      pendingRequests.assignAll(results[0] as List<Farm>);
      linkedFarms.assignAll(results[1] as List<Farm>);
    } catch (e) {
      Get.snackbar('Error', 'Failed to load dashboard data: ${e.toString()}');
    } finally {
      isLoading(false);
    }
  }

  // --- ACTIONS ---

  void goToNewPrescription() {
    Get.toNamed(AppRoutes.VET_NEW_PRESCRIPTION);
  }

  void approveFarm(String farmId) async {
    try {
      Get.snackbar('Processing...', 'Approving farm...');
      bool success = await _api.approveFarm(farmId);

      if (success) {
        Get.snackbar('Success', 'Farm $farmId has been approved.');
        fetchDashboardData();
      } else {
        Get.snackbar('Error', 'Failed to approve farm.');
      }
    } catch (e) {
      Get.snackbar('Error', e.toString());
    }
  }

  // --- THIS IS THE FIX ---
  void denyFarm(String farmId) async {
    try {
      Get.snackbar('Processing...', 'Denying farm...');

      // 1. Call the API
      bool success = await _api.denyFarm(farmId);

      if (success) {
        // 2. Show success message
        Get.snackbar('Success', 'Farm $farmId has been denied.');
        // 3. Refresh ALL dashboard data to update the lists
        fetchDashboardData();
      } else {
        Get.snackbar('Error', 'Failed to deny farm.');
      }
    } catch (e) {
      Get.snackbar('Error', e.toString());
    }
  }
  // --- END OF FIX ---

  void goToFarmDetails(Farm farm) {
    Get.toNamed(AppRoutes.VET_FARM_DETAIL, arguments: farm);
  }

  void reviewAllRequests() {
    final homeController = Get.find<VetHomeController>();
    homeController.onItemTapped(1);
    homeController.tabController.animateTo(1);
  }
}
