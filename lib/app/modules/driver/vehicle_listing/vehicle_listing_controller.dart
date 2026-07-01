import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';
import '../../../data/models/vehicle_model.dart';
import '../../../routes/app_routes.dart';

class VehicleListingController extends GetxController {
  // ── Text Controllers ──────────────────────────────────────────────────────
  final brandController = TextEditingController();
  final makeController = TextEditingController();
  final modelController = TextEditingController(); // year/model
  final variantController = TextEditingController();
  final seatsController = TextEditingController();
  final mileageController = TextEditingController();
  final fuelPriceController = TextEditingController();
  final profitMarginController = TextEditingController();

  // ── Reactive State ────────────────────────────────────────────────────────
  final RxList<File> selectedImages = <File>[].obs;
  final RxList<String> selectedPhotos = <String>[].obs;
  final RxBool isAc = false.obs;
  final RxBool isLoading = false.obs;
  final RxString uploadStatus = ''.obs;
  final RxDouble uploadProgress = 0.0.obs;

  // ── Firebase ──────────────────────────────────────────────────────────────
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final ImagePicker _picker = ImagePicker();

  static const int maxPhotos = 8;
  static const int minPhotos = 1;

  // ── Image Picking ─────────────────────────────────────────────────────────
  Future<void> pickCarImages() async {
    final remaining = maxPhotos - selectedImages.length;
    if (remaining <= 0) {
      Get.snackbar('Limit Reached', 'Maximum $maxPhotos photos allowed',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.orangeAccent.withValues(alpha: 0.9),
          colorText: Colors.white);
      return;
    }

    final List<XFile> files = await _picker.pickMultiImage(
      imageQuality: 80,
      maxWidth: 1200,
    );

    if (files.isNotEmpty) {
      final toAdd = files.take(remaining).toList();
      selectedImages.addAll(toAdd.map((f) => File(f.path)));
    }
  }

  void removeImage(int index) {
    if (index >= 0 && index < selectedImages.length) {
      selectedImages.removeAt(index);
    }
  }

  void reorderImages(int oldIndex, int newIndex) {
    if (newIndex > oldIndex) newIndex -= 1;
    final item = selectedImages.removeAt(oldIndex);
    selectedImages.insert(newIndex, item);
  }

  // ── Validation ────────────────────────────────────────────────────────────
  bool _validate() {
    if (selectedImages.isEmpty) {
      Get.snackbar('Validation', 'Please add at least 1 car photo',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.redAccent.withValues(alpha: 0.9),
          colorText: Colors.white);
      return false;
    }
    if (brandController.text.trim().isEmpty) {
      Get.snackbar('Validation', 'Please enter the car brand',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.redAccent.withValues(alpha: 0.9),
          colorText: Colors.white);
      return false;
    }
    if (makeController.text.trim().isEmpty) {
      Get.snackbar('Validation', 'Please enter the car make',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.redAccent.withValues(alpha: 0.9),
          colorText: Colors.white);
      return false;
    }
    if (modelController.text.trim().isEmpty) {
      Get.snackbar('Validation', 'Please enter the car model/year',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.redAccent.withValues(alpha: 0.9),
          colorText: Colors.white);
      return false;
    }
    if (seatsController.text.trim().isEmpty) {
      Get.snackbar('Validation', 'Please enter the number of seats',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.redAccent.withValues(alpha: 0.9),
          colorText: Colors.white);
      return false;
    }

    // Validate numeric fields parse correctly
    if (int.tryParse(seatsController.text.trim()) == null) {
      Get.snackbar('Validation', 'Total seats must be a valid number',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.redAccent.withValues(alpha: 0.9),
          colorText: Colors.white);
      return false;
    }

    if (mileageController.text.trim().isEmpty ||
        fuelPriceController.text.trim().isEmpty ||
        profitMarginController.text.trim().isEmpty) {
      Get.snackbar('Validation', 'Please fill all fare engine fields',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.redAccent.withValues(alpha: 0.9),
          colorText: Colors.white);
      return false;
    }

    if (double.tryParse(mileageController.text.trim()) == null) {
      Get.snackbar('Validation', 'Mileage must be a valid number',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.redAccent.withValues(alpha: 0.9),
          colorText: Colors.white);
      return false;
    }

    if (double.tryParse(fuelPriceController.text.trim()) == null) {
      Get.snackbar('Validation', 'Fuel price must be a valid number',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.redAccent.withValues(alpha: 0.9),
          colorText: Colors.white);
      return false;
    }

    if (double.tryParse(profitMarginController.text.trim()) == null) {
      Get.snackbar('Validation', 'Profit margin must be a valid number',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.redAccent.withValues(alpha: 0.9),
          colorText: Colors.white);
      return false;
    }

    return true;
  }

  // ── Placeholder image used when a storage upload fails ──────────────────
  static const String _placeholderCarPhoto =
      'https://firebasestorage.googleapis.com/v0/b/placeholder/o/default_car.png?alt=media';

