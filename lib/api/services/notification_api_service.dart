import 'dart:convert';
import 'package:get/get.dart';
import 'package:luna_iot/api/api_client.dart';
import 'package:luna_iot/api/api_endpoints.dart';
import 'package:luna_iot/controllers/auth_controller.dart';
import 'package:luna_iot/models/notification_model.dart' as NotificationModel;

class NotificationApiService {
  final ApiClient _apiClient;

  NotificationApiService(this._apiClient);

  // Get notifications (role-based)
  Future<List<NotificationModel.Notification>> getNotifications() async {
    try {
      final response = await _apiClient.dio.get(ApiEndpoints.getNotifications);

      print('API Response: ${response.data}'); // Debug log

      // Handle different response formats
      final data = response.data['data'];
      if (data == null) {
        print('No data in response');
        return [];
      }

      // Check if data is a list
      if (data is List) {
        return data
            .map((json) => NotificationModel.Notification.fromJson(json))
            .toList();
      } else if (data is String) {
        print('Data is string, trying to parse as JSON');
        final parsedData = jsonDecode(data);
        if (parsedData is List) {
          return parsedData
              .map((json) => NotificationModel.Notification.fromJson(json))
              .toList();
        }
      }

      print('Unexpected data format: ${data.runtimeType}');
      return [];
    } catch (e) {
      print('Error in getNotifications: $e');
      throw Exception('Failed to fetch notifications: $e');
    }
  }

  // Create notification (Super Admin only)
  Future<NotificationModel.Notification> createNotification({
    required String title,
    required String message,
    required String type,
    List<int>? targetUserIds,
    List<int>? targetRoleIds,
  }) async {
    try {
      final response = await _apiClient.dio.post(
        ApiEndpoints.createNotification,
        data: {
          'title': title,
          'message': message,
          'type': type,
          'targetUserIds': targetUserIds,
          'targetRoleIds': targetRoleIds,
        },
      );
      return NotificationModel.Notification.fromJson(response.data['data']);
    } catch (e) {
      throw Exception('Failed to create notification: $e');
    }
  }

  // Delete notification (Super Admin only)
  Future<void> deleteNotification(int id) async {
    try {
      await _apiClient.dio.delete(
        ApiEndpoints.deleteNotification.replaceAll(':id', id.toString()),
      );
    } catch (e) {
      throw Exception('Failed to delete notification: $e');
    }
  }

  // Mark notification as read
  Future<void> markNotificationAsRead(int notificationId) async {
    try {
      await _apiClient.dio.put(
        ApiEndpoints.markNotificationAsRead.replaceAll(
          ':notificationId',
          notificationId.toString(),
        ),
      );
    } catch (e) {
      throw Exception('Failed to mark notification as read: $e');
    }
  }

  // Get unread notification count
  Future<int> getUnreadNotificationCount() async {
    try {
      final response = await _apiClient.dio.get(
        ApiEndpoints.getUnreadNotificationCount,
      );
      return response.data['data']['count'];
    } catch (e) {
      throw Exception('Failed to fetch unread notification count: $e');
    }
  }

  // Update FCM token
  Future<void> updateFcmToken(String fcmToken) async {
    try {
      // Get current user phone from auth storage or controller
      final authController = Get.find<AuthController>();
      final userPhone = authController.currentUser.value?.phone;

      if (userPhone == null) {
        throw Exception('User phone not available');
      }

      await _apiClient.dio.put(
        ApiEndpoints.updateFcmToken,
        data: {
          'fcmToken': fcmToken,
          'phone': userPhone, // Add phone parameter
        },
      );
    } catch (e) {
      throw Exception('Failed to update FCM token: $e');
    }
  }
}
