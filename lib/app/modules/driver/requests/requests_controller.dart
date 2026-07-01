import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class RequestsHubController extends GetxController {
  // ── State ─────────────────────────────────────────────────────────────────
  final RxList<Map<String, dynamic>> incomingRequests = <Map<String, dynamic>>[].obs;
  final RxBool isLoading = true.obs;
  final RxString errorMessage = ''.obs;

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? _streamSub;
  bool _isFirstLoad = true;

  @override
  void onInit() {
    super.onInit();
    _listenToRequests();
  }

  // ── Real-time Snapshot Stream Listener ────────────────────────────────────
  void _listenToRequests() {
    final user = _auth.currentUser;
    if (user == null) {
      errorMessage.value = 'Not authenticated';
      isLoading.value = false;
      return;
    }

    isLoading.value = true;
    _isFirstLoad = true;

    try {
      _streamSub = _firestore
          .collection('bookings')
          .where('driverId', isEqualTo: user.uid)
          .where('status', isEqualTo: 'pending')
          .snapshots()
          .listen(
        (snapshot) {
          final List<Map<String, dynamic>> list = snapshot.docs.map((doc) {
            final data = doc.data();
            data['id'] = doc.id;
            return data;
          }).toList();

          incomingRequests.assignAll(list);
          isLoading.value = false;
          errorMessage.value = '';

          // Trigger instant local UI Alert / Snackbar if a new document arrives after first load
          if (!_isFirstLoad) {
            if (snapshot.docChanges.any((change) => change.type == DocumentChangeType.added)) {
              Get.snackbar(
                "New Ride Request! 🚗",
                "A passenger is requesting an inter-city ride setup.",
                snackPosition: SnackPosition.TOP,
                backgroundColor: const Color(0xFF00BFA5).withValues(alpha: 0.2),
                colorText: Colors.white,
                duration: const Duration(seconds: 4),
              );
            }
          } else {
            _isFirstLoad = false;
          }
        },
        onError: (e) {
          isLoading.value = false;
          errorMessage.value = 'Failed to listen to requests: $e';
        },
      );
    } catch (e) {
      isLoading.value = false;
      errorMessage.value = 'Failed to setup stream listener: $e';
    }
  }

  // ── Accept Ride ───────────────────────────────────────────────────────────
  Future<void> acceptRide(String bookingId) async {
    try {
      await _firestore
          .collection('bookings')
          .doc(bookingId)
          .update({
        'status': 'accepted',
        'acceptedAt': FieldValue.serverTimestamp(),
      });

      Get.snackbar(
        '✅ Ride Accepted',
        'You accepted the ride request successfully!',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.teal.withValues(alpha: 0.9),
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Could not accept ride: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.redAccent.withValues(alpha: 0.9),
        colorText: Colors.white,
      );
    }
  }

  // ── Reject Ride ───────────────────────────────────────────────────────────
  Future<void> rejectRide(String bookingId) async {
    try {
      await _firestore
          .collection('bookings')
          .doc(bookingId)
          .update({
        'status': 'rejected',
        'rejectedAt': FieldValue.serverTimestamp(),
      });

      Get.snackbar(
        'Request Rejected',
        'You rejected the ride request.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.blueGrey.withValues(alpha: 0.9),
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Could not reject ride: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.redAccent.withValues(alpha: 0.9),
        colorText: Colors.white,
      );
    }
  }

  @override
  void onClose() {
    _streamSub?.cancel();
    super.onClose();
  }
}
