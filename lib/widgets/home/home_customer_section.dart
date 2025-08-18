import 'package:flutter/material.dart';
import 'package:luna_iot/app/app_routes.dart';
import 'package:luna_iot/widgets/home/home_feature_card.dart';
import 'package:luna_iot/widgets/home/home_feature_section_title.dart';

class HomeCustomerSection extends StatelessWidget {
  const HomeCustomerSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Column(
        children: [
          // Section Title
          HomeFeatureSectionTitle(title: 'Track Private Vehicles'),
          GridView.count(
            crossAxisCount: 3,
            crossAxisSpacing: 7,
            mainAxisSpacing: 7,
            physics: const NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            children: [
              HomeFeatureCard(
                title: 'My Vehicles',
                subtitle: 'Manage your vehicles',
                icon: Icons.directions_car,
                route: AppRoutes.vehicle,
              ),

              HomeFeatureCard(
                title: 'Playback',
                subtitle: 'View playback',
                icon: Icons.history,
                route: AppRoutes.vehicleHistoryIndex,
              ),
              HomeFeatureCard(
                title: 'Report',
                subtitle: 'View reports',
                icon: Icons.bar_chart,
                route: AppRoutes.vehicleReportIndex,
              ),
              HomeFeatureCard(
                title: 'All Tracking',
                subtitle: 'Track your vehicle',
                icon: Icons.location_on,
                route: AppRoutes.vehicleLiveTrackingIndex,
              ),
              HomeFeatureCard(
                title: 'Geofence',
                subtitle: 'View fencing',
                icon: Icons.map,
                route: AppRoutes.geofence,
              ),
              HomeFeatureCard(
                title: 'Vehicle Access',
                subtitle: 'Manage vehicle access',
                icon: Icons.car_rental,
                route: AppRoutes.vehicleAccess,
              ),
              HomeFeatureCard(
                title: 'Fleet Management',
                subtitle: 'Manage your fleet',
                icon: Icons.tire_repair,
                route: AppRoutes.vehicle,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
