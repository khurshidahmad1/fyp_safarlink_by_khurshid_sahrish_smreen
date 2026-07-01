import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../routes/app_routes.dart';

class CarRegistrationController extends GetxController {
  final brandController = TextEditingController();
  final modelController = TextEditingController();
  final seatsController = TextEditingController();
  final addaController = TextEditingController();
  final mileageController = TextEditingController();
  final fuelPriceController = TextEditingController();
  final profitMarginController = TextEditingController();

  final RxBool isAc = false.obs;
  final RxBool isLoading = false.obs;

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void onClose() {
    brandController.dispose();
    modelController.dispose();
    seatsController.dispose();
    addaController.dispose();
    mileageController.dispose();
    fuelPriceController.dispose();
    profitMarginController.dispose();
    super.onClose();
  }

  Future<void> submitRegistration() async {
    final brand = brandController.text.trim();
    final model = modelController.text.trim();
    final seats = seatsController.text.trim();
    final adda = addaController.text.trim();
    final mileage = mileageController.text.trim();
    final fuelPrice = fuelPriceController.text.trim();
    final profitMargin = profitMarginController.text.trim();

    if (brand.isEmpty || model.isEmpty || seats.isEmpty || adda.isEmpty ||
        mileage.isEmpty || fuelPrice.isEmpty || profitMargin.isEmpty) {
      Get.snackbar(
        'Error',
        'Please fill all fields',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.redAccent.withValues(alpha: 0.8),
        colorText: Colors.white,
      );
      return;
    }

    final User? user = _auth.currentUser;
    if (user == null) {
      Get.snackbar(
        'Error',
        'No user logged in',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    isLoading.value = true;
    try {
      final carData = {
        'brand': brand,
        'model': model,
        'seats': int.tryParse(seats) ?? 4,
        'isAc': isAc.value,
        'addaCity': adda,
        'mileage': double.tryParse(mileage) ?? 10.0,
        'fuelPrice': double.tryParse(fuelPrice) ?? 270.0,
        'profitMargin': double.tryParse(profitMargin) ?? 10.0,
      };

      await _firestore.collection('users').doc(user.uid).update({
        'carDetails': carData,
        'addaCity': adda,
      });

      Get.snackbar(
        'Success',
        'Car registered successfully',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.teal.withValues(alpha: 0.8),
        colorText: Colors.white,
      );
      Get.offAllNamed(AppRoutes.DRIVER_DASHBOARD);
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to register car: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }
}
