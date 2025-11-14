import 'package:get/get.dart';
import 'package:sat_vet_app/controllers/vet/vet_animal_detail_controller.dart';

class VetAnimalDetailBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<VetAnimalDetailController>(() => VetAnimalDetailController());
  }
}
