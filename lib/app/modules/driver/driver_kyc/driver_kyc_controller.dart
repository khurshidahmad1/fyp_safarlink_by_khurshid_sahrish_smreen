import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import '../../../data/models/driver_model.dart';
import '../../../routes/app_routes.dart';

class DriverKycController extends GetxController {
  // ── Text Controllers ──────────────────────────────────────────────────────
  final nameController = TextEditingController();
  final cnicController = TextEditingController();
  final phoneController = TextEditingController();
  final addaCityController = TextEditingController();

  // ── Reactive State ────────────────────────────────────────────────────────
  final Rx<File?> profilePhoto = Rx<File?>(null);
  final Rx<File?> cnicPhoto = Rx<File?>(null);
  final Rx<File?> licensePhoto = Rx<File?>(null);
  final RxBool hasDrivingLicense = false.obs;
  final RxBool isLoading = false.obs;
  final RxString uploadStatus = ''.obs;

  // ── Firebase ──────────────────────────────────────────────────────────────
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final ImagePicker _picker = ImagePicker();

  @override
  void onInit() {
    super.onInit();
    _prefillPhone();
  }

  void _prefillPhone() {
    final user = _auth.currentUser;
    if (user?.phoneNumber != null) {
      phoneController.text = user!.phoneNumber!;
    }
    if (user?.displayName != null) {
      nameController.text = user!.displayName!;
    }
  }

  // ── Image Picking ─────────────────────────────────────────────────────────
  Future<void> pickProfilePhoto() async {
    final XFile? file = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
      maxWidth: 800,
    );
    if (file != null) profilePhoto.value = File(file.path);
  }

  Future<void> pickCnicPhoto() async {
    final XFile? file = await _picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 90,
      maxWidth: 1200,
    );
    if (file != null) cnicPhoto.value = File(file.path);
  }

  Future<void> pickLicensePhoto() async {
    final XFile? file = await _picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 90,
      maxWidth: 1200,
    );
    if (file != null) licensePhoto.value = File(file.path);
  }

  // ── Upload Helper ─────────────────────────────────────────────────────────
  Future<String?> _uploadFile(File file, String path) async {
    try {
      final ref = _storage.ref().child(path);
      final task = await ref.putFile(file);
      return await task.ref.getDownloadURL();
    } catch (e) {
      debugPrint('Upload error: $e');
      return null;
    }
  }

  // ── Validation ────────────────────────────────────────────────────────────
  bool _validate() {
    if (nameController.text.trim().isEmpty) {
      Get.snackbar('Validation', 'Please enter your full name',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.redAccent.withValues(alpha: 0.9),
          colorText: Colors.white);
      return false;
    }
    if (cnicController.text.trim().length < 13) {
      Get.snackbar('Validation', 'Enter a valid CNIC (13 digits)',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.redAccent.withValues(alpha: 0.9),
          colorText: Colors.white);
      return false;
    }
    if (addaCityController.text.trim().isEmpty) {
      Get.snackbar('Validation', 'Please enter your Adda city',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.redAccent.withValues(alpha: 0.9),
          colorText: Colors.white);
      return false;
    }
    if (profilePhoto.value == null) {
      Get.snackbar('Validation', 'Please upload your profile photo',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.redAccent.withValues(alpha: 0.9),
          colorText: Colors.white);
      return false;
    }
    if (cnicPhoto.value == null) {
      Get.snackbar('Validation', 'Please upload your CNIC photo',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.redAccent.withValues(alpha: 0.9),
          colorText: Colors.white);
      return false;
    }
    return true;
  }

  // ── Submit KYC ────────────────────────────────────────────────────────────
  Future<void> submitKyc() async {
    if (!_validate()) return;

    final user = _auth.currentUser;
    if (user == null) {
      Get.snackbar('Error', 'No authenticated user found');
      return;
    }

    isLoading.value = true;
    try {
      final uid = user.uid;

      // Upload profile photo
      uploadStatus.value = 'Uploading profile photo...';
      final profileUrl = await _uploadFile(
        profilePhoto.value!,
        'drivers/$uid/profile_photo.jpg',
      );

      // Upload CNIC photo (private)
      uploadStatus.value = 'Uploading CNIC...';
      final cnicUrl = await _uploadFile(
        cnicPhoto.value!,
        'drivers/$uid/private/cnic_photo.jpg',
      );

      // Upload license photo if provided
      String? licenseUrl;
      if (licensePhoto.value != null && hasDrivingLicense.value) {
        uploadStatus.value = 'Uploading license...';
        licenseUrl = await _uploadFile(
          licensePhoto.value!,
          'drivers/$uid/private/license_photo.jpg',
        );
      }

      uploadStatus.value = 'Saving your profile...';

      final driver = DriverModel(
        uid: uid,
        name: nameController.text.trim(),
        profilePhotoUrl: profileUrl ?? '',
        phoneNumber: phoneController.text.trim(),
        addaCity: addaCityController.text.trim(),
        rating: 0.0,
        email: user.email,
        cnicNumber: cnicController.text.trim(),
        cnicPhotoUrl: cnicUrl,
        hasDrivingLicense: hasDrivingLicense.value,
        licensePhotoUrl: licenseUrl,
        kycComplete: true,
      );

      // Save PUBLIC data to /users/{uid}
      await _firestore
          .collection('users')
          .doc(uid)
          .set(driver.toPublicMap(), SetOptions(merge: true));

      // Save PRIVATE data to /users/{uid}/private/profile
      await _firestore
          .collection('users')
          .doc(uid)
          .collection('private')
          .doc('profile')
          .set(driver.toPrivateMap(), SetOptions(merge: true));

      Get.snackbar(
        '✅ KYC Complete',
        'Your profile has been verified. Let\'s register your vehicle!',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.teal.withValues(alpha: 0.9),
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
      );

      await Future.delayed(const Duration(milliseconds: 500));
      Get.offAllNamed(AppRoutes.VEHICLE_LISTING);
    } catch (e) {
      Get.snackbar(
        'Error',
        'KYC submission failed: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.redAccent.withValues(alpha: 0.9),
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
      uploadStatus.value = '';
    }
  }

  @override
  void onClose() {
    nameController.dispose();
    cnicController.dispose();
    phoneController.dispose();
    addaCityController.dispose();
    super.onClose();
  }
}
