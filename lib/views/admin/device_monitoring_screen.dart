import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:luna_iot/app/app_theme.dart';
import 'package:luna_iot/services/socket_service.dart';

class DeviceMonitoringScreen extends StatefulWidget {
  const DeviceMonitoringScreen({super.key});

  @override
  DeviceMonitoringScreenState createState() => DeviceMonitoringScreenState();
}

class DeviceMonitoringScreenState extends State<DeviceMonitoringScreen> {
  final SocketService _socketService = Get.find<SocketService>();
  final ScrollController _scrollController = ScrollController();
  bool autoScroll = true;

  @override
  void initState() {
    super.initState();
    ever(_socketService.deviceMonitoringMessages, (_) {
      if (autoScroll) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (_scrollController.hasClients) {
            _scrollController.animateTo(
              _scrollController.position.maxScrollExtent,
              duration: Duration(milliseconds: 300),
              curve: Curves.easeInOut,
            );
          }
        });
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Device Monitoring',
          style: TextStyle(color: AppTheme.titleColor, fontSize: 14),
        ),
        actions: [
          // Auto-scroll toggle button
          IconButton(
            onPressed: () {
              setState(() {
                autoScroll = !autoScroll;
              });
            },
            icon: Icon(
              autoScroll
                  ? Icons.vertical_align_bottom
                  : Icons.vertical_align_top,
              color: autoScroll ? AppTheme.primaryColor : AppTheme.titleColor,
            ),
            tooltip: autoScroll ? 'Disable Auto-scroll' : 'Enable Auto-scroll',
          ),

          // Refersh
          IconButton(
            onPressed: () {
              _socketService.clearMessages();
            },
            icon: Icon(Icons.refresh),
          ),

          // Socket Connection
          SizedBox(
            child: Obx(
              () => Icon(
                _socketService.isConnected.value ? Icons.wifi : Icons.wifi_off,
                color: _socketService.isConnected.value
                    ? AppTheme.primaryColor
                    : AppTheme.titleColor,
              ),
            ),
          ),

          SizedBox(width: 15),
        ],
      ),
      backgroundColor: Colors.black,
      body: Obx(
        () => ListView.builder(
          controller: _scrollController,
          padding: const EdgeInsets.all(10),
          itemCount: _socketService.deviceMonitoringMessages.length,
          itemBuilder: (context, index) {
            final message = _socketService.deviceMonitoringMessages[index];

            return Container(
              margin: EdgeInsets.only(bottom: 12),
              child: Text(
                message['message'] ?? '',
                style: TextStyle(fontSize: 15, color: AppTheme.primaryColor),
              ),
            );
          },
        ),
      ),
    );
  }
}
