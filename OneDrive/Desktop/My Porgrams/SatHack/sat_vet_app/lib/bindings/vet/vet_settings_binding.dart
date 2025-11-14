import 'package:get/get.dart';
import 'package:sat_vet_app/controllers/vet/settings_controller.dart';

class VetSettingsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<VetSettingsController>(() => VetSettingsController());
  }
}
