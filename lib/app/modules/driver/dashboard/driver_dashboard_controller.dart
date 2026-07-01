import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../routes/app_routes.dart';

class DriverDashboardController extends GetxController {
  // ── Stats ─────────────────────────────────────────────────────────────────
  final RxDouble earnings = 0.0.obs;
  final RxInt activeTrips = 0.obs;
  final RxDouble rating = 0.0.obs;

  // ── Driver Profile ────────────────────────────────────────────────────────
  final RxString driverName = 'Captain'.obs;
  final RxString addaCity = ''.obs;
  final RxString profilePhotoUrl = ''.obs;
  final RxBool isCarRegistered = false.obs;
  final RxBool isVehicleRegistered = false.obs;
  final RxBool kycComplete = false.obs;
  final RxBool isProfileLoading = true.obs;

  // ── Hybrid Calendar Engine ────────────────────────────────────────────────
  /// Stores all blocked/booked dates (red on calendar).
  /// Keys are DateTime normalized to midnight.
  final RxSet<DateTime> blockedDates = <DateTime>{}.obs;

  /// Stores manually added bookings by the driver (e.g. pre-arranged trips)
  final RxList<Map<String, dynamic>> manualBookings =
      <Map<String, dynamic>>[].obs;

  /// Selected day on the calendar widget
  final Rx<DateTime> selectedDay = DateTime.now().obs;
  final Rx<DateTime> focusedDay = DateTime.now().obs;

  // ── Firebase ──────────────────────────────────────────────────────────────
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Stream subscription for real-time driver document listener
  StreamSubscription<DocumentSnapshot>? _driverDocSubscription;

  @override
  void onInit() {
    super.onInit();
    _loadDriverProfile();
    _setupDriverDocListener();
  }

  // ── Real-time Firestore Listener for /drivers/{uid} ───────────────────────
  /// Sets up a `snapshots()` stream on the driver's document to reactively
  /// track vehicle registration status and fare engine fields.
  /// When the document exists with valid data, the dashboard auto-unlocks
  /// stats, the calendar FAB, and swaps the glowing CTA with active streams.
  void _setupDriverDocListener() {
    final user = _auth.currentUser;
    if (user == null) return;

    final String currentUid = user.uid;

    _driverDocSubscription = _firestore
        .collection('drivers')
        .doc(currentUid)
        .snapshots()
        .listen(
      (DocumentSnapshot snapshot) {
        try {
          if (!snapshot.exists || snapshot.data() == null) {
            // No driver document yet → vehicle not registered
            isVehicleRegistered.value = false;
            isCarRegistered.value = false;
            return;
          }

          final data = snapshot.data() as Map<String, dynamic>;

          // ── Check for valid vehicle & fare engine fields ─────────────
          final bool hasValidVehicle =
              data['isVehicleRegistered'] == true ||
                  data['primaryVehicleId'] != null;

          final bool hasValidFareFields =
              data['mileage'] != null &&
                  data['fuelPrice'] != null &&
                  data['profitMargin'] != null;

          if (hasValidVehicle && hasValidFareFields) {
            isVehicleRegistered.value = true;
            isCarRegistered.value = true;

            // Sync fare/rating data from the driver document
            rating.value =
                (data['averageRating'] as num?)?.toDouble() ?? 5.0;
          } else {
            isVehicleRegistered.value = false;
            isCarRegistered.value = false;
          }

          // Sync calendar blocked dates if stored in the driver doc
          if (data['calendarBlockedDates'] != null &&
              data['calendarBlockedDates'] is List) {
            final List<dynamic> rawDates = data['calendarBlockedDates'];
            final Set<DateTime> dates = rawDates
                .whereType<Timestamp>()
                .map((ts) => _normalizeDate(ts.toDate()))
                .toSet();
            blockedDates.addAll(dates);
          }
        } catch (e) {
          debugPrint('Driver doc listener error: $e');
        }
      },
      onError: (error) {
        debugPrint('Driver doc stream error: $error');
      },
    );
  }

  // ── Profile Loading ───────────────────────────────────────────────────────
  Future<void> _loadDriverProfile() async {
    final user = _auth.currentUser;
    if (user == null) return;

    isProfileLoading.value = true;
    try {
      final doc =
          await _firestore.collection('users').doc(user.uid).get();
      if (!doc.exists) return;

      final data = doc.data()!;
      driverName.value = data['name'] ?? 'Captain';
      addaCity.value = data['addaCity'] ?? '';
      profilePhotoUrl.value = data['profilePhotoUrl'] ?? '';
      rating.value = (data['rating'] as num?)?.toDouble() ?? 0.0;
      kycComplete.value = data['kycComplete'] ?? false;

      // Vehicle check (legacy /users path — also updated by real-time listener)
      isCarRegistered.value =
          data['hasVehicle'] == true || data['carDetails'] != null;

      // Also sync isVehicleRegistered from legacy path as fallback
      if (isCarRegistered.value && !isVehicleRegistered.value) {
        isVehicleRegistered.value = true;
      }

      // Earnings from stats sub-collection (optional)
      final statsDoc = await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('stats')
          .doc('lifetime')
          .get();
      if (statsDoc.exists) {
        earnings.value =
            (statsDoc.data()?['totalEarnings'] as num?)?.toDouble() ?? 0.0;
        activeTrips.value =
            (statsDoc.data()?['totalTrips'] as num?)?.toInt() ?? 0;
      }

      // Load blocked dates from Firestore
      await _loadBlockedDates(user.uid);
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to load profile: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isProfileLoading.value = false;
    }
  }

