import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import '../../../routes/app_routes.dart';

class EditProfileController extends GetxController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final ImagePicker _picker = ImagePicker();

  // ── Text Controllers ──────────────────────────────────────────────────────
  final nameController = TextEditingController();
  final phoneController = TextEditingController();
  final addaCityController = TextEditingController();
  final emailController = TextEditingController();
  final cnicController = TextEditingController();
  final passwordController = TextEditingController(); // For delete re-auth

  // ── Reactive State ────────────────────────────────────────────────────────
  final RxString profilePhotoUrl = ''.obs;
  final RxBool hasDrivingLicense = false.obs;
  final RxBool isLoading = false.obs;
  final RxBool isUploading = false.obs;

  @override
  void onInit() {
    super.onInit();
    _loadProfileData();
  }

  // ── Load Current Data (Pre-populate text controllers) ─────────────────────
  Future<void> _loadProfileData() async {
    final user = _auth.currentUser;
    if (user == null) return;

    isLoading.value = true;
    try {
      // Fetch user data from /users/{uid}
      final userDoc = await _firestore.collection('users').doc(user.uid).get();
      if (userDoc.exists) {
        final data = userDoc.data()!;
        nameController.text = data['name'] ?? '';
        phoneController.text = data['phone'] ?? data['phoneNumber'] ?? user.phoneNumber ?? '';
        addaCityController.text = data['addaCity'] ?? '';
        profilePhotoUrl.value = data['profilePhotoUrl'] ?? '';
        emailController.text = data['email'] ?? user.email ?? '';
        cnicController.text = data['cnicNumber'] ?? '';
        hasDrivingLicense.value = data['hasDrivingLicense'] ?? false;
      }

      // Merge check from /drivers/{uid}
      final driverDoc = await _firestore.collection('drivers').doc(user.uid).get();
      if (driverDoc.exists) {
        final data = driverDoc.data()!;
        if (nameController.text.isEmpty) nameController.text = data['name'] ?? '';
        if (phoneController.text.isEmpty) phoneController.text = data['phone'] ?? data['phoneNumber'] ?? '';
        if (addaCityController.text.isEmpty) addaCityController.text = data['addaCity'] ?? '';
        if (profilePhotoUrl.value.isEmpty) profilePhotoUrl.value = data['profilePhotoUrl'] ?? '';
        if (emailController.text.isEmpty) emailController.text = data['email'] ?? '';
        if (cnicController.text.isEmpty) cnicController.text = data['cnicNumber'] ?? '';
        if (hasDrivingLicense.value == false) hasDrivingLicense.value = data['hasDrivingLicense'] ?? false;
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to load details: $e',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.redAccent.withValues(alpha: 0.9),
          colorText: Colors.white);
    } finally {
      isLoading.value = false;
    }
  }

  // ── Pick and Upload Profile Photo (Explicit whenComplete Task State Verification) ──
  Future<void> pickAndUploadImage() async {
    final user = _auth.currentUser;
    if (user == null) return;

    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 75,
        maxWidth: 500,
      );

      if (pickedFile == null) return;

      isUploading.value = true;
      Get.rawSnackbar(
        title: 'Uploading Image',
        message: 'Uploading your profile photo to Firebase Storage...',
        showProgressIndicator: true,
        duration: const Duration(seconds: 2),
      );

      String uid = FirebaseAuth.instance.currentUser!.uid;
      File localFile = File(pickedFile.path);

      if (!await localFile.exists()) {
        Get.snackbar("Error", "Selected file does not exist locally.");
        return;
      }

      // CRITICAL: Define the storage reference ONCE to eliminate any string interpolation or path typos
      final Reference profileImageRef = FirebaseStorage.instance
          .ref()
          .child('users')
          .child(uid)
          .child('profile.jpg');

      Get.log("Safarlink Log: Starting upload to path: ${profileImageRef.fullPath}");

      // Execute the upload task
      UploadTask uploadTask = profileImageRef.putFile(localFile);
      
      // Monitor the stream and wait for absolute completion
      TaskSnapshot snapshot = await uploadTask;

      if (snapshot.state == TaskState.success) {
        Get.log("Safarlink Log: Upload successful. Fetching URL from the EXACT same reference instance...");
        
        // Call getDownloadURL directly on the identical reference variable
        String downloadUrl = await profileImageRef.getDownloadURL();
        
        // Update the Cloud Firestore document mapping
        await FirebaseFirestore.instance.collection('users').doc(uid).update({
          'profilePhotoUrl': downloadUrl
        });

        // Mirror to drivers collection
        await FirebaseFirestore.instance.collection('drivers').doc(uid).update({
          'profilePhotoUrl': downloadUrl
        }).catchError((_) {});

        profilePhotoUrl.value = downloadUrl;
        Get.snackbar("Success", "Profile image updated successfully!");
      } else {
        Get.snackbar("Upload Failed", "Task snapshot state returned non-success.");
      }
    } on FirebaseException catch (storageError) {
      // Capture explicit cloud storage errors diagnostic logs
      Get.log("Safarlink Storage Error: [${storageError.code}] ${storageError.message}");
      Get.snackbar("Storage Error", "[${storageError.code}] ${storageError.message}");
    } catch (e) {
      Get.snackbar("General Error", e.toString());
    } finally {
      isUploading.value = false;
    }
  }

  // ── Save Profile Details ──────────────────────────────────────────────────
  Future<void> saveChanges() async {
    final user = _auth.currentUser;
    if (user == null) return;

    final String name = nameController.text.trim();
    final String phone = phoneController.text.trim();
    final String addaCity = addaCityController.text.trim();
    final String email = emailController.text.trim();
    final String cnic = cnicController.text.trim();

    if (name.isEmpty || phone.isEmpty || addaCity.isEmpty || email.isEmpty || cnic.isEmpty) {
      Get.snackbar('Validation', 'Please fill in all fields',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.orangeAccent.withValues(alpha: 0.9),
          colorText: Colors.white);
      return;
    }

    isLoading.value = true;
    try {
      final String uid = user.uid;

      // Transactional updates to user collection
      await _firestore.collection('users').doc(uid).update({
        'name': name,
        'phone': phone,
        'phoneNumber': phone,
        'addaCity': addaCity,
        'email': email,
        'cnicNumber': cnic,
        'hasDrivingLicense': hasDrivingLicense.value,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      // Mirror fields to /drivers collection
      await _firestore.collection('drivers').doc(uid).update({
        'name': name,
        'phone': phone,
        'phoneNumber': phone,
        'addaCity': addaCity,
        'email': email,
        'cnicNumber': cnic,
        'hasDrivingLicense': hasDrivingLicense.value,
        'updatedAt': FieldValue.serverTimestamp(),
      }).catchError((_) {});

      Get.snackbar('Success', 'Profile changes saved successfully!',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.teal.withValues(alpha: 0.9),
          colorText: Colors.white);

      Get.back();
    } catch (e) {
      Get.snackbar('Error', 'Failed to save changes: $e',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.redAccent.withValues(alpha: 0.9),
          colorText: Colors.white);
    } finally {
      isLoading.value = false;
    }
  }

  // ── Secure Delete Account (Requires fresh credentials) ────────────────────
  Future<void> deleteAccount(String currentPassword) async {
    final user = _auth.currentUser;
    if (user == null) return;

    if (currentPassword.isEmpty) {
      Get.snackbar('Error', 'Password is required to delete your account.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.redAccent.withValues(alpha: 0.9),
          colorText: Colors.white);
      return;
    }

    isLoading.value = true;
    try {
      final String emailAddress = user.email ?? emailController.text.trim();
      
      // Get auth credentials
      final AuthCredential credential = EmailAuthProvider.credential(
        email: emailAddress,
        password: currentPassword,
      );
      
      // Re-authenticate user securely
      await user.reauthenticateWithCredential(credential);
      
      final String uid = user.uid;

      // Clean up Firestore documents first to prevent orphan data records
      await _firestore.collection('drivers').doc(uid).delete();
      await _firestore.collection('users').doc(uid).delete();

      // Clean up associated file inside Storage bucket
      try {
        await _storage.ref().child('users/$uid/profile.jpg').delete();
      } catch (_) {}

      // Finally delete the authenticated user credentials from Firebase Auth
      await user.delete();

      // Navigate to landing/multi-auth screen
      Get.offAllNamed(AppRoutes.AUTH);

      Get.snackbar('Account Deleted', 'Your account has been deleted successfully.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.teal.withValues(alpha: 0.9),
          colorText: Colors.white);
    } catch (e) {
      Get.snackbar('Authentication Failure', 'Delete verification failed: $e',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.redAccent.withValues(alpha: 0.9),
          colorText: Colors.white);
    } finally {
      isLoading.value = false;
      passwordController.clear();
    }
  }

  @override
  void onClose() {
    nameController.dispose();
    phoneController.dispose();
    addaCityController.dispose();
    emailController.dispose();
    cnicController.dispose();
    passwordController.dispose();
    super.onClose();
  }
}
