import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../data/models/vehicle_model.dart';

class MyVehiclesListController extends GetxController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // ── Reactive State ────────────────────────────────────────────────────────
  final RxList<VehicleModel> vehicles = <VehicleModel>[].obs;
  final RxBool isLoading = true.obs;

  StreamSubscription<QuerySnapshot>? _vehiclesSubscription;

  @override
  void onInit() {
    super.onInit();
    _startVehiclesStream();
  }

  // ── Real-time Vehicles Stream ──────────────────────────────────────────────
  void _startVehiclesStream() {
    final user = _auth.currentUser;
    if (user == null) {
      isLoading.value = false;
      return;
    }

    isLoading.value = true;
    _vehiclesSubscription = _firestore
        .collection('users')
        .doc(user.uid)
        .collection('vehicles')
        .snapshots()
        .listen(
      (snapshot) {
        vehicles.assignAll(
          snapshot.docs.map((doc) => VehicleModel.fromDoc(doc)).toList(),
        );
        isLoading.value = false;
      },
      onError: (error) {
        isLoading.value = false;
        Get.snackbar(
          'Error',
          'Failed to load vehicle list: $error',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.redAccent.withValues(alpha: 0.9),
          colorText: Colors.white,
        );
      },
    );
  }

  // ── Delete Vehicle ────────────────────────────────────────────────────────
  Future<void> deleteVehicle(String vehicleId) async {
    final user = _auth.currentUser;
    if (user == null) return;

    Get.defaultDialog(
      title: '🗑️ Delete Vehicle',
      titleStyle: const TextStyle(fontWeight: FontWeight.bold),
      middleText: 'Are you sure you want to delete this vehicle from your fleet?',
      textConfirm: 'Delete',
      textCancel: 'Cancel',
      confirmTextColor: Colors.white,
      buttonColor: Colors.redAccent,
      onConfirm: () async {
        Get.back();
        await _performDeletion(user.uid, vehicleId);
      },
    );
  }

  Future<void> _performDeletion(String uid, String vehicleId) async {
    try {
      isLoading.value = true;

      // 1. Delete from users/{uid}/vehicles/{vehicleId}
      await _firestore
          .collection('users')
          .doc(uid)
          .collection('vehicles')
          .doc(vehicleId)
          .delete();

      // 2. Delete from drivers/{uid}/vehicles/{vehicleId}
      await _firestore
          .collection('drivers')
          .doc(uid)
          .collection('vehicles')
          .doc(vehicleId)
          .delete()
          .catchError((_) => null);

      // Check if deleted vehicle was primary
      final userDoc = await _firestore.collection('users').doc(uid).get();
      if (userDoc.exists && userDoc.data()?['primaryVehicleId'] == vehicleId) {
        // Clear primary vehicle fields
        await _firestore.collection('users').doc(uid).update({
          'hasVehicle': false,
          'primaryVehicleId': FieldValue.delete(),
          'primaryVehicle': FieldValue.delete(),
        });
        await _firestore.collection('drivers').doc(uid).update({
          'isVehicleRegistered': false,
          'primaryVehicleId': FieldValue.delete(),
        }).catchError((_) => null);
      }

      Get.snackbar(
        'Success',
        'Vehicle deleted successfully.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.teal.withValues(alpha: 0.9),
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar(
        'Deletion Error',
        'Failed to delete vehicle: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.redAccent.withValues(alpha: 0.9),
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // ── Update Vehicle Details (Full Sheet / Dialog) ──────────────────────────
  Future<void> updateVehicleDetails(String vehicleId, VehicleModel updatedVehicle) async {
    final user = _auth.currentUser;
    if (user == null) return;

    try {
      isLoading.value = true;

      final uid = user.uid;

      // 1. Update /users/{uid}/vehicles/{vehicleId}
      await _firestore
          .collection('users')
          .doc(uid)
          .collection('vehicles')
          .doc(vehicleId)
          .set(updatedVehicle.toMap(uid), SetOptions(merge: true));

      // 2. Update /drivers/{uid}/vehicles/{vehicleId}
      await _firestore
          .collection('drivers')
          .doc(uid)
          .collection('vehicles')
          .doc(vehicleId)
          .set({
        'vehicleId': vehicleId,
        'brand': updatedVehicle.brand,
        'make': updatedVehicle.make,
        'model': updatedVehicle.model,
        'variant': updatedVehicle.variant,
        'isAc': updatedVehicle.isAc,
        'totalSeats': updatedVehicle.totalSeats,
        'carPhotos': updatedVehicle.carPhotos,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true)).catchError((_) => null);

      // Check if we need to update the primaryVehicle mirror
      final userDoc = await _firestore.collection('users').doc(uid).get();
      if (userDoc.exists && userDoc.data()?['primaryVehicleId'] == vehicleId) {
        await _firestore.collection('users').doc(uid).update({
          'primaryVehicle': updatedVehicle.toPublicMap(uid),
        });
      }

      Get.snackbar(
        'Success',
        'Vehicle specs updated successfully!',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.teal.withValues(alpha: 0.9),
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to update vehicle details: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.redAccent.withValues(alpha: 0.9),
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void onClose() {
    _vehiclesSubscription?.cancel();
    super.onClose();
  }
}
