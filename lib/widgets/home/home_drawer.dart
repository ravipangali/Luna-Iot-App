import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:luna_iot/app/app_theme.dart';
import 'package:luna_iot/controllers/auth_controller.dart';

class HomeDrawer extends StatelessWidget {
  const HomeDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final AuthController authController = Get.find<AuthController>();

    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          Obx(() {
            final user = authController.currentUser.value;
            return UserAccountsDrawerHeader(
              accountName: Text(user?.name ?? 'User'),
              accountEmail: Text(user?.phone ?? ''),
              currentAccountPicture: CircleAvatar(
                backgroundColor: Colors.white,
                child: Text(
                  user?.name.substring(0, 1).toUpperCase() ?? 'U',
                  style: TextStyle(fontSize: 24, color: AppTheme.primaryColor),
                ),
              ),
              decoration: BoxDecoration(color: AppTheme.primaryColor),
            );
          }),

          // Super Admin Menu Items
          Obx(() {
            if (authController.isSuperAdmin) {
              return Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.admin_panel_settings),
                    title: const Text('Admin Panel'),
                    onTap: () => Get.toNamed('/admin'),
                  ),
                  ListTile(
                    leading: const Icon(Icons.devices),
                    title: const Text('Devices'),
                    onTap: () => Get.toNamed('/devices'),
                  ),
                  ListTile(
                    leading: const Icon(Icons.people),
                    title: const Text('Users'),
                    onTap: () => Get.toNamed('/users'),
                  ),
                  ListTile(
                    leading: const Icon(Icons.security),
                    title: const Text('Roles'),
                    onTap: () => Get.toNamed('/roles'),
                  ),
                  ListTile(
                    leading: const Icon(Icons.monitor),
                    title: const Text('Device Monitoring'),
                    onTap: () => Get.toNamed('/device-monitoring'),
                  ),
                  const Divider(),
                ],
              );
            }
            return const SizedBox.shrink();
          }),

          // Dealer Menu Items
          Obx(() {
            if (authController.isDealer) {
              return Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.devices),
                    title: const Text('My Devices'),
                    onTap: () => Get.toNamed('/devices'),
                  ),
                  const Divider(),
                ],
              );
            }
            return const SizedBox.shrink();
          }),

          // Common Menu Items (for all roles)
          ListTile(
            leading: const Icon(Icons.directions_car),
            title: const Text('Vehicles'),
            onTap: () => Get.toNamed('/vehicles'),
          ),
          ListTile(
            leading: const Icon(Icons.location_on),
            title: const Text('Live Tracking'),
            onTap: () => Get.toNamed('/live-tracking'),
          ),
          ListTile(
            leading: const Icon(Icons.history),
            title: const Text('Trip History'),
            onTap: () => Get.toNamed('/history'),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text('Logout'),
            onTap: () => authController.logout(),
          ),
        ],
      ),
    );
  }
}
