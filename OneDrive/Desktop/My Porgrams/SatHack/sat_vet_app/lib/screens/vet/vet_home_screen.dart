import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:sat_vet_app/controllers/vet/vet_home_controller.dart';
import 'package:sat_vet_app/screens/vet/vet_drawer.dart';
import 'package:sat_vet_app/routes/app_routes.dart';

class VetHomeScreen extends GetView<VetHomeController> {
  const VetHomeScreen({Key? key}) : super(key: key);

  AppBar _buildAppBar(BuildContext context) {
    int selectedIndex = controller.selectedIndex.value;

    // --- THIS IS THE FIX ---
    // Helper function to create the leading drawer button
    Widget buildDrawerButton() {
      return IconButton(
        icon: const FaIcon(FontAwesomeIcons.barsStaggered),
        onPressed: () {
          // This is how you open a drawer from a sub-widget
          Scaffold.of(context).openDrawer();
        },
      );
    }

    // Page 1: Dashboard
    if (selectedIndex == 0) {
      return AppBar(
        title: const Text('Vet Dashboard'),
        leading: buildDrawerButton(), // <-- Use the helper
        actions: [
          IconButton(
            icon: const FaIcon(FontAwesomeIcons.bell),
            onPressed: () => Get.toNamed(AppRoutes.VET_NOTIFICATIONS),
            tooltip: 'Notifications',
          ),
          const SizedBox(width: 8),
        ],
      );
    }

    // Page 2: My Farms (with TabBar)
    if (selectedIndex == 1) {
      return AppBar(
        title: const Text('My Farms'),
        leading: buildDrawerButton(), // <-- Use the helper
        bottom: TabBar(
          controller: controller.tabController,
          tabs: const [
            Tab(text: 'Linked Farms'),
            Tab(text: 'Pending Requests'),
          ],
        ),
      );
    }

    // Page 3: Profile
    if (selectedIndex == 2) {
      return AppBar(
        title: const Text('My Profile'),
        leading: buildDrawerButton(), // <-- Use the helper
      );
    }

    return AppBar();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Obx(() {
          // --- MOBILE LAYOUT ---
          if (constraints.maxWidth < 600) {
            return Scaffold(
              // We need a Builder here so _buildAppBar can find the Scaffold
              appBar: PreferredSize(
                preferredSize: Size.fromHeight(
                  controller.selectedIndex.value == 1 ? 112.0 : 56.0,
                ),
                child: Builder(builder: (context) => _buildAppBar(context)),
              ),
              drawer: const VetDrawer(),
              body: controller.pages[controller.selectedIndex.value],
              bottomNavigationBar: BottomNavigationBar(
                items: const <BottomNavigationBarItem>[
                  BottomNavigationBarItem(
                    icon: FaIcon(FontAwesomeIcons.house),
                    label: 'Dashboard',
                  ),
                  BottomNavigationBarItem(
                    icon: FaIcon(FontAwesomeIcons.chartSimple),
                    label: 'My Farms',
                  ),
                  BottomNavigationBarItem(
                    icon: FaIcon(FontAwesomeIcons.userDoctor),
                    label: 'Profile',
                  ),
                ],
                currentIndex: controller.selectedIndex.value,
                onTap: controller.onItemTapped,
                selectedItemColor: Theme.of(
                  context,
                ).bottomNavigationBarTheme.selectedItemColor,
                unselectedItemColor: Theme.of(
                  context,
                ).bottomNavigationBarTheme.unselectedItemColor,
                showUnselectedLabels: true,
                type: BottomNavigationBarType.fixed,
              ),
            );
          }
          // --- TABLET/DESKTOP LAYOUT ---
          else {
            return Scaffold(
              // We need a Builder here too
              appBar: PreferredSize(
                preferredSize: Size.fromHeight(
                  controller.selectedIndex.value == 1 ? 112.0 : 56.0,
                ),
                child: Builder(builder: (context) => _buildAppBar(context)),
              ),
              drawer: const VetDrawer(),
              body: Row(
                children: <Widget>[
                  NavigationRail(
                    selectedIndex: controller.selectedIndex.value,
                    onDestinationSelected: controller.onItemTapped,
                    labelType: NavigationRailLabelType.all,
                    selectedIconTheme: IconThemeData(
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    unselectedIconTheme: IconThemeData(
                      color: Theme.of(context).unselectedWidgetColor,
                    ),
                    selectedLabelTextStyle: TextStyle(
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    destinations: const <NavigationRailDestination>[
                      NavigationRailDestination(
                        icon: FaIcon(FontAwesomeIcons.house),
                        label: Text('Dashboard'),
                      ),
                      NavigationRailDestination(
                        icon: FaIcon(FontAwesomeIcons.chartSimple),
                        label: Text('My Farms'),
                      ),
                      NavigationRailDestination(
                        icon: FaIcon(FontAwesomeIcons.userDoctor),
                        label: Text('Profile'),
                      ),
                    ],
                  ),
                  const VerticalDivider(thickness: 1, width: 1),
                  Expanded(
                    child: controller.pages[controller.selectedIndex.value],
                  ),
                ],
              ),
            );
          }
        });
      },
    );
  }
}
