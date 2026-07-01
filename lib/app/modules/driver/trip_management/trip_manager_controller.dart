import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class TripStatus {
  static const String active = 'active';
  static const String completed = 'completed';
  static const String cancelled = 'cancelled';
  static const String accepted = 'accepted';
}

class TripModel {
  final String tripId;
  final String passengerName;
  final String passengerPhone;
  final String fromCity;
  final String toCity;
  final int seats;
  final double fare;
  final String status;
  final DateTime tripDate;
  final Map<String, dynamic> rawData;

  const TripModel({
    required this.tripId,
    required this.passengerName,
    required this.passengerPhone,
    required this.fromCity,
    required this.toCity,
    required this.seats,
    required this.fare,
    required this.status,
    required this.tripDate,
    required this.rawData,
  });

  factory TripModel.fromDoc(DocumentSnapshot doc) {
    final d = doc.data() as Map<String, dynamic>;
    return TripModel(
      tripId: doc.id,
      passengerName: d['passengerName'] ?? 'Unknown',
      passengerPhone: d['passengerPhone'] ?? '',
      fromCity: d['fromCity'] ?? '',
      toCity: d['toCity'] ?? '',
      seats: (d['seats'] as num?)?.toInt() ?? 1,
      fare: (d['fare'] as num?)?.toDouble() ?? 0.0,
      status: d['status'] ?? TripStatus.active,
      tripDate:
          (d['tripDate'] as Timestamp?)?.toDate() ?? DateTime.now(),
      rawData: {
        ...d,
        'bookingId': doc.id,
        'id': doc.id,
        '_collection': 'ride_requests',
      },
    );
  }
}

class TripManagerController extends GetxController {
  // ── State ──────────────────────────────────────────────────────────────
  final RxList<TripModel> activeTrips = <TripModel>[].obs;
  final RxList<TripModel> pastTrips = <TripModel>[].obs;
  final RxBool isLoading = true.obs;
  final RxInt selectedTab = 0.obs; // 0=Active, 1=History

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

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
        .collection('ride_requests')
        .where('driverId', isEqualTo: user.uid)
        .orderBy('tripDate', descending: true)
        .snapshots()
        .listen((snap) {
      final all = snap.docs.map(TripModel.fromDoc).toList();
      activeTrips.value = all
          .where((t) =>
              t.status == TripStatus.accepted ||
              t.status == TripStatus.active)
          .toList();
      pastTrips.value = all
          .where((t) =>
              t.status == TripStatus.completed ||
              t.status == TripStatus.cancelled)
          .toList();
      isLoading.value = false;
    }, onError: (e) {
      isLoading.value = false;
      debugPrint('TripManager error: $e');
    });
  }

  Future<void> markTripComplete(TripModel trip) async {
    try {
      await _firestore
          .collection('ride_requests')
          .doc(trip.tripId)
          .update({
        'status': TripStatus.completed,
        'completedAt': FieldValue.serverTimestamp(),
      });
      Get.snackbar('Trip Complete', 'Trip marked as completed!',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.teal.withValues(alpha: 0.9),
          colorText: Colors.white);
    } catch (e) {
      Get.snackbar('Error', 'Could not update trip: $e',
          snackPosition: SnackPosition.BOTTOM);
    }
  }

  String formatDate(DateTime dt) {
    const months = [
      '', 'Jan','Feb','Mar','Apr','May','Jun',
      'Jul','Aug','Sep','Oct','Nov','Dec'
    ];
    return '${dt.day} ${months[dt.month]} ${dt.year}';
  }
}
