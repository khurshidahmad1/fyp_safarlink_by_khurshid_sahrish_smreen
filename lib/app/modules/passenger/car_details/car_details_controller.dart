import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';

class CarDetailsController extends GetxController {
  // ── Arguments ─────────────────────────────────────────────────────────────
  late final String driverId;

  // ── Reactive Driver & Vehicle Details ──────────────────────────────────────
  final RxString driverName = 'Captain'.obs;
  final RxString driverPhoto = ''.obs;
  final RxDouble driverRating = 5.0.obs;
  
  final RxString carBrand = 'Car'.obs;
  final RxString carModel = ''.obs;
  final RxInt totalSeats = 4.obs;
  final RxString vehiclePhoto = ''.obs;
  final RxList<String> vehiclePhotos = <String>[].obs;
  final RxBool isAc = false.obs;

  // ── Calendar Blocked Dates ────────────────────────────────────────────────
  final RxList<DateTime> calendarBlockedDates = <DateTime>[].obs;
  final RxBool isLoading = false.obs;

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void onInit() {
    super.onInit();
    driverId = Get.arguments['driverId'] ?? '';
    fetchDriverDetails();
  }

  // ── Fetch details from Firestore ──────────────────────────────────────────
  Future<void> fetchDriverDetails() async {
    if (driverId.isEmpty) {
      Get.snackbar("Error", "No driver specified.");
      return;
    }

    isLoading.value = true;
    try {
      final driverDoc = await _firestore.collection('drivers').doc(driverId).get();
      final userDoc = await _firestore.collection('users').doc(driverId).get();

      if (!driverDoc.exists) {
        Get.snackbar("Error", "Driver not found.");
        return;
      }

      final driverData = driverDoc.data()!;
      final userData = userDoc.exists ? userDoc.data() : null;

      // Driver Info
      driverName.value = userData?['name'] ?? driverData['name'] ?? 'Captain';
      driverPhoto.value = userData?['profilePhotoUrl'] ?? driverData['profilePhotoUrl'] ?? '';
      driverRating.value = (userData?['rating'] as num?)?.toDouble() ?? 
                           (driverData['averageRating'] as num?)?.toDouble() ?? 
                           5.0;

      // Blocked Dates
      if (driverData['calendarBlockedDates'] != null && driverData['calendarBlockedDates'] is List) {
        final List<dynamic> rawDates = driverData['calendarBlockedDates'];
        final List<DateTime> parsedDates = [];
        
        for (var dateVal in rawDates) {
          if (dateVal is Timestamp) {
            parsedDates.add(_normalizeDate(dateVal.toDate()));
          } else if (dateVal is String) {
            final parsed = DateTime.tryParse(dateVal);
            if (parsed != null) parsedDates.add(_normalizeDate(parsed));
          }
        }
        calendarBlockedDates.assignAll(parsedDates);
      }

      // Vehicle Info
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
          carBrand.value = vehicleData['brand'] ?? 'Car';
          carModel.value = vehicleData['model'] ?? '';
          totalSeats.value = (vehicleData['totalSeats'] as num?)?.toInt() ?? 4;
          isAc.value = vehicleData['isAc'] ?? false;
          
          final List<dynamic>? photos = vehicleData['carPhotos'];
          if (photos != null && photos.isNotEmpty) {
            vehiclePhoto.value = photos.first.toString();
            vehiclePhotos.assignAll(photos.map((p) => p.toString()).toList());
          }
        } else if (userData?['primaryVehicle'] != null) {
          final vehicleData = Map<String, dynamic>.from(userData!['primaryVehicle']);
          carBrand.value = vehicleData['brand'] ?? 'Car';
          carModel.value = vehicleData['model'] ?? '';
          totalSeats.value = (vehicleData['totalSeats'] as num?)?.toInt() ?? 4;
          isAc.value = vehicleData['isAc'] ?? false;
          
          final List<dynamic>? photos = vehicleData['carPhotos'];
          if (photos != null && photos.isNotEmpty) {
            vehiclePhoto.value = photos.first.toString();
            vehiclePhotos.assignAll(photos.map((p) => p.toString()).toList());
          }
        }
      }
    } catch (e) {
      Get.snackbar("Error", "Failed to load details: $e");
    } finally {
      isLoading.value = false;
    }
  }

  DateTime _normalizeDate(DateTime dt) => DateTime(dt.year, dt.month, dt.day);

  bool isDateBlocked(DateTime date) {
    final normalized = _normalizeDate(date);
    return calendarBlockedDates.any((d) => _normalizeDate(d) == normalized);
  }
}
