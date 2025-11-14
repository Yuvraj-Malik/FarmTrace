import 'package:get/get.dart';
import 'package:sat_vet_app/controllers/vet/vet_farm_detail_controller.dart';

class VetFarmDetailBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<VetFarmDetailController>(() => VetFarmDetailController());
  }
}
