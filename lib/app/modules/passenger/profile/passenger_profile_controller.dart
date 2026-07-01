import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../routes/app_routes.dart';

class PassengerProfileController extends GetxController {
  // ── Form Controllers ──────────────────────────────────────────────────────
  final nameController = TextEditingController();
  final cityController = TextEditingController();
  final phoneController = TextEditingController();
  final addressController = TextEditingController();

  final RxBool isLoading = false.obs;
  final RxBool isSaving = false.obs;
  final RxString profilePhotoUrl = ''.obs;

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  void onInit() {
    super.onInit();
    fetchUserProfile();
  }

  // ── Fetch Profile Details ──────────────────────────────────────────────────
  Future<void> fetchUserProfile() async {
    final user = _auth.currentUser;
    if (user == null) return;

    isLoading.value = true;
    try {
      final doc = await _firestore.collection('users').doc(user.uid).get();
      if (doc.exists) {
        final data = doc.data()!;
        nameController.text = data['name'] ?? '';
        cityController.text = data['baseCity'] ?? data['city'] ?? '';
        phoneController.text = data['phone'] ?? '';
        addressController.text = data['address'] ?? '';
        profilePhotoUrl.value = data['profilePhotoUrl'] ?? '';
      }
    } catch (e) {
      Get.snackbar("Error", "Failed to fetch profile: $e");
    } finally {
      isLoading.value = false;
    }
  }

  // ── Save/Update Profile ────────────────────────────────────────────────────
  Future<void> saveProfile() async {
    final user = _auth.currentUser;
    if (user == null) return;

    final String name = nameController.text.trim();
    final String city = cityController.text.trim();
    final String phone = phoneController.text.trim();
    final String address = addressController.text.trim();

    if (name.isEmpty) {
      Get.snackbar("Validation", "Name cannot be empty.");
      return;
    }

    isSaving.value = true;
    try {
      await _firestore.collection('users').doc(user.uid).set({
        'name': name,
        'baseCity': city,
        'phone': phone,
        'address': address,
        'profilePhotoUrl': profilePhotoUrl.value,
        'role': 'passenger',
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      Get.snackbar(
        "Success 🎉",
        "Profile saved successfully!",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.teal.withValues(alpha: 0.9),
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar("Save Error", "Failed to save details: $e");
    } finally {
      isSaving.value = false;
    }
  }

  // ── Logout ────────────────────────────────────────────────────────────────
  Future<void> logoutUser() async {
    try {
      await _auth.signOut();
      
      Get.offAllNamed(AppRoutes.AUTH);
      
      Get.snackbar(
        "Logged Out",
        "You have been safely logged out of your passenger session.",
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.redAccent.withValues(alpha: 0.2),
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar("Logout Error", e.toString());
    }
  }

  @override
  void onClose() {
    nameController.dispose();
    cityController.dispose();
    phoneController.dispose();
    addressController.dispose();
    super.onClose();
  }
}
