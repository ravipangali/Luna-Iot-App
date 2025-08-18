import 'package:flutter/material.dart';
import 'package:luna_iot/app/app_routes.dart';
import 'package:luna_iot/widgets/home/home_feature_card.dart';
import 'package:luna_iot/widgets/home/home_feature_section_title.dart';

class HomeDealerSection extends StatelessWidget {
  const HomeDealerSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Column(
        children: [
          HomeFeatureSectionTitle(title: 'Dealer Management'),
          GridView.count(
            crossAxisCount: 3,
            crossAxisSpacing: 7,
            mainAxisSpacing: 7,
            physics: const NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            children: [
              HomeFeatureCard(
                title: 'Device',
                subtitle: 'Manage your devices',
                icon: Icons.memory,
                route: AppRoutes.device,
              ),
              HomeFeatureCard(
                title: 'My Vehicles',
                subtitle: 'Manage your vehicles',
                icon: Icons.directions_car,
                route: AppRoutes.vehicle,
              ),
              HomeFeatureCard(
                title: 'Vehicle Access',
                subtitle: 'Manage vehicle access permissions',
                icon: Icons.car_rental,
                route: AppRoutes.vehicleAccess,
              ),
              HomeFeatureCard(
                title: 'Live Tracking',
                subtitle: 'Track your vehicle',
                icon: Icons.mode_of_travel,
                route: AppRoutes.vehicleLiveTrackingIndex,
              ),
              HomeFeatureCard(
                title: 'History',
                subtitle: 'View vehicle history',
                icon: Icons.calendar_month,
                route: AppRoutes.vehicleHistoryIndex,
              ),
              HomeFeatureCard(
                title: 'Report',
                subtitle: 'View vehicle reports',
                icon: Icons.bar_chart,
                route: AppRoutes.vehicleReportIndex,
              ),
              HomeFeatureCard(
                title: 'Geofence',
                subtitle: 'View vehicle fencing',
                icon: Icons.map,
                route: AppRoutes.geofence,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
