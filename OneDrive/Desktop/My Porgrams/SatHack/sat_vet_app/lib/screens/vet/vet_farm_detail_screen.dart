import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:sat_vet_app/controllers/vet/vet_farm_detail_controller.dart';
import 'package:sat_vet_app/models/farm_model.dart';
import 'package:sat_vet_app/widgets/vet/compliance_badge.dart';
import 'package:sat_vet_app/routes/app_routes.dart';

// --- 1. CHANGED TO A GetView ---
class VetFarmDetailScreen extends GetView<VetFarmDetailController> {
  const VetFarmDetailScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    // --- 2. GET THE FARM FROM THE CONTROLLER ---
    final Farm farm = controller.farm;

    return Scaffold(
      appBar: AppBar(title: Text(farm.name)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (farm.isPending) ...[
              // --- Pending Request View ---
              Text(
                'Pending Request',
                style: theme.textTheme.headlineSmall?.copyWith(
                  color: theme.colorScheme.secondary,
                ),
              ),
              const SizedBox(height: 16),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(farm.name, style: theme.textTheme.titleLarge),
                      Text(
                        farm.owner,
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: theme.textTheme.bodySmall?.color,
                        ),
                      ),
                      const SizedBox(height: 24),
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton.icon(
                              icon: const FaIcon(
                                FontAwesomeIcons.check,
                                size: 16,
                              ),
                              label: const Text('Approve'),
                              // --- 3. CALL CONTROLLER METHOD ---
                              onPressed: controller.approveFarm,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green.shade600,
                                foregroundColor: Colors.white,
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: ElevatedButton.icon(
                              icon: const FaIcon(
                                FontAwesomeIcons.xmark,
                                size: 16,
                              ),
                              label: const Text('Deny'),
                              // --- 4. CALL CONTROLLER METHOD ---
                              onPressed: controller.denyFarm,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red.shade600,
                                foregroundColor: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ] else ...[
              // --- Linked Farm Detail View ---
              Text(
                farm.name,
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                farm.owner,
                style: theme.textTheme.titleMedium?.copyWith(
                  color: theme.textTheme.bodySmall?.color,
                ),
              ),
              const SizedBox(height: 16),
              Card(
                child: ListTile(
                  leading: const FaIcon(FontAwesomeIcons.shieldHalved),
                  title: const Text('Compliance Score'),
                  trailing: ComplianceBadge(
                    compliance: farm.compliance,
                    isLarge: true,
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // --- 5. NEW: ANIMAL SEARCH BAR (Mobile) ---
              Text(
                'Livestock on this Farm',
                style: theme.textTheme.titleMedium,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: TextField(
                  onChanged: (value) =>
                      controller.animalSearchQuery.value = value,
                  decoration: InputDecoration(
                    hintText: 'Search animal by tag...',
                    prefixIcon: const Icon(FontAwesomeIcons.search, size: 16),
                    filled: true,
                    fillColor: theme.cardColor,
                    contentPadding: EdgeInsets.zero,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: theme.dividerTheme.color!),
                    ),
                  ),
                ),
              ),
              const Divider(),

              // --- 6. NEW: ANIMAL LIST (from controller) ---
              Obx(() {
                if (controller.filteredAnimals.isEmpty) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(24.0),
                      child: Text('No matching animals found.'),
                    ),
                  );
                }
                return Column(
                  children: controller.filteredAnimals
                      .map(
                        (animal) => ListTile(
                          leading: const FaIcon(FontAwesomeIcons.tags),
                          title: Text(animal.tag),
                          trailing: const Icon(Icons.chevron_right),
                          onTap: () {
                            controller.goToAnimalDetails(animal.id);
                          },
                        ),
                      )
                      .toList(),
                );
              }),
            ],
          ],
        ),
      ),
    );
  }
}
