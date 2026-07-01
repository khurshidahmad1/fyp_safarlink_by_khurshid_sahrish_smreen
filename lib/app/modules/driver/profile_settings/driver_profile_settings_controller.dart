import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../routes/app_routes.dart';

class DriverProfileSettingsController extends GetxController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // ── Reactive State ────────────────────────────────────────────────────────
  final RxString driverName = ''.obs;
  final RxString phoneNumber = ''.obs;
  final RxString profilePhotoUrl = ''.obs;
  final RxDouble rating = 5.0.obs;
  final RxBool isProfileLoading = true.obs;

  @override
  void onInit() {
    super.onInit();
    loadDriverProfile();
  }

  // ── Load Profile ──────────────────────────────────────────────────────────
  Future<void> loadDriverProfile() async {
    final user = _auth.currentUser;
    if (user == null) return;

    isProfileLoading.value = true;
    try {
      final doc = await _firestore.collection('users').doc(user.uid).get();
      if (doc.exists) {
        final data = doc.data()!;
        driverName.value = data['name'] ?? 'Captain';
        phoneNumber.value = data['phone'] ?? user.phoneNumber ?? 'Not Available';
        profilePhotoUrl.value = data['profilePhotoUrl'] ?? '';
        rating.value = (data['rating'] as num?)?.toDouble() ?? 5.0;
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to load profile details: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.redAccent.withValues(alpha: 0.9),
        colorText: Colors.white,
      );
    } finally {
      isProfileLoading.value = false;
    }
  }

  // ── Switch to Passenger Mode ──────────────────────────────────────────────
  void confirmSwitchRole() {
    Get.defaultDialog(
      title: '🔄 Switch Mode',
      titleStyle: const TextStyle(fontWeight: FontWeight.bold),
      middleText: 'Are you sure you want to switch to Passenger Mode?',
      textConfirm: 'Switch',
      textCancel: 'Cancel',
      confirmTextColor: Colors.white,
      buttonColor: const Color(0xFF003D45),
      onConfirm: () async {
        Get.back();
        await _switchToPassenger();
      },
    );
  }

  Future<void> _switchToPassenger() async {
    final user = _auth.currentUser;
    if (user == null) return;

    try {
      isProfileLoading.value = true;
      
      // Update the user's role to 'passenger' in Firestore
      await _firestore.collection('users').doc(user.uid).update({
        'role': 'passenger',
        'updatedAt': FieldValue.serverTimestamp(),
      });

      Get.snackbar(
        '🔄 Role Switched',
        'Switched to Passenger Mode successfully.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.teal.withValues(alpha: 0.9),
        colorText: Colors.white,
      );

      // Navigate to Passenger Home
      Get.offAllNamed(AppRoutes.PASSENGER_HOME);
    } catch (e) {
      Get.snackbar(
        'Switch Error',
        'Failed to switch mode: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.redAccent.withValues(alpha: 0.9),
        colorText: Colors.white,
      );
    } finally {
      isProfileLoading.value = false;
    }
  }

  // ── Logout ────────────────────────────────────────────────────────────────
  Future<void> logout() async {
    try {
      await _auth.signOut();
      Get.offAllNamed(AppRoutes.AUTH);
    } catch (e) {
      Get.snackbar(
        'Logout Error',
        'Failed to log out: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.redAccent.withValues(alpha: 0.9),
        colorText: Colors.white,
      );
    }
  }
}
