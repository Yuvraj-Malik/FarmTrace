import 'package:get/get.dart';
import 'package:sat_vet_app/models/animal_model.dart';
import 'package:sat_vet_app/models/farm_model.dart'; // We need the Farm model
import 'package:sat_vet_app/services/api_service.dart';
import 'package:sat_vet_app/routes/app_routes.dart';

class VetAnimalDetailController extends GetxController {
  final ApiService _api = Get.find<ApiService>();

  // Get arguments passed from the previous screen
  final Farm farm = Get.arguments['farm'];
  final String animalId = Get.arguments['animalId'];

  // Reactive variables
  var animal = Rx<AnimalDetail?>(null);
  var isLoading = true.obs;

  // --- NEW ---
  // For the search bar
  var searchQuery = ''.obs;
  var filteredHistory = <Treatment>[].obs;

  @override
  void onReady() {
    super.onReady();
    fetchAnimalDetails();
  }

  void fetchAnimalDetails() async {
    try {
      isLoading(true);
      animal.value = await _api.getAnimalDetails(animalId);

      // --- NEW: Populate the filtered list and set up the listener ---
      if (animal.value != null) {
        filteredHistory.assignAll(animal.value!.history);
        // This 'ever' worker automatically re-filters the list
        // whenever the searchQuery variable changes.
        ever(searchQuery, _filterHistory);
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to load animal details: ${e.toString()}');
    } finally {
      isLoading(false);
    }
  }

  // --- NEW: Search logic ---
  void onSearchChanged(String query) {
    searchQuery.value = query.toLowerCase();
  }

  void _filterHistory(String query) {
    if (animal.value == null) return;

    if (query.isEmpty) {
      filteredHistory.assignAll(animal.value!.history);
    } else {
      var filtered = animal.value!.history.where((treatment) {
        return treatment.drugName.toLowerCase().contains(query);
      }).toList();
      filteredHistory.assignAll(filtered);
    }
  }

  // --- NEW: Navigation logic for the prescribe button ---
  void goToNewPrescription() {
    // Pass the farm and animal data to the prescription screen
    Get.toNamed(
      AppRoutes.VET_NEW_PRESCRIPTION,
      arguments: {'farm': farm, 'animal': animal.value},
    );
  }
}
