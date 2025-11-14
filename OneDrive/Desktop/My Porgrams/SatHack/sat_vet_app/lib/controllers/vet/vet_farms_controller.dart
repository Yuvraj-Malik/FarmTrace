import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sat_vet_app/models/farm_model.dart';
import 'package:sat_vet_app/routes/app_routes.dart';
import 'package:sat_vet_app/services/api_service.dart';

class VetFarmsController extends GetxController {
  final ApiService _api = Get.find<ApiService>();

  // --- 1. FARM FILTER & SEARCH ---
  var _linkedFarmsMaster = <Farm>[].obs;
  var _pendingRequestsMaster = <Farm>[].obs;

  var linkedFarms = <Farm>[].obs;
  var pendingRequests = <Farm>[].obs;

  var searchLinkedQuery = ''.obs;
  var searchRequestsQuery = ''.obs;
  var complianceFilter = 0.obs; // 0: All, 1: <90%, 2: >=90%

  var isLoading = true.obs;
  var selectedFarm = Rx<Farm?>(null);

  @override
  void onReady() {
    super.onReady();
    fetchAllFarms();

    debounce(
      searchLinkedQuery,
      _filterLinkedFarms,
      time: const Duration(milliseconds: 300),
    );
    debounce(
      searchRequestsQuery,
      _filterPendingRequests,
      time: const Duration(milliseconds: 300),
    );
    // Re-run the filter whenever the complianceFilter value changes
    ever(complianceFilter, (_) => _filterLinkedFarms(searchLinkedQuery.value));
  }

  void fetchAllFarms() async {
    try {
      isLoading(true);
      final results = await Future.wait([
        _api.getLinkedFarms(),
        _api.getPendingRequests(),
      ]);

      _linkedFarmsMaster.assignAll(results[0] as List<Farm>);
      _pendingRequestsMaster.assignAll(results[1] as List<Farm>);

      _filterLinkedFarms(searchLinkedQuery.value);
      _filterPendingRequests(searchRequestsQuery.value);

      if (Get.width >= 600 && linkedFarms.isNotEmpty) {
        onFarmSelected(linkedFarms.first);
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to load farm data: ${e.toString()}');
    } finally {
      isLoading(false);
    }
  }

  void setComplianceFilter(int filterIndex) {
    complianceFilter.value = filterIndex;
  }

  void _filterLinkedFarms(String query) {
    List<Farm> filtered;

    if (query.isEmpty) {
      filtered = _linkedFarmsMaster;
    } else {
      filtered = _linkedFarmsMaster
          .where(
            (farm) =>
                farm.name.toLowerCase().contains(query.toLowerCase()) ||
                farm.owner.toLowerCase().contains(query.toLowerCase()),
          )
          .toList();
    }

    if (complianceFilter.value == 1) {
      // < 90%
      filtered = filtered.where((f) => f.compliance < 90).toList();
    } else if (complianceFilter.value == 2) {
      // >= 90%
      filtered = filtered.where((f) => f.compliance >= 90).toList();
    }

    linkedFarms.assignAll(filtered);
  }

  void _filterPendingRequests(String query) {
    if (query.isEmpty) {
      pendingRequests.assignAll(_pendingRequestsMaster);
    } else {
      pendingRequests.assignAll(
        _pendingRequestsMaster.where(
          (farm) =>
              farm.name.toLowerCase().contains(query.toLowerCase()) ||
              farm.owner.toLowerCase().contains(query.toLowerCase()),
        ),
      );
    }
  }

  void onFarmSelected(Farm farm) {
    if (Get.width >= 600) {
      selectedFarm.value = farm;
    } else {
      Get.toNamed(AppRoutes.VET_FARM_DETAIL, arguments: farm);
    }
  }

  void approveFarm(String farmId) async {
    try {
      Get.snackbar('Processing...', 'Approving farm...');
      await _api.approveFarm(farmId);
      Get.snackbar('Success', 'Farm $farmId has been approved.');
      selectedFarm.value = null;
      fetchAllFarms();
    } catch (e) {
      Get.snackbar('Error', e.toString());
    }
  }

  void denyFarm(String farmId) async {
    try {
      Get.snackbar('Processing...', 'Denying farm...');
      await _api.denyFarm(farmId);
      Get.snackbar('Success', 'Farm $farmId has been denied.');
      selectedFarm.value = null;
      fetchAllFarms();
    } catch (e) {
      Get.snackbar('Error', e.toString());
    }
  }

  // --- THIS IS THE FIX: ADD THE MISSING METHOD ---
  void goToAnimalDetails(Farm farm, String animalId) {
    Get.toNamed(
      AppRoutes.VET_ANIMAL_DETAIL,
      arguments: {'farm': farm, 'animalId': animalId},
    );
  }
}
