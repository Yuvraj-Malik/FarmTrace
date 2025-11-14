import 'package:get/get.dart';
import 'package:sat_vet_app/controllers/vet/vet_new_prescription_controller.dart';

class VetNewPrescriptionBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<NewPrescriptionController>(() => NewPrescriptionController());
  }
}
