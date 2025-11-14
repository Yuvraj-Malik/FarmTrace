import 'package:get/get.dart';
import 'package:sat_vet_app/models/notification_model.dart';
import 'package:sat_vet_app/services/api_service.dart';

class VetNotificationsController extends GetxController {
  final ApiService _api = Get.find<ApiService>();

  var notifications = <AppNotification>[].obs;
  var isLoading = true.obs;

  @override
  void onReady() {
    super.onReady();
    fetchNotifications();
  }

  void fetchNotifications() async {
    try {
      isLoading(true);
      notifications.assignAll(await _api.getNotifications());
    } catch (e) {
      Get.snackbar('Error', 'Failed to load notifications');
    } finally {
      isLoading(false);
    }
  }

  void markAsRead(String id) {
    // TODO: Call API to mark as read
    print('Marking $id as read');
  }

  void clearAll() {
    // TODO: Call API to clear all
    notifications.clear();
  }
}
