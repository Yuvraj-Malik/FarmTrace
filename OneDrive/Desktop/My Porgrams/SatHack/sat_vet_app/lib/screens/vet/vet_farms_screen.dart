import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:sat_vet_app/controllers/vet/vet_farms_controller.dart';
import 'package:sat_vet_app/controllers/vet/vet_home_controller.dart';
import 'package:sat_vet_app/models/farm_model.dart';
import 'package:sat_vet_app/widgets/vet/compliance_badge.dart';
import 'package:sat_vet_app/routes/app_routes.dart';

class VetFarmsScreen extends GetView<VetFarmsController> {
  const VetFarmsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final homeController = Get.find<VetHomeController>();

    return LayoutBuilder(
      builder: (context, constraints) {
        return Obx(() {
          if (controller.isLoading.isTrue) {
            return const Center(child: CircularProgressIndicator());
          }

          if (constraints.maxWidth >= 600) {
            // --- TABLET / DESKTOP LAYOUT ---
            if (controller.selectedFarm.value == null &&
                controller.linkedFarms.isNotEmpty) {
              controller.selectedFarm.value = controller.linkedFarms.first;
            }

            return Row(
              children: [
                SizedBox(
                  width: 300,
                  child: TabBarView(
                    controller: homeController.tabController,
                    children: [
                      _buildFarmList(
                        context,
                        controller.linkedFarms,
                        isPendingList: false,
                      ),
                      _buildFarmList(
                        context,
                        controller.pendingRequests,
                        isPendingList: true,
                      ),
                    ],
                  ),
                ),
                const VerticalDivider(width: 1, thickness: 1),
                Expanded(
                  child: controller.selectedFarm.value == null
                      ? const Center(
                          child: Text('Select a farm to view details'),
                        )
                      // --- FIX: Use the new StatefulWidget for the detail view ---
                      : _FarmDetailView(
                          key: ValueKey(
                            controller.selectedFarm.value!.id,
                          ), // Ensures it rebuilds
                          farm: controller.selectedFarm.value!,
                          controller: controller,
                        ),
                ),
              ],
            );
          } else {
            // --- MOBILE LAYOUT ---
            return TabBarView(
              controller: homeController.tabController,
              children: [
                _buildFarmList(
                  context,
                  controller.linkedFarms,
                  isPendingList: false,
                ),
                _buildFarmList(
                  context,
                  controller.pendingRequests,
                  isPendingList: true,
                ),
              ],
            );
          }
        });
      },
    );
  }

  /// Builds the list of farms (The "Master" view)
  Widget _buildFarmList(
    BuildContext context,
    List<Farm> farms, {
    required bool isPendingList,
  }) {
    final theme = Theme.of(context);
    // (This whole widget is unchanged and correct)
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: TextField(
            onChanged: (value) {
              if (isPendingList) {
                controller.searchRequestsQuery.value = value;
              } else {
                controller.searchLinkedQuery.value = value;
              }
            },
            decoration: InputDecoration(
              hintText: 'Search by name or owner...',
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

        if (!isPendingList)
          Padding(
            padding: const EdgeInsets.fromLTRB(8, 0, 8, 8),
            child: Obx(
              () => SegmentedButton<int>(
                style: SegmentedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 8,
                  ),
                ),
                onSelectionChanged: (newSelection) {
                  controller.setComplianceFilter(newSelection.first);
                },
                segments: const [
                  ButtonSegment<int>(value: 0, label: Text('All')),
                  ButtonSegment<int>(value: 1, label: Text('< 90%')),
                  ButtonSegment<int>(value: 2, label: Text('>= 90%')),
                ],
                selected: {controller.complianceFilter.value},
              ),
            ),
          ),

        Expanded(
          child: ListView.builder(
            itemCount: farms.isEmpty ? 1 : farms.length,
            itemBuilder: (context, index) {
              if (farms.isEmpty) {
                final message = isPendingList
                    ? 'No requests currently'
                    : 'No matching farms found';
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Text(
                      message,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.textTheme.bodySmall?.color?.withOpacity(
                          0.7,
                        ),
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                );
              }

              final farm = farms[index];
              return Obx(() {
                final isSelected = controller.selectedFarm.value?.id == farm.id;
                return ListTile(
                  tileColor: isSelected
                      ? theme.primaryColor.withOpacity(0.1)
                      : null,
                  leading: FaIcon(
                    farm.isPending
                        ? FontAwesomeIcons.userPlus
                        : FontAwesomeIcons.cow,
                    color: farm.isPending
                        ? theme.colorScheme.secondary
                        : theme.textTheme.bodySmall?.color,
                  ),
                  title: Text(
                    farm.name,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(farm.owner),
                  trailing: farm.isPending
                      ? null
                      : ComplianceBadge(compliance: farm.compliance),
                  onTap: () => controller.onFarmSelected(farm),
                );
              });
            },
          ),
        ),
      ],
    );
  }
}

