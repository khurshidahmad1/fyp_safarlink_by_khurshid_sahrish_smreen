import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class PassengerDashboardController extends GetxController {
  // ── Text Controllers & State ──────────────────────────────────────────────
  final searchController = TextEditingController();
  final RxList<Map<String, dynamic>> discoveredDrivers = <Map<String, dynamic>>[].obs;
  final RxBool isSearching = false.obs;
  final RxBool hasSearched = false.obs;

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // ── Query drivers by base_adda_city ───────────────────────────────────────
  Future<void> searchDrivers(String city) async {
    final String queryCity = city.trim();
    if (queryCity.isEmpty) {
      Get.snackbar(
        "Validation",
        "Please enter a city name to search.",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.orangeAccent.withValues(alpha: 0.9),
        colorText: Colors.white,
      );
      return;
    }

    isSearching.value = true;
    hasSearched.value = true;
    discoveredDrivers.clear();

    try {
      // 1. Direct equality check on base_adda_city in lowercase
      var querySnapshot = await _firestore
          .collection('drivers')
          .where('base_adda_city', isEqualTo: queryCity.toLowerCase())
          .get();

      var docs = querySnapshot.docs;

      // 2. Local fallback check to support varying casing or legacy field schemes
      if (docs.isEmpty) {
        final allDrivers = await _firestore.collection('drivers').get();
        docs = allDrivers.docs.where((doc) {
          final data = doc.data();
          final String? cityField = data['base_adda_city'] ?? data['addaCity'];
          if (cityField == null) return false;
          return cityField.trim().toLowerCase() == queryCity.toLowerCase();
        }).toList();
      }

      final List<Map<String, dynamic>> results = [];

      for (var doc in docs) {
        final driverData = doc.data();
        final String uid = doc.id;

        // Fetch driver's public user details (name, profilePhotoUrl, rating)
        final userDoc = await _firestore.collection('users').doc(uid).get();
        final userData = userDoc.exists ? userDoc.data() : null;

        final String name = userData?['name'] ?? driverData['name'] ?? 'Captain';
        final String profilePhotoUrl = userData?['profilePhotoUrl'] ?? driverData['profilePhotoUrl'] ?? '';
        final double rating = (userData?['rating'] as num?)?.toDouble() ?? 
                             (driverData['averageRating'] as num?)?.toDouble() ?? 
                             5.0;

        // Fetch primary vehicle details
        Map<String, dynamic>? vehicleData;
        final String? primaryVehicleId = driverData['primaryVehicleId'] ?? userData?['primaryVehicleId'];
        
        if (primaryVehicleId != null) {
          final vehicleDoc = await _firestore
              .collection('drivers')
              .doc(uid)
              .collection('vehicles')
              .doc(primaryVehicleId)
              .get();
          if (vehicleDoc.exists) {
            vehicleData = vehicleDoc.data();
          } else if (userData?['primaryVehicle'] != null) {
            vehicleData = Map<String, dynamic>.from(userData!['primaryVehicle']);
          }
        }

        final String carBrand = vehicleData?['brand'] ?? 'Car';
        final String carModel = vehicleData?['model'] ?? '';
        final bool isAc = vehicleData?['isAc'] ?? false;
        final int totalSeats = (vehicleData?['totalSeats'] as num?)?.toInt() ?? 4;

        results.add({
          'driverId': uid,
          'name': name,
          'profilePhotoUrl': profilePhotoUrl,
          'rating': rating,
          'carBrand': carBrand,
          'carModel': carModel,
          'isAc': isAc,
          'totalSeats': totalSeats,
        });
      }

      discoveredDrivers.assignAll(results);
    } catch (e) {
      Get.snackbar(
        "Search Error",
        "Failed to query captains: $e",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.redAccent.withValues(alpha: 0.9),
        colorText: Colors.white,
      );
    } finally {
      isSearching.value = false;
    }
  }

  @override
  void onClose() {
    searchController.dispose();
    super.onClose();
  }
}
