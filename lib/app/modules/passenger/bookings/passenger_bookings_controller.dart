import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class PassengerBookingsController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // ── Stream builder mapping for target statuses ────────────────────────────
  Stream<List<Map<String, dynamic>>> getBookingsStream(String status) {
    final user = _auth.currentUser;
    if (user == null) {
      return Stream.value([]);
    }

    return _firestore
        .collection('bookings')
        .where('passengerId', isEqualTo: user.uid)
        .where('status', isEqualTo: status)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) {
            final data = doc.data();
            data['id'] = doc.id;
            return data;
          }).toList();
        });
  }

  // ── Delete Booking Request ────────────────────────────────────────────────
  Future<void> deleteBookingRequest(String bookingId) async {
    try {
      await _firestore.collection('bookings').doc(bookingId).delete();
      
      Get.snackbar(
        "Booking Removed 🚫",
        "The booking request has been successfully deleted.",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.blueGrey.withValues(alpha: 0.9),
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
      );
    } catch (e) {
      Get.snackbar(
        "Error",
        "Could not delete booking: $e",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.redAccent.withValues(alpha: 0.9),
        colorText: Colors.white,
      );
    }
  }
}
