import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class DriverCalendarController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  final RxList<DateTime> bookedDates = <DateTime>[].obs;
  final Rx<DateTime> selectedDay = DateTime.now().obs;
  final Rx<DateTime> focusedDay = DateTime.now().obs;

  // Form fields for manual booking
  final passengerNameController = TextEditingController();
  final passengerPhoneController = TextEditingController();
  final departureController = TextEditingController();
  final destinationController = TextEditingController();

  final RxBool isSubmitting = false.obs;

  @override
  void onInit() {
    super.onInit();
    _listenToBookedDates();
  }

  void _listenToBookedDates() {
    final user = _auth.currentUser;
    if (user == null) return;

    _firestore
        .collection('bookings')
        .where('driverId', isEqualTo: user.uid)
        .where('status', isEqualTo: 'confirmed')
        .snapshots()
        .listen((snapshot) {
      final List<DateTime> dates = [];
      for (var doc in snapshot.docs) {
        final data = doc.data();
        if (data['travelDate'] != null) {
          final timestamp = data['travelDate'] as Timestamp;
          final dt = timestamp.toDate();
          dates.add(DateTime(dt.year, dt.month, dt.day));
        }
      }
      bookedDates.assignAll(dates);
    });
  }

  Future<void> submitOfflineBooking() async {
    final name = passengerNameController.text.trim();
    final phone = passengerPhoneController.text.trim();
    final departure = departureController.text.trim();
    final destination = destinationController.text.trim();
    final user = _auth.currentUser;

    if (user == null) return;

    if (name.isEmpty || phone.isEmpty || departure.isEmpty || destination.isEmpty) {
      Get.snackbar(
        "Validation",
        "Please fill all fields.",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.orangeAccent,
        colorText: Colors.white,
      );
      return;
    }

    isSubmitting.value = true;
    try {
      final date = selectedDay.value;
      
      // Write confirmed offline/manual booking directly to bookings collection
      await _firestore.collection('bookings').add({
        'driverId': user.uid,
        'passengerId': 'manual_offline',
        'passengerName': name,
        'passengerPhoneNumber': phone,
        'departureCity': departure,
        'destinationCity': destination,
        'distanceKm': 0.0,
        'totalFare': 0,
        'fuelExpense': 0.0,
        'driverProfit': 0.0,
        'travelDate': Timestamp.fromDate(DateTime(date.year, date.month, date.day)),
        'tripType': 'Manual/Offline',
        'status': 'confirmed',
        'createdAt': FieldValue.serverTimestamp(),
      });

      // Reset fields
      passengerNameController.clear();
      passengerPhoneController.clear();
      departureController.clear();
      destinationController.clear();

      Get.back(); // close bottom sheet
      Get.snackbar(
        "Offline Booking Saved 🎉",
        "Calendar date locked successfully.",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.teal,
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar("Error", "Failed to block date: $e");
    } finally {
      isSubmitting.value = false;
    }
  }

  @override
  void onClose() {
    passengerNameController.dispose();
    passengerPhoneController.dispose();
    departureController.dispose();
    destinationController.dispose();
    super.onClose();
  }
}
