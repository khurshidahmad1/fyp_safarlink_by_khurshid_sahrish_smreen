import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';

/// Reactive runtime permission service for Safarlink.
/// Registered as a GetxService in main.dart and invoked at splash launch.
class PermissionService extends GetxService {

  /// Sequentially requests Location, Camera, and Notification permissions
  /// via native OS dialogue popups. Shows contextual feedback on denial.
  Future<void> requestAppPermissions() async {
    Map<Permission, PermissionStatus> statuses = await [
      Permission.locationWhenInUse,
      Permission.camera,
      Permission.notification,
    ].request();

    // Contextual denial feedback
    if (statuses[Permission.locationWhenInUse]?.isDenied ?? false) {
      Get.snackbar(
        "Location Needed 📍",
        "Safarlink requires location access to auto-calculate route distances.",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.orangeAccent,
        colorText: Colors.white,
        duration: const Duration(seconds: 4),
      );
    }

    if (statuses[Permission.camera]?.isDenied ?? false) {
      Get.snackbar(
        "Camera Access 📷",
        "Camera permission is required for profile photo uploads.",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.orangeAccent,
        colorText: Colors.white,
        duration: const Duration(seconds: 4),
      );
    }
  }
}
