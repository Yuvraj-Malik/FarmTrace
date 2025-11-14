import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:sat_vet_app/controllers/vet/vet_animal_detail_controller.dart';
import 'package:sat_vet_app/models/animal_model.dart';

class VetAnimalDetailScreen extends GetView<VetAnimalDetailController> {
  const VetAnimalDetailScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Obx(() => Text(controller.animal.value?.tag ?? 'Loading...')),
      ),

      // --- NEW: Added Floating Action Button ---
      floatingActionButton: FloatingActionButton.extended(
        icon: const FaIcon(FontAwesomeIcons.fileMedical),
        label: const Text('Prescribe'),
        onPressed: controller.goToNewPrescription,
      ),

      body: Obx(() {
        if (controller.isLoading.isTrue) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.animal.value == null) {
          return const Center(child: Text('Error: Animal not found.'));
        }

        final animal = controller.animal.value!;
        final statusColor = animal.status == 'ACTIVE'
            ? Colors.orange.shade800
            : (animal.status == 'PENDING'
                  ? Colors.amber.shade800
                  : Colors.green.shade600);

        return ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            // --- 1. Status Card ---
            Card(
              elevation: 2,
              color: statusColor.withOpacity(0.1),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Text(
                      'STATUS: ${animal.status}',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: statusColor,
                      ),
                    ),
                    if (animal.status != 'CLEAR') ...[
                      const SizedBox(height: 8),
                      Text(
                        'Withdrawal ends: ${animal.withdrawalEnd}',
                        style: theme.textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // --- 2. Animal Details Card ---
            Card(
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Animal Details',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildDetailRow(theme, 'Tag ID', animal.tag),
                    _buildDetailRow(theme, 'Species', animal.species),
                    _buildDetailRow(theme, 'Age', animal.age),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // --- 3. Treatment History ---
            Text(
              'Treatment History',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),

            // --- NEW: Search Bar ---
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: TextField(
                onChanged: controller.onSearchChanged,
                decoration: InputDecoration(
                  hintText: 'Search drug history...',
                  prefixIcon: const Icon(FontAwesomeIcons.search, size: 16),
                  filled: true,
                  fillColor: theme.cardColor,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: theme.dividerTheme.color!),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: theme.dividerTheme.color!),
                  ),
                ),
              ),
            ),

            // --- NEW: Wrap list in Obx ---
            Obx(() {
              if (controller.filteredHistory.isEmpty) {
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Text('No treatment history found.'),
                  ),
                );
              }
              return Column(
                children: controller.filteredHistory
                    .map((tx) => _buildTreatmentTile(theme, tx))
                    .toList(),
              );
            }),

            // Add padding for the FAB
            const SizedBox(height: 80),
          ],
        );
      }),
    );
  }

  // ... (Helper widgets _buildDetailRow and _buildTreatmentTile are unchanged) ...
  Widget _buildDetailRow(ThemeData theme, String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.textTheme.bodySmall?.color?.withOpacity(0.7),
            ),
          ),
          Text(
            value,
            style: theme.textTheme.bodyLarge?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTreatmentTile(ThemeData theme, Treatment tx) {
    return Card(
      elevation: 1,
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: FaIcon(
          FontAwesomeIcons.pills,
          color: theme.colorScheme.primary,
        ),
        title: Text(
          tx.drugName,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text('Dosage: ${tx.dosage} • By: ${tx.vetName}'),
        trailing: Text(tx.date),
      ),
    );
  }
}
