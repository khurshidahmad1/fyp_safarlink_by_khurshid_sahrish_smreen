import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import '../../../services/fcm_helper.dart';

class PassengerBookingSetupController extends GetxController {
  // ── Route Arguments ───────────────────────────────────────────────────────
  late final String driverId;

  // ── Reactive Driver Metrics (Confidential) ────────────────────────────────
  final RxDouble driverMileage = 0.0.obs;
  final RxDouble driverFuelPrice = 0.0.obs;
  final RxDouble driverMargin = 0.0.obs;

  // ── Calculated Fare & Distance ────────────────────────────────────────────
  final RxInt totalCalculatedFare = 0.obs;
  final RxDouble routeDistanceKm = 0.0.obs;
  final RxDouble fuelExpenses = 0.0.obs;
  final RxDouble netProfit = 0.0.obs;
  final RxBool isCalculatingFare = false.obs;
  final RxBool isSubmitting = false.obs;
  final RxBool isRoundTrip = false.obs;

  // ── Driver Info ──────────────────────────────────────────────────────────
  final RxString driverName = 'Captain'.obs;
  final RxString carModelText = 'Car'.obs;

  // ── Route Form Fields & Date ──────────────────────────────────────────────
  final departureController = TextEditingController();
  final destinationController = TextEditingController();
  final Rx<DateTime> selectedDate = DateTime.now().obs;

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // ── Pre-defined Coordinates for Pakistani Cities (OSRM source) ─────────────
  static const Map<String, Map<String, double>> cityCoordinates = {
    'Lahore': {'lat': 31.5204, 'lng': 74.3587},
    'Karachi': {'lat': 24.8607, 'lng': 67.0011},
    'Islamabad': {'lat': 33.6844, 'lng': 73.0479},
    'Rawalpindi': {'lat': 33.5984, 'lng': 73.0441},
    'Faisalabad': {'lat': 31.4504, 'lng': 73.1350},
    'Multan': {'lat': 30.1575, 'lng': 71.5249},
    'Peshawar': {'lat': 34.0151, 'lng': 71.5249},
    'Quetta': {'lat': 30.1798, 'lng': 66.9750},
    'Sahiwal': {'lat': 30.6682, 'lng': 73.1114},
    'Okara': {'lat': 30.8014, 'lng': 73.4489},
    'Gujranwala': {'lat': 32.1877, 'lng': 74.1945},
    'Sialkot': {'lat': 32.4945, 'lng': 74.5229},
    'Sargodha': {'lat': 32.0836, 'lng': 72.6711},
    'Bahawalpur': {'lat': 29.3544, 'lng': 71.6911},
    'Sukkur': {'lat': 27.7244, 'lng': 68.8475},
    'Jhang': {'lat': 31.2781, 'lng': 72.3317},
    'Sheikhupura': {'lat': 31.7131, 'lng': 73.9783},
    'Mardan': {'lat': 34.1989, 'lng': 72.0404},
    'Gujrat': {'lat': 32.5742, 'lng': 74.0754},
    'Hyderabad': {'lat': 25.3960, 'lng': 68.3772},
  };

  @override
  void onInit() {
    super.onInit();
    driverId = Get.arguments['driverId'] ?? Get.arguments['driverUid'] ?? '';
    fetchDriverMetrics();
  }

  // ── Pull driver parameters from Firestore ─────────────────────────────────
  Future<void> fetchDriverMetrics() async {
    if (driverId.isEmpty) {
      Get.snackbar("Error", "No driver ID specified.");
      return;
    }

    isCalculatingFare.value = true;
    try {
      final driverDoc = await _firestore.collection('drivers').doc(driverId).get();
      final userDoc = await _firestore.collection('users').doc(driverId).get();

      if (!driverDoc.exists) {
        Get.snackbar("Error", "Driver metrics document not found.");
        return;
      }

      final driverData = driverDoc.data()!;
      final userData = userDoc.exists ? userDoc.data() : null;

      // Populate confidential fare metrics
      driverMileage.value = (driverData['mileage'] as num?)?.toDouble() ?? 12.0;
      driverFuelPrice.value = (driverData['fuelPrice'] as num?)?.toDouble() ?? 270.0;
      driverMargin.value = (driverData['profitMargin'] as num?)?.toDouble() ?? 15.0;

      // Populate summary fields
      driverName.value = userData?['name'] ?? driverData['name'] ?? 'Captain';
      
      final String? vehicleId = driverData['primaryVehicleId'] ?? userData?['primaryVehicleId'];
      if (vehicleId != null) {
        final vehicleDoc = await _firestore
            .collection('drivers')
            .doc(driverId)
            .collection('vehicles')
            .doc(vehicleId)
            .get();
        if (vehicleDoc.exists) {
          final vehicleData = vehicleDoc.data()!;
          carModelText.value = '${vehicleData['brand'] ?? 'Car'} ${vehicleData['model'] ?? ''}';
        }
      }
    } catch (e) {
      Get.snackbar("Error", "Failed to fetch metrics: $e");
    } finally {
      isCalculatingFare.value = false;
    }
  }

