import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:sat_vet_app/controllers/vet/vet_profile_controller.dart';
// We no longer need to import the screens directly

class VetDrawer extends StatelessWidget {
  const VetDrawer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    // Find the profile controller to get user info and methods
    // We use Get.find() because the controller is already loaded
    // by the VetHomeBinding
    final VetProfileController controller = Get.find<VetProfileController>();

    return Drawer(
      child: Column(
        children: [
          // Obx will update the header if the user's name changes
          Obx(
            () => UserAccountsDrawerHeader(
              accountName: Text(
                controller.vetUser['name']!,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              accountEmail: Text(controller.vetUser['email']!),
              currentAccountPicture: CircleAvatar(
                backgroundColor: Colors.white,
                child: Text(
                  controller.vetUser['name']![0], // First initial
                  style: TextStyle(fontSize: 40.0, color: theme.primaryColor),
                ),
              ),
              decoration: BoxDecoration(color: theme.primaryColor),
            ),
          ),
          ListTile(
            leading: const FaIcon(FontAwesomeIcons.palette),
            title: const Text('Appearance & Theme'),
            onTap: () {
              Get.back(); // Close the drawer
              controller.goToSettings(); // --- USE CONTROLLER METHOD ---
            },
          ),
          ListTile(
            leading: const FaIcon(FontAwesomeIcons.circleQuestion),
            title: const Text('Help & Support'),
            onTap: () {
              Get.back(); // Close the drawer
              controller.goToHelp(); // --- USE CONTROLLER METHOD ---
            },
          ),
          const Spacer(), // Pushes the logout button to the bottom
          const Divider(),
          ListTile(
            leading: FaIcon(
              FontAwesomeIcons.signOutAlt,
              color: theme.colorScheme.error,
            ),
            title: Text(
              'Logout',
              style: TextStyle(color: theme.colorScheme.error),
            ),
            onTap: () {
              Get.back(); // Close the drawer
              controller.logout(); // --- USE CONTROLLER METHOD ---
            },
          ),
        ],
      ),
    );
  }
}
