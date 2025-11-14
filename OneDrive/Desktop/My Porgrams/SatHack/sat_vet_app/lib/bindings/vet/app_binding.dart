import 'package:get/get.dart';
import 'package:sat_vet_app/services/api_service.dart';

class AppBinding extends Bindings {
  @override
  void dependencies() {
    // Inject ApiService as a permanent service
    // fenix: true means it will live for the entire app lifecycle
    Get.lazyPut<ApiService>(() => ApiService(), fenix: true);
  }
}
