import 'dart:async';
import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

class PassengerHomeController extends GetxController {
  // ── Search Field Controller ───────────────────────────────────────────────
  final searchController = TextEditingController();

  // ── Reactive State ────────────────────────────────────────────────────────
  final RxList<String> citySuggestions = <String>[].obs;
  final RxList<Map<String, dynamic>> discoveredDrivers = <Map<String, dynamic>>[].obs;
  final RxBool isSearching = false.obs;
  final RxBool hasSearched = false.obs;
  
  // Real-time greeting profile details
  final RxString passengerName = 'User'.obs;
  final RxString passengerPhotoUrl = ''.obs;

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  Timer? _debounce;

  @override
  void onInit() {
    super.onInit();
    // Listening to search text change for autocomplete predictions
    searchController.addListener(_onSearchChanged);
    fetchUserProfile();
  }

  Future<void> fetchUserProfile() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    try {
      final doc = await _firestore.collection('users').doc(user.uid).get();
      if (doc.exists) {
        final data = doc.data()!;
        passengerName.value = data['name'] ?? 'User';
        passengerPhotoUrl.value = data['profilePhotoUrl'] ?? '';
      }
    } catch (e) {
      debugPrint('Error fetching user profile: $e');
    }
  }

  void _onSearchChanged() {
    final String text = searchController.text;
    if (text.isEmpty) {
      citySuggestions.clear();
      return;
    }
    fetchCitySuggestions(text);
  }

  // ── Debounced Autocomplete search ─────────────────────────────────────────
  void fetchCitySuggestions(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () async {
      if (query.trim().isEmpty) {
        citySuggestions.clear();
        return;
      }
      await _fetchSuggestionsFromApi(query);
    });
  }

  Future<void> _fetchSuggestionsFromApi(String query) async {
    try {
      const String apiKey = String.fromEnvironment('GOOGLE_MAPS_API_KEY', defaultValue: '');
      if (apiKey.isEmpty) {
        _useLocalFallback(query);
        return;
      }

      final url = Uri.parse(
        'https://maps.googleapis.com/maps/api/place/autocomplete/json'
        '?input=${Uri.encodeComponent(query)}'
        '&types=(cities)'
        '&key=$apiKey'
      );

      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == 'OK') {
          final predictions = data['predictions'] as List<dynamic>;
          citySuggestions.assignAll(
            predictions.map((p) => p['description'] as String).toList(),
          );
        } else {
          _useLocalFallback(query);
        }
      } else {
        _useLocalFallback(query);
      }
    } catch (e) {
      _useLocalFallback(query);
    }
  }

  void _useLocalFallback(String query) {
    const allCities = [
      'Lahore, Punjab, Pakistan',
      'Karachi, Sindh, Pakistan',
      'Islamabad, Capital Territory, Pakistan',
      'Rawalpindi, Punjab, Pakistan',
      'Faisalabad, Punjab, Pakistan',
      'Multan, Punjab, Pakistan',
      'Peshawar, Khyber Pakhtunkhwa, Pakistan',
      'Quetta, Balochistan, Pakistan',
      'Sahiwal, Punjab, Pakistan',
      'Okara, Punjab, Pakistan',
      'Gujranwala, Punjab, Pakistan',
      'Sialkot, Punjab, Pakistan',
      'Sargodha, Punjab, Pakistan',
      'Bahawalpur, Punjab, Pakistan',
      'Sukkur, Sindh, Pakistan',
      'Jhang, Punjab, Pakistan',
      'Sheikhupura, Punjab, Pakistan',
      'Mardan, Khyber Pakhtunkhwa, Pakistan',
      'Gujrat, Punjab, Pakistan',
      'Hyderabad, Sindh, Pakistan'
    ];

    final matches = allCities
        .where((city) => city.toLowerCase().contains(query.toLowerCase()))
        .toList();
    citySuggestions.assignAll(matches);
  }

  // ── Autocomplete Dropdown Selection ────────────────────────────────────────
  void selectCity(String city) {
    searchController.removeListener(_onSearchChanged);
    searchController.text = city;
    searchController.addListener(_onSearchChanged);
    
    citySuggestions.clear();
    executeDriverDiscovery();
  }

  // ── Query drivers by base_adda_city ───────────────────────────────────────
  Future<void> executeDriverDiscovery() async {
    final String fullText = searchController.text.trim();
    if (fullText.isEmpty) {
      Get.snackbar(
        "Validation",
        "Please enter an Adda City name to find captains.",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.orangeAccent.withValues(alpha: 0.9),
        colorText: Colors.white,
      );
      return;
    }

    final String city = fullText.split(',').first.trim().toLowerCase();

    isSearching.value = true;
    hasSearched.value = true;
    discoveredDrivers.clear();

    try {
      // 1. Direct query checking `/drivers` where `base_adda_city` matches lowercase query
      var querySnapshot = await _firestore
          .collection('drivers')
          .where('base_adda_city', isEqualTo: city)
          .get();

      var docs = querySnapshot.docs;

      // 2. Client-side local filtering fallback
      if (docs.isEmpty) {
        final allDrivers = await _firestore.collection('drivers').get();
        docs = allDrivers.docs.where((doc) {
          final data = doc.data();
          final String? cityField = data['base_adda_city'] ?? data['addaCity'];
          if (cityField == null) return false;
          return cityField.trim().toLowerCase() == city;
        }).toList();
      }

      final List<Map<String, dynamic>> results = [];

      for (var doc in docs) {
        final driverData = doc.data();
        final String uid = doc.id;

        // Fetch driver profile info from users collection
        final userDoc = await _firestore.collection('users').doc(uid).get();
        final userData = userDoc.exists ? userDoc.data() : null;

        final String name = userData?['name'] ?? driverData['name'] ?? 'Captain';
        final String profilePhotoUrl = userData?['profilePhotoUrl'] ?? driverData['profilePhotoUrl'] ?? '';
        final double rating = (userData?['rating'] as num?)?.toDouble() ?? 
                             (driverData['averageRating'] as num?)?.toDouble() ?? 
                             5.0;
        final bool isVerified = userData?['isVerified'] ?? driverData['isVerified'] ?? false;

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
          'isVerified': isVerified,
          'carBrand': carBrand,
          'carModel': carModel,
          'isAc': isAc,
          'totalSeats': totalSeats,
        });
      }

      discoveredDrivers.assignAll(results);
    } catch (e) {
      Get.snackbar(
        "Discovery Error",
        "Failed to discover captains: $e",
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
    _debounce?.cancel();
    searchController.dispose();
    super.onClose();
  }
}
