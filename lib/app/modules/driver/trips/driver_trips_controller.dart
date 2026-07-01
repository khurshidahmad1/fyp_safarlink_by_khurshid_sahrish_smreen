import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class DriverTripsController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  final RxList<Map<String, dynamic>> activeTodayTrips = <Map<String, dynamic>>[].obs;
  final RxList<Map<String, dynamic>> upcomingTrips = <Map<String, dynamic>>[].obs;
  final RxList<Map<String, dynamic>> completedTrips = <Map<String, dynamic>>[].obs;
  final RxBool isLoading = true.obs;

  @override
  void onInit() {
    super.onInit();
    _listenToTrips();
  }

  void _listenToTrips() {
    final user = _auth.currentUser;
    if (user == null) {
      isLoading.value = false;
      return;
    }

    _firestore
        .collection('bookings')
        .where('driverId', isEqualTo: user.uid)
        .where('status', whereIn: const ['confirmed', 'ongoing', 'completed'])
        .snapshots()
        .listen((snap) {
      final List<Map<String, dynamic>> today = [];
      final List<Map<String, dynamic>> upcoming = [];
      final List<Map<String, dynamic>> completed = [];

      for (var doc in snap.docs) {
        final data = doc.data();
        data['id'] = doc.id;
        data['bookingId'] = doc.id;
        data['_collection'] = 'bookings';

        final status = data['status'] as String?;
        if (status == 'completed') {
          completed.add(data);
          continue;
        }

        final rawDate = data['journeyDate'] ?? data['travelDate'] ?? data['tripDate'];
        final date = _parseDate(rawDate);

        if (date != null) {
          if (_isToday(date) && (status == 'confirmed' || status == 'ongoing')) {
            today.add(data);
          } else if (_isFuture(date) && status == 'confirmed') {
            upcoming.add(data);
          }
        } else {
          // If no date is available, default to today if it's confirmed or ongoing
          if (status == 'confirmed' || status == 'ongoing') {
            today.add(data);
          }
        }
      }

      activeTodayTrips.assignAll(today);
      upcomingTrips.assignAll(upcoming);
      completedTrips.assignAll(completed);
      isLoading.value = false;
    }, onError: (e) {
      isLoading.value = false;
      debugPrint("Error listening to driver bookings: $e");
    });
  }

  Future<void> startActiveTrip(String bookingId) async {
    try {
      Get.dialog(const Center(child: CircularProgressIndicator()), barrierDismissible: false);
      await _firestore.collection('bookings').doc(bookingId).update({
        'status': 'ongoing',
      });
      Get.back(); // close dialog
      Get.snackbar(
        "Trip Started",
        "Your trip is now ongoing. Drive safely!",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.teal.withOpacity(0.9),
        colorText: Colors.white,
      );
    } catch (e) {
      Get.back();
      debugPrint("Error starting trip: $e");
      Get.snackbar("Error", "Could not start trip. Try again.");
    }
  }

  Future<void> completeActiveTrip(String bookingId) async {
    try {
      Get.dialog(const Center(child: CircularProgressIndicator()), barrierDismissible: false);
      await _firestore.collection('bookings').doc(bookingId).update({
        'status': 'completed',
        'completedAt': FieldValue.serverTimestamp(),
      });
      Get.back(); // close dialog
      Get.snackbar(
        "Trip Completed",
        "Trip marked as completed. Pending passenger review.",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.teal.withOpacity(0.9),
        colorText: Colors.white,
      );
    } catch (e) {
      Get.back();
      debugPrint("Error completing trip: $e");
      Get.snackbar("Error", "Could not complete trip. Try again.");
    }
  }

  DateTime? _parseDate(dynamic val) {
    if (val == null) return null;
    if (val is Timestamp) return val.toDate();
    if (val is String) return DateTime.tryParse(val);
    return null;
  }

  bool _isToday(DateTime dt) {
    final now = DateTime.now();
    return dt.year == now.year && dt.month == now.month && dt.day == now.day;
  }

  bool _isFuture(DateTime dt) {
    final now = DateTime.now();
    final todayMidnight = DateTime(now.year, now.month, now.day);
    final dateMidnight = DateTime(dt.year, dt.month, dt.day);
    return dateMidnight.isAfter(todayMidnight);
  }

  String formatDate(dynamic rawDate) {
    final date = _parseDate(rawDate);
    if (date == null) return 'N/A';
    const months = [
      '', 'Jan','Feb','Mar','Apr','May','Jun',
      'Jul','Aug','Sep','Oct','Nov','Dec'
    ];
    return '${date.day} ${months[date.month]} ${date.year}';
  }
}