  // ── Run OSRM distance engine and dynamic fare calculations ────────────────
  Future<void> calculateRouteAndFare() async {
    final String origin = departureController.text.trim();
    final String destination = destinationController.text.trim();

    if (origin.isEmpty || destination.isEmpty) {
      Get.snackbar(
        "Validation",
        "Please enter departure and destination locations.",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.orangeAccent.withValues(alpha: 0.9),
        colorText: Colors.white,
      );
      return;
    }

    // Try to resolve matching city keys from input strings
    final String originKey = _findMatchingCityKey(origin);
    final String destKey = _findMatchingCityKey(destination);

    final originCoords = cityCoordinates[originKey];
    final destCoords = cityCoordinates[destKey];

    if (originCoords == null || destCoords == null) {
      Get.snackbar(
        "Location Error",
        "Could not resolve coordinate mappings for input locations.",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.redAccent.withValues(alpha: 0.9),
        colorText: Colors.white,
      );
      return;
    }

    isCalculatingFare.value = true;
    try {
      final double originLng = originCoords['lng']!;
      final double originLat = originCoords['lat']!;
      final double destLng = destCoords['lng']!;
      final double destLat = destCoords['lat']!;

      final url = Uri.parse(
        'https://router.project-osrm.org/route/v1/driving/'
        '$originLng,$originLat;$destLng,$destLat'
        '?overview=false'
      );

      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['code'] == 'Ok' && data['routes'] != null && (data['routes'] as List).isNotEmpty) {
          final double distanceMeters = (data['routes'][0]['distance'] as num).toDouble();
          final double distanceKm = distanceMeters / 1000.0;
          routeDistanceKm.value = distanceKm;

          // ── CORE PRICING ALGORITHM & DATA LOGIC ────────────────────────────
          // Fuel Expense = (effective_distance / mileage) * fuel_price
          // Net Profit = effective_distance * profit_margin
          // Total Final Fare = Fuel Expense + Net Profit
          final double mileage = driverMileage.value > 0 ? driverMileage.value : 1.0;
          final double effectiveDistance = isRoundTrip.value ? (distanceKm * 2) : distanceKm;

          final double fuelCost = (effectiveDistance / mileage) * driverFuelPrice.value;
          final double marginProfit = effectiveDistance * driverMargin.value;

          fuelExpenses.value = fuelCost;
          netProfit.value = marginProfit;

          final double totalFare = fuelCost + marginProfit;
          totalCalculatedFare.value = totalFare.round();
        } else {
          Get.snackbar("Routing Error", "Could not resolve OSRM route.");
        }
      } else {
        Get.snackbar("Routing Error", "OSRM API responded with status ${response.statusCode}");
      }
    } catch (e) {
      Get.snackbar("Calculation Error", "Failed to compute distance: $e");
    } finally {
      isCalculatingFare.value = false;
    }
  }

  // ── Helper to resolve city keys case-insensitively ────────────────────────
  String _findMatchingCityKey(String input) {
    final String clean = input.toLowerCase();
    for (var key in cityCoordinates.keys) {
      if (clean.contains(key.toLowerCase()) || key.toLowerCase().contains(clean)) {
        return key;
      }
    }
    return input; // fallback to input
  }

  void toggleTripType(bool val) {
    isRoundTrip.value = val;
    if (routeDistanceKm.value > 0) {
      final double distanceKm = routeDistanceKm.value;
      final double mileage = driverMileage.value > 0 ? driverMileage.value : 1.0;
      final double effectiveDistance = isRoundTrip.value ? (distanceKm * 2) : distanceKm;

      final double fuelCost = (effectiveDistance / mileage) * driverFuelPrice.value;
      final double marginProfit = effectiveDistance * driverMargin.value;

      fuelExpenses.value = fuelCost;
      netProfit.value = marginProfit;

      final double totalFare = fuelCost + marginProfit;
      totalCalculatedFare.value = totalFare.round();
    }
  }

  // ── Schedule Date Selection ───────────────────────────────────────────────
  Future<void> selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate.value,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 30)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: Color(0xFF00BFA5),
              onPrimary: Colors.white,
              surface: Color(0xFF0A1628),
              onSurface: Colors.white,
            ),
            dialogTheme: const DialogThemeData(
              backgroundColor: Color(0xFF0C101A),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != selectedDate.value) {
      selectedDate.value = picked;
    }
  }

  // ── Send Booking Request to global /bookings collection ───────────────────
  Future<void> sendBookingRequest() async {
    final String origin = departureController.text.trim();
    final String destination = destinationController.text.trim();
    final int fare = totalCalculatedFare.value;

    if (origin.isEmpty || destination.isEmpty || fare <= 0) {
      Get.snackbar(
        "Validation",
        "Please select a valid route and calculate the fare first.",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.orangeAccent.withValues(alpha: 0.9),
        colorText: Colors.white,
      );
      return;
    }

    final passengerUser = FirebaseAuth.instance.currentUser;
    if (passengerUser == null) {
      Get.snackbar("Auth Error", "Please authenticate to request a ride.");
      return;
    }

    isSubmitting.value = true;
    try {
      final double distance = routeDistanceKm.value;
      final double fuelExp = fuelExpenses.value;
      final double profit = netProfit.value;

      // Fetch passenger profile metrics
      final passengerDoc = await _firestore.collection('users').doc(passengerUser.uid).get();
      final passengerData = passengerDoc.exists ? passengerDoc.data() : null;
      final String pName = passengerData?['name'] ?? 'Passenger';
      final String pPhone = passengerData?['phone'] ?? passengerUser.phoneNumber ?? '';
      final String pProfileUrl = passengerData?['profilePhotoUrl'] ?? '';

      // ── Write booking to global /bookings collection ─────────────────────
      // Documents must strictly save passenger profile metrics alongside booking details
      await _firestore.collection('bookings').add({
        'passengerId': passengerUser.uid,
        'passengerName': pName,
        'passengerPhoneNumber': pPhone,
        'passengerProfileUrl': pProfileUrl,
        'driverId': driverId,
        'departureCity': origin,
        'destinationCity': destination,
        'distanceKm': distance,
        'totalFare': fare,
        'fuelExpense': fuelExp,
        'driverProfit': profit,
        'travelDate': Timestamp.fromDate(selectedDate.value),
        'tripType': isRoundTrip.value ? 'Round-Trip' : 'One-Way',
        'status': 'pending',
        'createdAt': FieldValue.serverTimestamp(),
      });

      // Trigger Hook 1: NEW BOOKING REQUEST ALERT
      try {
        FcmHelper.sendNotification(
          recipientUserId: driverId,
          title: "New Ride Request! 🚗",
          body: "A passenger has requested an inter-city ride from $origin.",
        );
      } catch (e) {
        debugPrint("FCM Booking Alert Error: $e");
      }

      Get.snackbar(
        "Booking Sent!",
        "Your request has been delivered to Captain ${driverName.value}!",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.teal.withValues(alpha: 0.9),
        colorText: Colors.white,
        duration: const Duration(seconds: 4),
      );

      await Future.delayed(const Duration(seconds: 1));
      Get.offAllNamed('/passenger_home'); // Navigates back to home
    } catch (e) {
      Get.snackbar(
        "Submission Failed",
        "Could not place booking: $e",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.redAccent.withValues(alpha: 0.9),
        colorText: Colors.white,
      );
    } finally {
      isSubmitting.value = false;
    }
  }

  @override
  void onClose() {
    departureController.dispose();
    destinationController.dispose();
    super.onClose();
  }
}