  // ── Hybrid Calendar Engine ────────────────────────────────────────────────

  /// Load persisted blocked dates from Firestore
  Future<void> _loadBlockedDates(String uid) async {
    try {
      final snap = await _firestore
          .collection('users')
          .doc(uid)
          .collection('blocked_dates')
          .get();

      final dates = snap.docs.map((d) {
        final ts = d.data()['date'] as Timestamp?;
        return ts?.toDate() ?? DateTime.now();
      }).map(_normalizeDate).toSet();

      blockedDates.addAll(dates);
    } catch (_) {}
  }

  /// Normalize a DateTime to midnight for consistent comparison
  DateTime _normalizeDate(DateTime dt) =>
      DateTime(dt.year, dt.month, dt.day);

  /// Check if a given date is blocked
  bool isDateBlocked(DateTime day) =>
      blockedDates.contains(_normalizeDate(day));

  /// Add a manual booking / block a date
  Future<void> addManualBooking(DateTime date,
      {String? note, String? passengerName}) async {
    final normalized = _normalizeDate(date);
    if (blockedDates.contains(normalized)) {
      Get.snackbar('Already Blocked', 'This date is already marked',
          snackPosition: SnackPosition.BOTTOM);
      return;
    }

    blockedDates.add(normalized);
    manualBookings.add({
      'date': normalized,
      'note': note ?? 'Manual Block',
      'passengerName': passengerName ?? '',
      'addedAt': DateTime.now(),
    });

    // Persist to Firestore
    final user = _auth.currentUser;
    if (user == null) return;
    try {
      await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('blocked_dates')
          .add({
        'date': Timestamp.fromDate(normalized),
        'note': note ?? 'Manual Block',
        'passengerName': passengerName ?? '',
        'source': 'manual',
        'createdAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      debugPrint('Failed to persist blocked date: $e');
    }
  }

  /// Unblock / remove a date
  Future<void> unblockDate(DateTime date) async {
    final normalized = _normalizeDate(date);
    blockedDates.remove(normalized);
    manualBookings.removeWhere(
        (b) => _normalizeDate(b['date'] as DateTime) == normalized);

    final user = _auth.currentUser;
    if (user == null) return;
    try {
      final snap = await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('blocked_dates')
          .where('date',
              isEqualTo: Timestamp.fromDate(normalized))
          .get();
      for (final doc in snap.docs) {
        await doc.reference.delete();
      }
    } catch (_) {}
  }

  /// Called when user taps the FAB to manually block a date
  void showAddBlockDialog() {
    Get.defaultDialog(
      title: '📅 Block a Date',
      titleStyle: const TextStyle(fontWeight: FontWeight.bold),
      middleText: 'Block ${_formatDate(selectedDay.value)} for a manual trip?',
      textConfirm: 'Block',
      textCancel: 'Cancel',
      confirmTextColor: Colors.white,
      buttonColor: const Color(0xFF003D45),
      onConfirm: () {
        Get.back();
        addManualBooking(selectedDay.value,
            note: 'Manual booking via calendar');
        Get.snackbar('Blocked',
            '${_formatDate(selectedDay.value)} has been blocked',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.teal.withValues(alpha: 0.85),
            colorText: Colors.white);
      },
    );
  }

  /// Called when user long-presses a blocked date to unblock
  void showUnblockDialog(DateTime date) {
    if (!isDateBlocked(date)) return;
    Get.defaultDialog(
      title: '🔓 Unblock Date',
      middleText: 'Remove block from ${_formatDate(date)}?',
      textConfirm: 'Unblock',
      textCancel: 'Keep',
      confirmTextColor: Colors.white,
      buttonColor: Colors.redAccent,
      onConfirm: () {
        Get.back();
        unblockDate(date);
        Get.snackbar('Unblocked', '${_formatDate(date)} is now available',
            snackPosition: SnackPosition.BOTTOM);
      },
    );
  }

  String _formatDate(DateTime dt) =>
      '${dt.day}/${dt.month}/${dt.year}';

  // ── Navigation ────────────────────────────────────────────────────────────
  void goToKyc() => Get.toNamed(AppRoutes.DRIVER_KYC_SETUP);
  void goToVehicle() => Get.toNamed(AppRoutes.VEHICLE_LISTING);
  void goToBookings() => Get.toNamed(AppRoutes.BOOKING_MANAGEMENT);
  void goToRequestsHub() => Get.toNamed(AppRoutes.DRIVER_REQUESTS_HUB);
  void goToTripManagement() => Get.toNamed(AppRoutes.TRIP_MANAGEMENT);
  void goToCarRegistration() => Get.toNamed(AppRoutes.CAR_REGISTRATION);

  @override
  void onClose() {
    // Cancel the real-time listener to prevent memory leaks
    _driverDocSubscription?.cancel();
    super.onClose();
  }
}
