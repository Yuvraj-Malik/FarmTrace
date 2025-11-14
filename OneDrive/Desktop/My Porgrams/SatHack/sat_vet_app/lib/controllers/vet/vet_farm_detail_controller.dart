import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sat_vet_app/models/animal_model.dart';
import 'package:sat_vet_app/models/farm_model.dart';
import 'package:sat_vet_app/services/api_service.dart';
import 'package:sat_vet_app/routes/app_routes.dart';

class VetFarmDetailController extends GetxController {
  final ApiService _api = Get.find<ApiService>();

  // Get the farm passed from the previous screen
  final Farm farm = Get.arguments as Farm;

  // --- 1. THIS IS THE FIX ---
  // The master list is now populated from the API
  var _animalsMaster = <AnimalDetail>[].obs;
  var filteredAnimals = <AnimalDetail>[].obs;
  var animalSearchQuery = ''.obs;
  var isLoading = true.obs;
  // --- END OF FIX ---

  @override
  void onReady() {
    super.onReady();
    // --- 2. FETCH ANIMALS WHEN THE SCREEN IS READY ---
    fetchAnimalsForFarm();
  }

  void fetchAnimalsForFarm() async {
    try {
      isLoading(true);
      // Call the new API method
      final animals = await _api.getAnimalsForFarm(farm.id);
      _animalsMaster.assignAll(animals);
      filteredAnimals.assignAll(animals);

      // Set up the listener for the search query
      debounce(
        animalSearchQuery,
        _filterAnimals,
        time: const Duration(milliseconds: 300),
      );
    } catch (e) {
      Get.snackbar('Error', 'Failed to load animals: ${e.toString()}');
    } finally {
      isLoading(false);
    }
  }
  // --- END OF FIX ---

  void _filterAnimals(String query) {
    if (query.isEmpty) {
      filteredAnimals.assignAll(_animalsMaster);
    } else {
      filteredAnimals.assignAll(
        _animalsMaster.where(
          (animal) => animal.tag.toLowerCase().contains(query.toLowerCase()),
        ),
      );
    }
  }

  void goToAnimalDetails(String animalId) {
    Get.toNamed(
      AppRoutes.VET_ANIMAL_DETAIL,
      arguments: {'farm': farm, 'animalId': animalId},
    );
  }

  // Logic for the approve/deny buttons on this mobile screen
  void approveFarm() async {
    // TODO: Call API
    Get.snackbar('Success', 'Farm approved');
    Get.back(); // Go back to the farms list
  }

  void denyFarm() async {
    // TODO: Call API
    Get.snackbar('Success', 'Farm denied');
    Get.back(); // Go back to the farms list
  }
}