  // ── Submit Vehicle Data (SRS /drivers/{uid} schema) ───────────────────────
  /// Writes driver fare/vehicle data to the `/drivers/{uid}` document
  /// and vehicle details to the `/drivers/{uid}/vehicles/{vehicleId}`
  /// sub-collection, matching the SRS database schema.
  Future<void> submitVehicleData() async {
    if (!_validate()) return;

    // ── 0. Early-exit: empty photo guard ────────────────────────────────
    if (selectedImages.isEmpty) {
      Get.snackbar(
        'Error',
        'Please select at least 1 car photo to register your vehicle.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.redAccent.withValues(alpha: 0.9),
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
      );
      return;
    }

    final user = _auth.currentUser;
    if (user == null) {
      Get.snackbar('Error', 'No authenticated user found',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.redAccent.withValues(alpha: 0.9),
          colorText: Colors.white);
      return;
    }

    isLoading.value = true;
    uploadStatus.value = 'Preparing vehicle data...';

    try {
      final String uid = user.uid;
      final String vehicleId = const Uuid().v4();

      // ── 1. Upload car photos to Firebase Storage (defensive) ──────────
      final List<String> photoUrls = [];

      for (int i = 0; i < selectedImages.length; i++) {
        final File imageFile = selectedImages[i];

        // Pre-flight: verify the local file still exists on disk
        if (!imageFile.existsSync()) {
          debugPrint(
              '[VehicleUpload] Skipping photo $i — file does not exist: '
              '${imageFile.path}');
          photoUrls.add(_placeholderCarPhoto);
          uploadProgress.value = (i + 1) / selectedImages.length;
          continue;
        }

        // Per-file upload with dedicated FirebaseException catch
        try {
          uploadStatus.value =
              'Uploading photo ${i + 1} of ${selectedImages.length}...';
          final ref = _storage
              .ref()
              .child('drivers/$uid/vehicles/$vehicleId/photo_$i.jpg');
          final task = await ref.putFile(imageFile);
          final String url = await task.ref.getDownloadURL();
          photoUrls.add(url);
        } on FirebaseException catch (e) {
          // Gracefully handle storage errors (object-not-found, etc.)
          debugPrint(
              '[VehicleUpload] FirebaseException on photo $i '
              '(code: ${e.code}): ${e.message}');
          photoUrls.add(_placeholderCarPhoto);
        } catch (e) {
          // Catch any other unexpected per-file error
          debugPrint(
              '[VehicleUpload] Unexpected error on photo $i: $e');
          photoUrls.add(_placeholderCarPhoto);
        }

        uploadProgress.value = (i + 1) / selectedImages.length;
      }

      // Sync photo URLs into the reactive string list
      selectedPhotos.assignAll(photoUrls);

      uploadStatus.value = 'Saving driver data...';

      // ── 2. Parse numeric fields with type safety ──────────────────────
      final double mileage = double.parse(mileageController.text.trim());
      final double fuelPrice = double.parse(fuelPriceController.text.trim());
      final double profitMargin =
          double.parse(profitMarginController.text.trim());
      final int totalSeats = int.parse(seatsController.text.trim());

      // ── 3. Write/Update the /drivers/{uid} document ───────────────────
      //    Contains fare engine fields + onboarding metadata
      await _firestore.collection('drivers').doc(uid).set({
        'mileage': mileage,
        'fuelPrice': fuelPrice,
        'profitMargin': profitMargin,
        'calendarBlockedDates': <String>[],
        'averageRating': 5.0,
        'isVehicleRegistered': true,
        'primaryVehicleId': vehicleId,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      // ── 4. Save vehicle details to sub-collection ─────────────────────
      //    /drivers/{uid}/vehicles/{vehicleId}
      await _firestore
          .collection('drivers')
          .doc(uid)
          .collection('vehicles')
          .doc(vehicleId)
          .set({
        'vehicleId': vehicleId,
        'brand': brandController.text.trim(),
        'make': makeController.text.trim(),
        'model': modelController.text.trim(),
        'variant': variantController.text.trim(),
        'isAc': isAc.value,
        'totalSeats': totalSeats,
        'carPhotos': selectedPhotos.toList(),
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      // ── 5. Also mirror to /users/{uid} for backward compatibility ─────
      final vehicle = VehicleModel(
        vehicleId: vehicleId,
        brand: brandController.text.trim(),
        make: makeController.text.trim(),
        model: modelController.text.trim(),
        variant: variantController.text.trim(),
        isAc: isAc.value,
        totalSeats: totalSeats,
        carPhotos: photoUrls,
        mileageKmPerLitre: mileage,
        fuelPrice: fuelPrice,
        profitMarginPercentage: profitMargin,
      );

      await _firestore
          .collection('users')
          .doc(uid)
          .collection('vehicles')
          .doc(vehicleId)
          .set(vehicle.toMap(uid));

      await _firestore.collection('users').doc(uid).update({
        'hasVehicle': true,
        'primaryVehicleId': vehicleId,
        'primaryVehicle': vehicle.toPublicMap(uid),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      // ── 6. Success feedback & navigate to dashboard ───────────────────
      Get.snackbar(
        '🚗 Vehicle Registered!',
        'Your vehicle is now live. Start accepting rides!',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.teal.withValues(alpha: 0.9),
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
      );

      await Future.delayed(const Duration(milliseconds: 500));
      Get.offAllNamed(AppRoutes.DRIVER_DASHBOARD);
    } on FormatException catch (e) {
      Get.snackbar(
        'Invalid Input',
        'Please check your numeric values: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.redAccent.withValues(alpha: 0.9),
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to save vehicle: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.redAccent.withValues(alpha: 0.9),
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
      uploadStatus.value = '';
      uploadProgress.value = 0.0;
    }
  }

  // ── Save Vehicle (legacy /users path) ─────────────────────────────────────
  Future<void> saveVehicle() async {
    // Delegate to the new unified method that writes to both paths
    await submitVehicleData();
  }

  @override
  void onClose() {
    brandController.dispose();
    makeController.dispose();
    modelController.dispose();
    variantController.dispose();
    seatsController.dispose();
    mileageController.dispose();
    fuelPriceController.dispose();
    profitMarginController.dispose();
    super.onClose();
  }
}
