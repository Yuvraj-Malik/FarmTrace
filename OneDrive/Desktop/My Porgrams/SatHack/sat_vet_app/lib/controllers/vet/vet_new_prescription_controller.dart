import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sat_vet_app/models/animal_model.dart'; // Import Animal model
import 'package:sat_vet_app/models/farm_model.dart';
import 'package:sat_vet_app/services/api_service.dart';

class NewPrescriptionController extends GetxController {
  final ApiService _api = Get.find<ApiService>();

  // --- MOCK DATA ---
  // In a real app, you'd fetch these from the API
  final List<Map<String, String>> _animals = [
    {'id': 'a1', 'tag': '#102-B (Holstein)'},
    {'id': 'a2', 'tag': '#105-A (Sahiwal)'},
    {'id': 'a3', 'tag': 'Flock-B (Poultry)'},
  ];

  final List<Map<String, dynamic>> _drugs = [
    {'id': 'd1', 'name': 'Penicillin', 'withdrawal': 12},
    {'id': 'd2', 'name': 'Ivermectin', 'withdrawal': 7},
    {'id': 'd3', 'name': 'Ampicillin', 'withdrawal': 10},
  ];
  // --- END MOCK DATA ---

  // Reactive variables to hold form state
  var linkedFarms = <Farm>[].obs;
  var animals = <Map<String, String>>[].obs;
  var drugs = <Map<String, dynamic>>[].obs;
  var isLoading = true.obs;

  // Form selection state
  var selectedFarm = Rx<Farm?>(null);
  var selectedAnimal = Rx<Map<String, String>?>(null);
  var selectedDrug = Rx<Map<String, dynamic>?>(null);
  var treatmentDate = Rx<DateTime?>(null);
  var dosage = ''.obs;

  // Computed value: automatically calculates withdrawal date
  String? get withdrawalDate {
    if (treatmentDate.value == null || selectedDrug.value == null) {
      return null;
    }
    final withdrawalDays = selectedDrug.value!['withdrawal'] as int;
    final safeDate = treatmentDate.value!.add(Duration(days: withdrawalDays));
    return "${safeDate.year}-${safeDate.month.toString().padLeft(2, '0')}-${safeDate.day.toString().padLeft(2, '0')}";
  }

  @override
  void onReady() {
    super.onReady();
    // We make this async to handle pre-filling
    _fetchAndPreloadData();
  }

  // Fetches the data needed for the dropdowns
  Future<void> _fetchAndPreloadData() async {
    try {
      isLoading(true);
      // Fetch data from API
      linkedFarms.assignAll(await _api.getLinkedFarms());
      // In a real app, you'd fetch animals and drugs from the API too
      animals.assignAll(_animals);
      drugs.assignAll(_drugs);

      // --- THIS IS THE FIX ---
      // Check if arguments were passed from the animal detail screen
      if (Get.arguments != null && Get.arguments is Map) {
        final Map<String, dynamic> args = Get.arguments;

        if (args.containsKey('farm') && args.containsKey('animal')) {
          final prefilledFarm = args['farm'] as Farm;
          final prefilledAnimal = args['animal'] as AnimalDetail;

          // Find the matching objects in our dropdown lists
          selectedFarm.value = linkedFarms.firstWhereOrNull(
            (f) => f.id == prefilledFarm.id,
          );

          // Note: This logic assumes _animals list is already loaded
          // In a real app, you might need to fetch animals for this farm ID first
          selectedAnimal.value = animals.firstWhereOrNull(
            (a) => a['id'] == prefilledAnimal.id,
          );
        }
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to load data: ${e.toString()}');
    } finally {
      isLoading(false);
    }
  }

  // --- ACTIONS ---

  void onFarmSelected(Farm? farm) {
    selectedFarm.value = farm;
    selectedAnimal.value = null; // Reset animal when farm changes
    // In a real app, you would now fetch the animals for this farm
    // e.g., animals.assignAll(await _api.getAnimalsForFarm(farm.id));
  }

  void onAnimalSelected(Map<String, String>? animal) {
    selectedAnimal.value = animal;
  }

  void onDrugSelected(Map<String, dynamic>? drug) {
    selectedDrug.value = drug;
  }

  void onDosageChanged(String value) {
    dosage.value = value;
  }

  void onDateSelected(DateTime? date) {
    treatmentDate.value = date;
  }

  void submitPrescription() {
    // TODO: Add form validation here
    if (selectedFarm.value == null ||
        selectedAnimal.value == null ||
        selectedDrug.value == null ||
        dosage.isEmpty) {
      Get.snackbar('Error', 'Please fill all fields');
      return;
    }

    // Call the API
    _api.createPrescription(
      selectedAnimal.value!['id']!,
      selectedDrug.value!['id']!,
      dosage.value,
    );

    // Show success and go back
    Get.snackbar('Success', 'Prescription submitted successfully');
    Get.back();
  }
}
