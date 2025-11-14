import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:sat_vet_app/controllers/vet/vet_profile_controller.dart';

class VetProfileScreen extends GetView<VetProfileController> {
  const VetProfileScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ListView(
      padding: const EdgeInsets.all(16.0),
      children: [
        Card(
          elevation: 2,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            // --- 1. Wrap content in Obx to listen for isEditing ---
            child: Obx(
              () => Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Professional Details',
                        style: theme.textTheme.titleLarge?.copyWith(
                          color: theme.colorScheme.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      // --- 2. Edit/Cancel Button ---
                      TextButton(
                        onPressed: controller.toggleEditMode,
                        child: Text(
                          controller.isEditing.isTrue ? 'Cancel' : 'Edit',
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // --- 3. Editable/Static Fields ---
                  controller.isEditing.isTrue
                      ? _buildEditMode(context) // Show text fields
                      : _buildViewMode(context), // Show static text
                  // --- 4. Show Save Button only in Edit Mode ---
                  if (controller.isEditing.isTrue) ...[
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: controller.saveProfileChanges,
                      child: const Text('Save Changes'),
                      style: theme.elevatedButtonTheme.style?.copyWith(
                        minimumSize: MaterialStateProperty.all(
                          const Size(double.infinity, 48), // Full width
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  // --- NEW: View-only widget ---
  Widget _buildViewMode(BuildContext context) {
    return Column(
      children: [
        _buildProfileTile(
          context,
          icon: FontAwesomeIcons.userDoctor,
          title: 'Name',
          subtitle: controller.vetUser['name']!,
        ),
        const Divider(),
        _buildProfileTile(
          context,
          icon: FontAwesomeIcons.solidEnvelope,
          title: 'Email',
          subtitle: controller.vetUser['email']!,
        ),
        const Divider(),
        _buildProfileTile(
          context,
          icon: FontAwesomeIcons.clinicMedical,
          title: 'Clinic',
          subtitle: controller.vetUser['clinic']!,
        ),
        const Divider(),
        _buildProfileTile(
          context,
          icon: FontAwesomeIcons.idBadge,
          title: 'License ID',
          subtitle: controller.vetUser['regNo']!,
          isReadOnly: true,
        ),
      ],
    );
  }

  // --- NEW: Edit-mode widget ---
  Widget _buildEditMode(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      children: [
        _buildTextField(
          context,
          controller.nameController,
          'Name',
          FontAwesomeIcons.userDoctor,
        ),
        const SizedBox(height: 16),
        _buildTextField(
          context,
          controller.emailController,
          'Email',
          FontAwesomeIcons.solidEnvelope,
        ),
        const SizedBox(height: 16),
        _buildTextField(
          context,
          controller.clinicController,
          'Clinic',
          FontAwesomeIcons.clinicMedical,
        ),
        const Divider(),
        _buildProfileTile(
          context,
          icon: FontAwesomeIcons.idBadge,
          title: 'License ID',
          subtitle: controller.vetUser['regNo']!,
          isReadOnly: true,
        ),
      ],
    );
  }

  // --- UPDATED: Helper for TextFields ---
  Widget _buildTextField(
    BuildContext context,
    TextEditingController textController,
    String label,
    IconData icon,
  ) {
    final theme = Theme.of(context);
    return TextFormField(
      controller: textController,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: FaIcon(icon, size: 16, color: theme.colorScheme.primary),
        filled: true,
        fillColor: theme.scaffoldBackgroundColor,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: theme.dividerTheme.color!),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: theme.dividerTheme.color!),
        ),
      ),
    );
  }

  Widget _buildProfileTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    bool isReadOnly = false,
  }) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          FaIcon(
            icon,
            size: 18,
            color: isReadOnly ? theme.disabledColor : theme.colorScheme.primary,
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: isReadOnly
                      ? theme.disabledColor
                      : theme.textTheme.bodySmall?.color?.withOpacity(0.7),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: isReadOnly ? theme.disabledColor : null,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
