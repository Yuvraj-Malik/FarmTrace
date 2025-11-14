import 'package:get/get.dart';
import 'package:sat_vet_app/controllers/vet/vet_notifications_controller.dart';

class VetNotificationsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<VetNotificationsController>(() => VetNotificationsController());
  }
}
