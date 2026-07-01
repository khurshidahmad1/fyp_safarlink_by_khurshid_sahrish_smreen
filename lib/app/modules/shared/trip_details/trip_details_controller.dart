import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';

class TripDetailsController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  late final String bookingId;
  late final String collectionPath; // 'bookings' or 'ride_requests'

  final RxMap<String, dynamic> bookingData = <String, dynamic>{}.obs;
  
  // Real-time profiles of both passenger and driver from `/users`
  final RxMap<String, dynamic> passengerProfile = <String, dynamic>{}.obs;
  final RxMap<String, dynamic> driverProfile = <String, dynamic>{}.obs;
  final RxMap<String, dynamic> driverVehicleData = <String, dynamic>{}.obs;

  final RxBool isLoading = true.obs;
  final RxBool isCompleting = false.obs;
  final RxBool isCancelling = false.obs;
  final RxString userRole = ''.obs; // 'passenger' or 'driver'

  // ── Token Payment State ─────────────────────────────────────────────────────
  var isTokenFormOpen = false.obs;
  var tokenAmount = ''.obs;
  var trxId = ''.obs;

  final TextEditingController tokenAmountController = TextEditingController();
  final TextEditingController tokenTrxIdController = TextEditingController();

  // Predefined cancellation reasons
  final List<String> cancellationReasons = [
    "Change of plans",
    "Driver didn't respond/show up",
    "Passenger changed route/schedule",
    "Vehicle issues / breakdown",
    "Found better price/alternative",
  ];
  final RxString selectedReason = ''.obs;

  @override
  void onInit() {
    super.onInit();

    // Sync controllers with reactive variables
    tokenAmountController.addListener(() {
      tokenAmount.value = tokenAmountController.text;
    });
    tokenTrxIdController.addListener(() {
      trxId.value = tokenTrxIdController.text;
    });

    // Accept the full booking map payload from navigation arguments
    final args = Get.arguments;
    String initialPassengerId = '';
    String initialDriverId = '';
    if (args is Map<String, dynamic>) {
      bookingId = args['bookingId'] ?? args['id'] ?? args['tripId'] ?? '';
      collectionPath = args['_collection'] ?? 'bookings';
      initialPassengerId = args['passengerId'] ?? '';
      initialDriverId = args['driverId'] ?? '';
    } else {
      bookingId = '';
      collectionPath = 'bookings';
    }

    _determineRoleAndListen();
    _startInitialFetches(initialPassengerId, initialDriverId);
  }

  void _startInitialFetches(String passengerId, String driverId) {
    if (passengerId.isNotEmpty) {
      _firestore.collection('users').doc(passengerId).snapshots().listen((snap) {
        if (snap.exists) {
          passengerProfile.assignAll(snap.data()!);
        }
      });
    }
    if (driverId.isNotEmpty) {
      _firestore.collection('users').doc(driverId).snapshots().listen((snap) {
        if (snap.exists) {
          driverProfile.assignAll(snap.data()!);
        }
      });
      _firestore.collection('drivers').doc(driverId).snapshots().listen((snap) {
        if (snap.exists) {
          driverVehicleData.assignAll(snap.data()!);
        }
      });
    }
  }

  Future<void> _determineRoleAndListen() async {
    final user = _auth.currentUser;
    if (user == null || bookingId.isEmpty) {
      isLoading.value = false;
      return;
    }

    try {
      // 1. Fetch user role
      final userDoc = await _firestore.collection('users').doc(user.uid).get();
      if (userDoc.exists) {
        userRole.value = userDoc.data()?['role'] ?? 'passenger';
      }

      // 2. Listen to booking document stream (supports both collections)
      _firestore.collection(collectionPath).doc(bookingId).snapshots().listen((snapshot) async {
        if (!snapshot.exists) {
          isLoading.value = false;
          return;
        }

        final data = snapshot.data()!;
        bookingData.assignAll(data);

        final String pId = data['passengerId'] ?? '';
        final String dId = data['driverId'] ?? '';

        // Start listening to the counterpart profile updates
        _startInitialFetches(pId, dId);

        isLoading.value = false;
      });
    } catch (e) {
      isLoading.value = false;
      Get.snackbar("Error", "Failed to load trip: $e");
    }
  }

  // ── Launch phone call ──────────────────────────────────────────────────────
  Future<void> makeCall(String phone) async {
    if (phone.isEmpty) return;
    final Uri url = Uri.parse('tel:$phone');
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    } else {
      Get.snackbar("Error", "Could not open telephone line.");
    }
  }

  // ── Launch WhatsApp deep link ──────────────────────────────────────────────
  Future<void> openWhatsApp(String phone) async {
    if (phone.isEmpty) return;

    // Normalize phone number (remove +, spaces, leading zeroes)
    String cleanPhone = phone.replaceAll(RegExp(r'[+\s\-\(\)]'), '');
    if (cleanPhone.startsWith('0')) {
      cleanPhone = '92${cleanPhone.substring(1)}'; // Pakistan default prefix
    }

    final Uri url = Uri.parse('whatsapp://send?phone=$cleanPhone&text=Hello from Safarlink!');
    try {
      if (await canLaunchUrl(url)) {
        await launchUrl(url);
      } else {
        // Fallback Web link
        final webUrl = Uri.parse('https://wa.me/$cleanPhone?text=Hello%20from%20Safarlink!');
        await launchUrl(webUrl, mode: LaunchMode.externalApplication);
      }
    } catch (e) {
      Get.snackbar("WhatsApp Error", "Could not open WhatsApp.");
    }
  }

  // ── Mark trip as completed (Driver side only) ──────────────────────────────
  Future<void> completeTrip() async {
    if (bookingId.isEmpty) return;

    isCompleting.value = true;
    try {
      await _firestore.collection(collectionPath).doc(bookingId).update({
        'status': 'completed',
        'completedAt': FieldValue.serverTimestamp(),
      });

      Get.snackbar(
        "Trip Completed! 🏆",
        "This ride has been marked as completed successfully.",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.teal,
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar("Error", "Failed to complete trip: $e");
    } finally {
      isCompleting.value = false;
    }
  }

  // ── Cancel confirmed booking request ───────────────────────────────────────
  Future<void> cancelTrip() async {
    if (bookingId.isEmpty) return;

    isCancelling.value = true;
    try {
      await _firestore.collection(collectionPath).doc(bookingId).update({
        'status': 'cancelled',
        'cancellationReason': selectedReason.value,
        'cancelledAt': FieldValue.serverTimestamp(),
      });

      Get.snackbar(
        "Trip Cancelled 🚫",
        "The trip has been cancelled.",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.blueGrey,
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar("Error", "Failed to cancel trip: $e");
    } finally {
      isCancelling.value = false;
      selectedReason.value = '';
    }
  }

  // ── Submit Token Payment (Atomic Firestore Update) ─────────────────────────
  Future<void> submitToken(String bookingId) async {
    final String amount = tokenAmount.value.trim();
    final String reference = trxId.value.trim();

    if (amount.isEmpty || reference.isEmpty) {
      Get.snackbar(
        "Validation Error",
        "Both token amount and transaction reference ID are required.",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
      return;
    }

    final int? parsedInt = int.tryParse(amount);
    if (parsedInt == null) {
      Get.snackbar(
        "Validation Error",
        "Token amount must be a valid integer.",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
      return;
    }

    try {
      await _firestore.collection(collectionPath).doc(bookingId).update({
        'tokenPaid': true,
        'tokenAmount': parsedInt,
        'tokenReference': reference,
        'tokenTimestamp': FieldValue.serverTimestamp(),
      });

      // Reset fields
      tokenAmountController.clear();
      tokenTrxIdController.clear();
      tokenAmount.value = '';
      trxId.value = '';
      isTokenFormOpen.value = false;

      Get.snackbar(
        "Token Updated! ✅",
        "Driver notified reactively.",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFF00BFA5),
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar("Error", "Failed to submit token: $e");
    }
  }

  @override
  void onClose() {
    tokenAmountController.dispose();
    tokenTrxIdController.dispose();
    super.onClose();
  }
}
