import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:luna_iot/app/app_routes.dart';
import 'package:luna_iot/app/app_theme.dart';
import 'package:luna_iot/controllers/device_controller.dart';
import 'package:luna_iot/widgets/confirm_dialouge.dart';
import 'package:luna_iot/widgets/loading_widget.dart';
import 'package:luna_iot/widgets/role_based_widget.dart';

class DeviceIndexScreen extends GetView<DeviceController> {
  const DeviceIndexScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // AppBar
      appBar: AppBar(
        title: Text(
          'Devices',
          style: TextStyle(color: AppTheme.titleColor, fontSize: 14),
        ),
      ),

      // Add Button in Floating Action
      floatingActionButton: RoleBasedWidget(
        allowedRoles: ['Super Admin'],
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            FloatingActionButton(
              onPressed: () {
                Get.toNamed(AppRoutes.deviceAssignment);
              },
              backgroundColor: AppTheme.primaryColor,
              tooltip: 'Assign Devices',
              child: const Icon(Icons.assignment, color: Colors.white),
            ),
            const SizedBox(height: 8),
            FloatingActionButton(
              onPressed: () {
                Get.toNamed(AppRoutes.deviceCreate);
              },
              backgroundColor: AppTheme.primaryColor,
              tooltip: 'Add Device',
              child: const Icon(Icons.add, color: Colors.white),
            ),
          ],
        ),
      ),

      // Main Body Start
      body: Obx(() {
        if (controller.loading.value) {
          return const LoadingWidget();
        }

        if (controller.devices.isEmpty) {
          return Center(
            child: Text(
              'No devices found',
              style: TextStyle(color: AppTheme.subTitleColor),
            ),
          );
        }

        return ListView(
          children: [
            for (var device in controller.devices)
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 8,
                ),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 10,
                        offset: Offset(0, 4),
                      ),
                    ],
                    border: Border.all(
                      color: AppTheme.secondaryColor,
                      width: 1,
                    ),
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    leading: CircleAvatar(
                      backgroundColor: AppTheme.primaryColor.withOpacity(0.1),
                      child: Icon(Icons.memory, color: AppTheme.primaryColor),
                    ),
                    title: Text(
                      device.imei,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: AppTheme.titleColor,
                        fontSize: 14,
                      ),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (device.phone != null && device.phone!.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(top: 2.0),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.phone,
                                  size: 12,
                                  color: AppTheme.subTitleColor,
                                ),
                                SizedBox(width: 4),
                                Text(
                                  device.phone!,
                                  style: TextStyle(
                                    color: AppTheme.subTitleColor,
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        // Assigned User(s)
                        if (device.userDevices != null &&
                            device.userDevices!.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(top: 2.0),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.record_voice_over,
                                  size: 12,
                                  color: AppTheme.subTitleColor,
                                ),
                                SizedBox(width: 4),
                                Text(
                                  device.userDevices!
                                      .map((ud) => ud['user']?['name'] ?? '')
                                      .where((name) => name.isNotEmpty)
                                      .join(', '),
                                  style: TextStyle(
                                    color: AppTheme.subTitleColor,
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        // Assigned Vehicle(s)
                        Padding(
                          padding: const EdgeInsets.only(top: 2.0),
                          child: Row(
                            children: [
                              Icon(
                                Icons.directions_car,
                                size: 12,
                                color: AppTheme.subTitleColor,
                              ),
                              SizedBox(width: 4),
                              Builder(
                                builder: (context) {
                                  final vehicles = device.vehicles ?? [];
                                  final assignedVehicles = vehicles
                                      .where(
                                        (v) =>
                                            (v['vehicleNo'] != null &&
                                                (v['vehicleNo'] as String)
                                                    .isNotEmpty) ||
                                            (v['name'] != null &&
                                                (v['name'] as String)
                                                    .isNotEmpty),
                                      )
                                      .toList();

                                  if (assignedVehicles.isNotEmpty) {
                                    final vehicleNames = assignedVehicles
                                        .map(
                                          (v) =>
                                              (v['vehicleNo'] != null &&
                                                  (v['vehicleNo'] as String)
                                                      .isNotEmpty)
                                              ? v['vehicleNo']
                                              : v['name'],
                                        )
                                        .join(', ');
                                    return Container(
                                      padding: EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 2,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.green.withOpacity(0.08),
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: Text(
                                        'ASSIGNED',
                                        style: TextStyle(
                                          color: Colors.green[800],
                                          fontSize: 13,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    );
                                  } else {
                                    return Container(
                                      padding: EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 2,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.red.withOpacity(0.08),
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: Text(
                                        'NOT ASSIGNED',
                                        style: TextStyle(
                                          color: Colors.red[800],
                                          fontSize: 13,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    );
                                  }
                                },
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    trailing: RoleBasedWidget(
                      allowedRoles: ['Super Admin'],
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              color: AppTheme.primaryColor.withOpacity(0.12),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: IconButton(
                              tooltip: 'Edit Device',
                              onPressed: () {
                                Get.toNamed(
                                  AppRoutes.deviceEdit.replaceAll(
                                    ':imei',
                                    device.imei,
                                  ),
                                  arguments: device,
                                );
                              },
                              icon: Icon(
                                Icons.edit,
                                color: AppTheme.primaryColor,
                              ),
                            ),
                          ),
                          SizedBox(width: 8),
                          Container(
                            decoration: BoxDecoration(
                              color: AppTheme.errorColor.withOpacity(0.12),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: IconButton(
                              tooltip: 'Delete Device',
                              onPressed: () {
                                showDialog(
                                  context: context,
                                  builder: (context) => ConfirmDialouge(
                                    title: 'Confirm Delete Device',
                                    message:
                                        'All location, status and vehicle data also deleted with this device. Are you sure to delete device?',
                                    onConfirm: () {
                                      controller.deleteDevice(device.imei);
                                    },
                                  ),
                                );
                              },
                              icon: Icon(
                                Icons.delete,
                                color: AppTheme.errorColor,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
          ],
        );
      }),
    );
  }
}
