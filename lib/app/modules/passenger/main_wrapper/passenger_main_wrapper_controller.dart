import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../bookings/rating_dialog_sheet.dart';

class PassengerMainWrapperController extends GetxController {
  final RxInt currentIndex = 0.obs;
  StreamSubscription? _completedBookingSubscription;

  @override
  void onInit() {
    super.onInit();
    _startCompletedBookingListener();
  }

  void changePage(int index) {
    currentIndex.value = index;
  }

  void _startCompletedBookingListener() {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    // Listen to bookings that are 'completed' and not yet reviewed
    _completedBookingSubscription = FirebaseFirestore.instance
        .collection('bookings')
        .where('passengerId', isEqualTo: user.uid)
        .where('status', isEqualTo: 'completed')
        .snapshots()
        .listen((snapshot) async {
      for (var doc in snapshot.docs) {
        final data = doc.data();
        final bool isReviewed = data['isReviewed'] ?? false;
        
        if (!isReviewed) {
          final String bookingId = doc.id;
          final String driverId = data['driverId'] ?? '';
          
          if (driverId.isNotEmpty) {
            // Fetch driver name
            final driverUserDoc = await FirebaseFirestore.instance.collection('users').doc(driverId).get();
            final String driverName = driverUserDoc.exists 
                ? (driverUserDoc.data()?['name'] ?? 'Captain') 
                : 'Captain';

            // Show non-dismissible rating dialog sheet
            Get.bottomSheet(
              RatingDialogSheet(
                bookingId: bookingId,
                driverId: driverId,
                driverName: driverName,
              ),
              isDismissible: false,
              enableDrag: false,
              isScrollControlled: true,
            );
            
            // Only handle one rating at a time
            break;
          }
        }
      }
    });
  }

  @override
  void onClose() {
    _completedBookingSubscription?.cancel();
    super.onClose();
  }
}
