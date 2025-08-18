import 'package:dio/dio.dart';
import 'package:luna_iot/api/api_client.dart';
import 'package:luna_iot/api/api_endpoints.dart';
import 'package:luna_iot/models/history_model.dart';

class HistoryApiService {
  final ApiClient _apiClient;

  HistoryApiService(this._apiClient);

  /// Get combined history by date range
  Future<List<History>> getCombinedHistoryByDateRange(
    String imei,
    DateTime startDate,
    DateTime endDate,
  ) async {
    try {
      final response = await _apiClient.dio.get(
        ApiEndpoints.getCombinedHistoryByDateRange.replaceAll(':imei', imei),
        queryParameters: {
          'startDate': startDate.toIso8601String(),
          'endDate': endDate.toIso8601String(),
        },
      );
      return (response.data['data'] as List)
          .map((json) => History.fromJson(json))
          .toList();
    } on DioException catch (e) {
      throw Exception('Network error: ${e.message}');
    }
  }
}
