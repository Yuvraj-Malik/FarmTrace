import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:sat_vet_app/controllers/vet/vet_notifications_controller.dart';
import 'package:sat_vet_app/models/notification_model.dart';

class VetNotificationsScreen extends GetView<VetNotificationsController> {
  const VetNotificationsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        actions: [
          IconButton(
            icon: const FaIcon(FontAwesomeIcons.broom, size: 18),
            onPressed: controller.clearAll,
            tooltip: 'Clear All',
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.isTrue) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.notifications.isEmpty) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                FaIcon(
                  FontAwesomeIcons.bellSlash,
                  size: 40,
                  color: Colors.grey,
                ),
                SizedBox(height: 16),
                Text('You have no new notifications.'),
              ],
            ),
          );
        }

        return ListView.builder(
          itemCount: controller.notifications.length,
          itemBuilder: (context, index) {
            final notification = controller.notifications[index];
            return Card(
              margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              elevation: 1,
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: notification.iconColor.withOpacity(0.1),
                  child: FaIcon(
                    notification.icon,
                    color: notification.iconColor,
                    size: 18,
                  ),
                ),
                title: Text(
                  notification.title,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text(notification.body),
                trailing: Text(
                  // A simple time-ago formatter
                  '${DateTime.now().difference(notification.timestamp).inHours}h ago',
                  style: theme.textTheme.bodySmall,
                ),
                onTap: () => controller.markAsRead(notification.id),
              ),
            );
          },
        );
      }),
    );
  }
}
