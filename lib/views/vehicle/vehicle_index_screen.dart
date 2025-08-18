import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:luna_iot/app/app_routes.dart';
import 'package:luna_iot/app/app_theme.dart';
import 'package:luna_iot/controllers/vehicle_controller.dart';
import 'package:luna_iot/widgets/loading_widget.dart';
import 'package:luna_iot/widgets/vehicle/vehicle_card.dart';

class VehicleIndexScreen extends GetView<VehicleController> {
  const VehicleIndexScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Appbar
      appBar: AppBar(
        title: Text(
          'Vehicles',
          style: TextStyle(color: AppTheme.titleColor, fontSize: 14),
        ),
      ),

      // Add Button in Floating Action
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Get.toNamed(AppRoutes.vehicleCreate);
        },
        backgroundColor: AppTheme.primaryColor,
        tooltip: 'Add Vehicle',
        child: const Icon(Icons.add, color: Colors.white),
      ),

      // Main Body Start
      body: Column(
        children: [
          // Filter Buttons
          Container(
            height: 60,
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Obx(() {
              // Ensure we're observing the observable variables
              final selectedFilter = controller.selectedFilter.value;
              final vehiclesList = controller.vehicles;

              return ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 10),
                itemCount: VehicleController.filterOptions.length,
                itemBuilder: (context, index) {
                  final filter = VehicleController.filterOptions[index];
                  final isSelected = selectedFilter == filter;
                  final vehicleCount = controller.getVehicleCountForFilter(
                    filter,
                  );
                  final buttonColor = controller.getFilterButtonColor(filter);
                  return Container(
                    margin: const EdgeInsets.only(right: 8),
                    child: FilterChip(
                      selected: isSelected,
                      label: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            filter,
                            style: TextStyle(
                              color: isSelected ? Colors.white : buttonColor,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? Colors.white.withOpacity(0.3)
                                  : buttonColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              '$vehicleCount',
                              style: TextStyle(
                                color: isSelected ? Colors.white : buttonColor,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      onSelected: (selected) {
                        if (selected) {
                          controller.setFilter(filter);
                        }
                      },
                      selectedColor: buttonColor,
                      backgroundColor: Colors.white,
                      side: BorderSide(
                        color: isSelected
                            ? buttonColor
                            : buttonColor.withOpacity(0.3),
                        width: 1,
                      ),
                      elevation: isSelected ? 2 : 0,
                      shadowColor: buttonColor.withOpacity(0.3),
                    ),
                  );
                },
              );
            }),
          ),

          // Vehicles List
          Expanded(
            child: Obx(() {
              if (controller.loading.value) {
                return const LoadingWidget();
              }

              if (controller.filteredVehicles.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.directions_car_outlined,
                        size: 64,
                        color: AppTheme.subTitleColor.withOpacity(0.5),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        controller.selectedFilter.value == 'All'
                            ? 'No vehicles found'
                            : 'No ${controller.selectedFilter.value.toLowerCase()} vehicles found',
                        style: TextStyle(
                          color: AppTheme.subTitleColor,
                          fontSize: 16,
                        ),
                      ),
                      if (controller.selectedFilter.value != 'All') ...[
                        const SizedBox(height: 8),
                        TextButton(
                          onPressed: () => controller.setFilter('All'),
                          child: Text(
                            'Show All Vehicles',
                            style: TextStyle(color: AppTheme.primaryColor),
                          ),
                        ),
                      ],
                    ],
                  ),
                );
              }

              return RefreshIndicator(
                onRefresh: () => controller.refreshVehicles(),
                child: Padding(
                  padding: const EdgeInsets.all(10),
                  child: ListView.builder(
                    itemCount: controller.filteredVehicles.length,
                    itemBuilder: (context, index) {
                      final vehicle = controller.filteredVehicles[index];
                      return VehicleCard(givenVehicle: vehicle);
                    },
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}
