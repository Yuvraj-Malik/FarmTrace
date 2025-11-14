import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:sat_vet_app/controllers/vet/settings_controller.dart';

class SettingsScreen extends GetView<VetSettingsController> {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Appearance & Theme')),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          Card(
            elevation: 2,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Select Theme',
                    style: theme.textTheme.titleLarge?.copyWith(
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  // We use GetBuilder to update the checkmark
                  GetBuilder<VetSettingsController>(
                    builder: (controller) => Column(
                      children: [
                        _buildThemeOption(
                          context: context,
                          title: 'Light Mode',
                          icon: FontAwesomeIcons.sun,
                          mode: ThemeMode.light,
                          currentMode: controller.currentTheme,
                          onTap: () => controller.changeTheme(ThemeMode.light),
                        ),
                        const Divider(),
                        _buildThemeOption(
                          context: context,
                          title: 'Dark Mode',
                          icon: FontAwesomeIcons.moon,
                          mode: ThemeMode.dark,
                          currentMode: controller.currentTheme,
                          onTap: () => controller.changeTheme(ThemeMode.dark),
                        ),
                        const Divider(),
                        _buildThemeOption(
                          context: context,
                          title: 'System Default',
                          icon: FontAwesomeIcons.desktop,
                          mode: ThemeMode.system,
                          currentMode: controller.currentTheme,
                          onTap: () => controller.changeTheme(ThemeMode.system),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildThemeOption({
    required BuildContext context,
    required String title,
    required IconData icon,
    required ThemeMode mode,
    required ThemeMode currentMode,
    required VoidCallback onTap,
  }) {
    // Check if this option is the currently active one
    bool isSelected = mode == currentMode;

    // A simple way to check system theme
    if (mode == ThemeMode.system &&
        Get.isPlatformDarkMode &&
        currentMode == ThemeMode.dark) {
      isSelected = true;
    } else if (mode == ThemeMode.system &&
        !Get.isPlatformDarkMode &&
        currentMode == ThemeMode.light) {
      isSelected = true;
    }

    return ListTile(
      leading: FaIcon(icon, size: 20),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
      trailing: isSelected
          ? FaIcon(
              FontAwesomeIcons.check,
              color: Theme.of(context).colorScheme.primary,
            )
          : null,
      onTap: onTap,
    );
  }
}
