import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:sat_vet_app/controllers/vet/vet_dashboard_controller.dart';
// import 'package:sat_vet_app/models/farm_model.dart';
import 'package:sat_vet_app/widgets/vet/compliance_badge.dart';
import 'package:sat_vet_app/widgets/vet/request_list_tile.dart';
// import 'package:sat_vet_app/routes/app_routes.dart';

class VetDashboardScreen extends GetView<VetDashboardController> {
  const VetDashboardScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return LayoutBuilder(
      builder: (context, constraints) {
        // Obx listens to controller state changes
        return Obx(() {
          if (controller.isLoading.isTrue) {
            return const Center(child: CircularProgressIndicator());
          }

          if (constraints.maxWidth < 600) {
            return _buildMobileLayout(context, theme);
          } else {
            return _buildWideLayout(context, theme);
          }
        });
      },
    );
  }

  Widget _buildMobileLayout(BuildContext context, ThemeData theme) {
    return ListView(
      padding: const EdgeInsets.all(16.0),
      children: [
        _buildRequestsCard(context, theme),
        const SizedBox(height: 20),
        _buildPrescriptionButton(context, theme),
        const SizedBox(height: 20),
        _buildFarmsCard(context, theme),
      ],
    );
  }

  Widget _buildWideLayout(BuildContext context, ThemeData theme) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildPrescriptionButton(context, theme, isWide: true),
          const SizedBox(height: 24),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(flex: 2, child: _buildRequestsCard(context, theme)),
              const SizedBox(width: 24),
              Expanded(flex: 1, child: _buildFarmsCard(context, theme)),
            ],
          ),
        ],
      ),
    );
  }

  // --- Reusable Widget Methods ---

  Widget _buildRequestsCard(BuildContext context, ThemeData theme) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // This title will now update automatically
            Obx(
              () => Text(
                'Pending Farm Requests (${controller.pendingRequests.length})',
                style: theme.textTheme.titleLarge?.copyWith(
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 12),

            // --- THIS IS THE FIX ---
            Obx(() {
              if (controller.pendingRequests.isEmpty) {
                // Show a message if the list is empty
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 24.0),
                  child: Center(
                    child: Text(
                      'No requests currently',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.textTheme.bodySmall?.color?.withOpacity(
                          0.7,
                        ),
                      ),
                    ),
                  ),
                );
              }

              // If not empty, show the list and the button
              return Column(
                children: [
                  ...controller.pendingRequests.map(
                    (farm) => RequestListTile(
                      farm: farm,
                      onApprove: () => controller.approveFarm(farm.id),
                      onDeny: () => controller.denyFarm(farm.id),
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextButton(
                    onPressed: controller.reviewAllRequests,
                    child: const Text('Review All Requests...'),
                  ),
                ],
              );
            }),
            // --- END OF FIX ---
          ],
        ),
      ),
    );
  }

  Widget _buildPrescriptionButton(
    BuildContext context,
    ThemeData theme, {
    bool isWide = false,
  }) {
    return ElevatedButton.icon(
      icon: const FaIcon(FontAwesomeIcons.fileMedical, size: 18),
      label: const Text('CREATE NEW PRESCRIPTION'),
      onPressed: controller.goToNewPrescription,
      style: isWide
          ? theme.elevatedButtonTheme.style?.copyWith(
              padding: MaterialStateProperty.all(
                const EdgeInsets.symmetric(vertical: 24, horizontal: 32),
              ),
              textStyle: MaterialStateProperty.all(
                theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            )
          : null,
    );
  }

  Widget _buildFarmsCard(BuildContext context, ThemeData theme) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'My Linked Farms',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            // Obx listens to the controller's list
            Obx(() {
              if (controller.linkedFarms.isEmpty) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 24.0),
                  child: Center(
                    child: Text(
                      'No linked farms yet',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.textTheme.bodySmall?.color?.withOpacity(
                          0.7,
                        ),
                      ),
                    ),
                  ),
                );
              }
              return Column(
                children: controller.linkedFarms
                    .map(
                      (farm) => ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: const FaIcon(FontAwesomeIcons.cow, size: 20),
                        title: Text(farm.name),
                        trailing: ComplianceBadge(compliance: farm.compliance),
                        onTap: () => controller.goToFarmDetails(farm),
                      ),
                    )
                    .toList(),
              );
            }),
          ],
        ),
      ),
    );
  }
}
