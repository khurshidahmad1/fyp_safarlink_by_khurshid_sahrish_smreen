import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';

class BookingTrip {
  final String id;
  final String passengerName;
  final String route;
  final String fare;
  final String tokenStatus;
  final String status;

  BookingTrip({
    required this.id,
    required this.passengerName,
    required this.route,
    required this.fare,
    required this.tokenStatus,
    required this.status,
  });
}

class BookingManagementController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  final RxList<BookingTrip> upcomingTrips = <BookingTrip>[].obs;
  final RxList<BookingTrip> pastTrips = <BookingTrip>[].obs;

  @override
  void onInit() {
    super.onInit();
    _listenToTrips();
  }

  void _listenToTrips() {
    final user = _auth.currentUser;
    if (user == null) return;

    // Upcoming: status is 'confirmed'
    _firestore
        .collection('bookings')
        .where('driverId', isEqualTo: user.uid)
        .where('status', isEqualTo: 'confirmed')
        .snapshots()
        .listen((snapshot) {
      final trips = snapshot.docs.map((doc) {
        final data = doc.data();
        final departure = data['departureCity'] ?? 'Departure';
        final destination = data['destinationCity'] ?? 'Destination';
        final fareValue = (data['totalFare'] as num?)?.toInt() ?? 0;
        final pName = data['passengerName'] ?? 'Passenger';
        
        return BookingTrip(
          id: doc.id,
          passengerName: pName,
          route: '$departure to $destination',
          fare: 'Rs. $fareValue',
          tokenStatus: 'Paid',
          status: 'confirmed',
        );
      }).toList();
      upcomingTrips.assignAll(trips);
    });

    // Past / Completed: status is 'completed' or 'cancelled' or 'rejected'
    _firestore
        .collection('bookings')
        .where('driverId', isEqualTo: user.uid)
        .where('status', whereIn: ['completed', 'cancelled', 'rejected'])
        .snapshots()
        .listen((snapshot) {
      final trips = snapshot.docs.map((doc) {
        final data = doc.data();
        final departure = data['departureCity'] ?? 'Departure';
        final destination = data['destinationCity'] ?? 'Destination';
        final fareValue = (data['totalFare'] as num?)?.toInt() ?? 0;
        final pName = data['passengerName'] ?? 'Passenger';
        final status = data['status'] ?? 'completed';

        return BookingTrip(
          id: doc.id,
          passengerName: pName,
          route: '$departure to $destination',
          fare: 'Rs. $fareValue',
          tokenStatus: status.toUpperCase(),
          status: status,
        );
      }).toList();
      pastTrips.assignAll(trips);
    });
  }
}
