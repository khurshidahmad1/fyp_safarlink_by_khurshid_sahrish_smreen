import 'package:cloud_firestore/cloud_firestore.dart';

/// PUBLIC fields — stored at /users/{uid}/vehicles/{vehicleId}
/// PRIVATE fare metrics — stored in the same document but security-ruled
class VehicleModel {
  // ── PUBLIC ────────────────────────────────────────────────────────────────
  final String vehicleId;
  final String brand; // e.g. Toyota
  final String make; // e.g. Corolla
  final String model; // e.g. 2020
  final String variant; // e.g. GLi
  final bool isAc;
  final int totalSeats;
  final List<String> carPhotos; // min 1, max 8 URLs

  // ── PRIVATE FARE METRICS ──────────────────────────────────────────────────
  // Stored in the vehicle doc but protected by Firestore rules so only
  // the owner (auth.uid == driverId) can read these fields.
  final double mileageKmPerLitre;
  final double fuelPrice; // PKR per litre
  final double profitMarginPercentage;

  const VehicleModel({
    required this.vehicleId,
    required this.brand,
    required this.make,
    required this.model,
    required this.variant,
    required this.isAc,
    required this.totalSeats,
    required this.carPhotos,
    required this.mileageKmPerLitre,
    required this.fuelPrice,
    required this.profitMarginPercentage,
  });

  // ── Firestore ── Full Document (/users/{uid}/vehicles/{vehicleId}) ─────────
  Map<String, dynamic> toMap(String driverUid) {
    return {
      'vehicleId': vehicleId,
      'driverUid': driverUid,
      'brand': brand,
      'make': make,
      'model': model,
      'variant': variant,
      'isAc': isAc,
      'totalSeats': totalSeats,
      'carPhotos': carPhotos,
      // Private fare metrics — protected by Firestore rules
      'mileageKmPerLitre': mileageKmPerLitre,
      'fuelPrice': fuelPrice,
      'profitMarginPercentage': profitMarginPercentage,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }

  /// Public-only map (for exposure to passengers)
  Map<String, dynamic> toPublicMap(String driverUid) {
    return {
      'vehicleId': vehicleId,
      'driverUid': driverUid,
      'brand': brand,
      'make': make,
      'model': model,
      'variant': variant,
      'isAc': isAc,
      'totalSeats': totalSeats,
      'carPhotos': carPhotos,
    };
  }

  factory VehicleModel.fromDoc(DocumentSnapshot doc) {
    final d = doc.data() as Map<String, dynamic>;
    return VehicleModel(
      vehicleId: d['vehicleId'] ?? doc.id,
      brand: d['brand'] ?? '',
      make: d['make'] ?? '',
      model: d['model'] ?? '',
      variant: d['variant'] ?? '',
      isAc: d['isAc'] ?? false,
      totalSeats: (d['totalSeats'] as num?)?.toInt() ?? 4,
      carPhotos: List<String>.from(d['carPhotos'] ?? []),
      mileageKmPerLitre:
          (d['mileageKmPerLitre'] as num?)?.toDouble() ?? 10.0,
      fuelPrice: (d['fuelPrice'] as num?)?.toDouble() ?? 280.0,
      profitMarginPercentage:
          (d['profitMarginPercentage'] as num?)?.toDouble() ?? 15.0,
    );
  }

  factory VehicleModel.fromMap(Map<String, dynamic> d) {
    return VehicleModel(
      vehicleId: d['vehicleId'] ?? '',
      brand: d['brand'] ?? '',
      make: d['make'] ?? '',
      model: d['model'] ?? '',
      variant: d['variant'] ?? '',
      isAc: d['isAc'] ?? false,
      totalSeats: (d['totalSeats'] as num?)?.toInt() ?? 4,
      carPhotos: List<String>.from(d['carPhotos'] ?? []),
      mileageKmPerLitre:
          (d['mileageKmPerLitre'] as num?)?.toDouble() ?? 10.0,
      fuelPrice: (d['fuelPrice'] as num?)?.toDouble() ?? 280.0,
      profitMarginPercentage:
          (d['profitMarginPercentage'] as num?)?.toDouble() ?? 15.0,
    );
  }

  /// Calculate estimated fare for a given distance (km)
  double estimateFare(double distanceKm) {
    final fuelCost = (distanceKm / mileageKmPerLitre) * fuelPrice;
    final profit = fuelCost * (profitMarginPercentage / 100);
    return fuelCost + profit;
  }

  VehicleModel copyWith({
    String? vehicleId,
    String? brand,
    String? make,
    String? model,
    String? variant,
    bool? isAc,
    int? totalSeats,
    List<String>? carPhotos,
    double? mileageKmPerLitre,
    double? fuelPrice,
    double? profitMarginPercentage,
  }) {
    return VehicleModel(
      vehicleId: vehicleId ?? this.vehicleId,
      brand: brand ?? this.brand,
      make: make ?? this.make,
      model: model ?? this.model,
      variant: variant ?? this.variant,
      isAc: isAc ?? this.isAc,
      totalSeats: totalSeats ?? this.totalSeats,
      carPhotos: carPhotos ?? this.carPhotos,
      mileageKmPerLitre: mileageKmPerLitre ?? this.mileageKmPerLitre,
      fuelPrice: fuelPrice ?? this.fuelPrice,
      profitMarginPercentage:
          profitMarginPercentage ?? this.profitMarginPercentage,
    );
  }
}