/// --- NEW STATEFUL WIDGET ---
/// This is the "Detail" view for a selected farm.
/// We make it a StatefulWidget to manage its own animal search query.
class _FarmDetailView extends StatefulWidget {
  final Farm farm;
  final VetFarmsController controller;

  const _FarmDetailView({
    Key? key,
    required this.farm,
    required this.controller,
  }) : super(key: key);

  @override
  State<_FarmDetailView> createState() => _FarmDetailViewState();
}

class _FarmDetailViewState extends State<_FarmDetailView> {
  // Mock data for this farm's animals
  final List<Map<String, String>> _animalsMaster = [
    {'id': 'a1', 'tag': '#102-B (Holstein)'},
    {'id': 'a2', 'tag': '#105-A (Sahiwal)'},
    {'id': 'a3', 'tag': 'Flock-B (Poultry)'},
    {'id': 'a4', 'tag': '#201-C (Gir)'},
  ];

  late List<Map<String, String>> _filteredAnimals;

  @override
  void initState() {
    super.initState();
    // In a real app, you'd fetch this from the API here
    _filteredAnimals = _animalsMaster;
  }

  void _filterAnimalList(String query) {
    if (query.isEmpty) {
      _filteredAnimals = _animalsMaster;
    } else {
      _filteredAnimals = _animalsMaster
          .where(
            (animal) =>
                animal['tag']!.toLowerCase().contains(query.toLowerCase()),
          )
          .toList();
    }
    setState(() {}); // Rebuild the widget
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final farm = widget.farm;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
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
                            onPressed: () =>
                                widget.controller.approveFarm(farm.id),
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
                            onPressed: () =>
                                widget.controller.denyFarm(farm.id),
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
            Text(
              'Livestock on this Farm (${_filteredAnimals.length})',
              style: theme.textTheme.titleMedium,
            ),

            // --- ANIMAL SEARCH BAR ---
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: TextField(
                onChanged: _filterAnimalList, // Call our local filter
                decoration: InputDecoration(
                  hintText: 'Search animal by tag...',
                  prefixIcon: const Icon(FontAwesomeIcons.search, size: 16),
                  filled: true,
                  fillColor: theme.scaffoldBackgroundColor,
                  contentPadding: EdgeInsets.zero,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: theme.dividerTheme.color!),
                  ),
                ),
              ),
            ),
            const Divider(),

            // --- FILTERED ANIMAL LIST ---
            if (_filteredAnimals.isEmpty)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(24.0),
                  child: Text('No matching animals found.'),
                ),
              )
            else
              ..._filteredAnimals.map(
                (animal) => ListTile(
                  leading: const FaIcon(FontAwesomeIcons.tags),
                  title: Text(animal['tag']!),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    // Use the main controller to navigate
                    widget.controller.goToAnimalDetails(farm, animal['id']!);
                  },
                ),
              ),
          ],
        ],
      ),
    );
  }
}
