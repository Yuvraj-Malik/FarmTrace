import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:sat_vet_app/controllers/vet/vet_new_prescription_controller.dart';
import 'package:sat_vet_app/models/farm_model.dart';

class NewPrescriptionScreen extends GetView<NewPrescriptionController> {
  const NewPrescriptionScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isWide = MediaQuery.of(context).size.width >= 600;

    return Scaffold(
      appBar: AppBar(
        title: const Text('New Prescription'),
        leading: IconButton(
          icon: const FaIcon(FontAwesomeIcons.xmark),
          onPressed: () => Get.back(),
        ),
      ),
      body: Obx(() {
        // Obx widget rebuilds when controller variables change
        if (controller.isLoading.isTrue) {
          return const Center(child: CircularProgressIndicator());
        }

        return Center(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 700),
            child: ListView(
              padding: EdgeInsets.all(isWide ? 32.0 : 16.0),
              children: [
                // --- 1. Select Farm ---
                _buildDropdown<Farm>(
                  context: context,
                  label: 'Step 1: Select Farm',
                  value: controller.selectedFarm.value,
                  items: controller.linkedFarms,
                  onChanged: controller.onFarmSelected,
                  itemAsString: (farm) => farm.name,
                  icon: FontAwesomeIcons.cow,
                ),

                const SizedBox(height: 20),

                // --- 2. Select Animal ---
                _buildDropdown<Map<String, String>>(
                  context: context,
                  label: 'Step 2: Select Animal',
                  value: controller.selectedAnimal.value,
                  items: controller.selectedFarm.value != null
                      ? controller.animals
                      : [],
                  onChanged: controller.onAnimalSelected,
                  itemAsString: (animal) => animal['tag']!,
                  icon: FontAwesomeIcons.tags,
                  disabledHint: 'Select a farm first',
                ),

                const SizedBox(height: 20),

                // --- 3. Select Drug ---
                _buildDropdown<Map<String, dynamic>>(
                  context: context,
                  label: 'Step 3: Select Drug',
                  value: controller.selectedDrug.value,
                  items: controller.drugs,
                  onChanged: controller.onDrugSelected,
                  itemAsString: (drug) =>
                      "${drug['name']} (${drug['withdrawal']} day withdrawal)",
                  icon: FontAwesomeIcons.pills,
                ),

                const SizedBox(height: 20),

                // --- 4. Dosage & Date (Side-by-Side) ---
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: _buildTextField(
                        context: context,
                        label: 'Step 4: Dosage (ml)',
                        icon: FontAwesomeIcons.syringe,
                        keyboardType: TextInputType.number,
                        onChanged: controller.onDosageChanged,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(child: _buildDateField(context)),
                  ],
                ),

                const SizedBox(height: 24),

                // --- 5. Confirmation Card ---
                // Obx will automatically show/hide this
                Obx(() {
                  if (controller.withdrawalDate == null) {
                    return const SizedBox.shrink();
                  }
                  return Card(
                    color: theme.colorScheme.primary.withOpacity(0.1),
                    elevation: 0,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Compliance Confirmation',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: theme.colorScheme.primary,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'This treatment will require a ${controller.selectedDrug.value!['withdrawal']}-day withdrawal period.',
                            style: theme.textTheme.bodyMedium,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Safe Date: ${controller.withdrawalDate}',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }),

                const SizedBox(height: 24),

                // --- 6. Submit Button ---
                ElevatedButton.icon(
                  icon: const FaIcon(FontAwesomeIcons.fileContract, size: 18),
                  label: const Text('SUBMIT OFFICIAL RECORD'),
                  onPressed: controller.submitPrescription,
                  style: theme.elevatedButtonTheme.style?.copyWith(
                    padding: MaterialStateProperty.all(
                      const EdgeInsets.symmetric(vertical: 20),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      }),
    );
  }

  // --- Reusable Form Field Widgets ---

  Widget _buildDropdown<T>({
    required BuildContext context,
    required String label,
    required IconData icon,
    required T? value,
    required List<T> items,
    required Function(T?) onChanged,
    required String Function(T) itemAsString,
    String disabledHint = 'Please complete previous steps',
  }) {
    final theme = Theme.of(context);
    bool isDisabled = items.isEmpty && value == null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: theme.textTheme.titleSmall),
        const SizedBox(height: 8),
        DropdownButtonFormField<T>(
          value: value,
          items: items.map((T item) {
            return DropdownMenuItem<T>(
              value: item,
              child: Text(itemAsString(item)),
            );
          }).toList(),
          onChanged: isDisabled ? null : onChanged,
          icon: const FaIcon(FontAwesomeIcons.chevronDown, size: 16),
          decoration: InputDecoration(
            hintText: isDisabled ? disabledHint : 'Select...',
            prefixIcon: FaIcon(
              icon,
              size: 16,
              color: theme.colorScheme.primary,
            ),
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
      ],
    );
  }

  Widget _buildTextField({
    required BuildContext context,
    required String label,
    required IconData icon,
    required Function(String) onChanged,
    TextInputType keyboardType = TextInputType.text,
  }) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: theme.textTheme.titleSmall),
        const SizedBox(height: 8),
        TextFormField(
          onChanged: onChanged,
          keyboardType: keyboardType,
          decoration: InputDecoration(
            prefixIcon: FaIcon(
              icon,
              size: 16,
              color: theme.colorScheme.primary,
            ),
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
      ],
    );
  }

  Widget _buildDateField(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Step 5: Date', style: theme.textTheme.titleSmall),
        const SizedBox(height: 8),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: theme.cardColor,
            foregroundColor: theme.textTheme.bodyLarge?.color,
            elevation: 0,
            side: BorderSide(color: theme.dividerTheme.color!),
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
          ),
          onPressed: () async {
            final DateTime? picked = await showDatePicker(
              context: context,
              initialDate: controller.treatmentDate.value ?? DateTime.now(),
              firstDate: DateTime(2020),
              lastDate: DateTime.now(),
            );
            if (picked != null && picked != controller.treatmentDate.value) {
              controller.onDateSelected(picked);
            }
          },
          child: Row(
            children: [
              FaIcon(
                FontAwesomeIcons.calendar,
                size: 16,
                color: theme.colorScheme.primary,
              ),
              const SizedBox(width: 8),
              // Obx makes this text update automatically
              Obx(
                () => Text(
                  controller.treatmentDate.value == null
                      ? 'Select Date'
                      : "${controller.treatmentDate.value!.year}-${controller.treatmentDate.value!.month.toString().padLeft(2, '0')}-${controller.treatmentDate.value!.day.toString().padLeft(2, '0')}",
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
