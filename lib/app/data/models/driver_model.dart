import 'package:cloud_firestore/cloud_firestore.dart';

/// PUBLIC fields — stored at /users/{uid}
/// PRIVATE fields — stored at /users/{uid}/private/profile
class DriverModel {
  // ── PUBLIC ────────────────────────────────────────────────────────────────
  final String uid;
  final String name;
  final String profilePhotoUrl;
  final String phoneNumber; // PUBLIC — passengers can see this
  final String addaCity; // e.g. Okara
  final double rating;

  // ── PRIVATE (stored in sub-document /users/{uid}/private/profile) ─────────
  final String? email;
  final String? cnicNumber;
  final String? cnicPhotoUrl;
  final bool hasDrivingLicense;
  final String? licensePhotoUrl;
  final bool kycComplete;

  const DriverModel({
    required this.uid,
    required this.name,
    required this.profilePhotoUrl,
    required this.phoneNumber,
    required this.addaCity,
    required this.rating,
    this.email,
    this.cnicNumber,
    this.cnicPhotoUrl,
    this.hasDrivingLicense = false,
    this.licensePhotoUrl,
    this.kycComplete = false,
  });

  // ── Firestore ── Public Document (/users/{uid}) ───────────────────────────
  Map<String, dynamic> toPublicMap() {
    return {
      'uid': uid,
      'name': name,
      'profilePhotoUrl': profilePhotoUrl,
      'phoneNumber': phoneNumber,
      'addaCity': addaCity,
      'rating': rating,
      'role': 'driver',
      'kycComplete': kycComplete,
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }

  // ── Firestore ── Private Sub-document (/users/{uid}/private/profile) ──────
  Map<String, dynamic> toPrivateMap() {
    return {
      'email': email,
      'cnicNumber': cnicNumber,
      'cnicPhotoUrl': cnicPhotoUrl,
      'hasDrivingLicense': hasDrivingLicense,
      'licensePhotoUrl': licensePhotoUrl,
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }

  factory DriverModel.fromPublicDoc(DocumentSnapshot doc) {
    final d = doc.data() as Map<String, dynamic>;
    return DriverModel(
      uid: d['uid'] ?? doc.id,
      name: d['name'] ?? '',
      profilePhotoUrl: d['profilePhotoUrl'] ?? '',
      phoneNumber: d['phoneNumber'] ?? '',
      addaCity: d['addaCity'] ?? '',
      rating: (d['rating'] as num?)?.toDouble() ?? 0.0,
      kycComplete: d['kycComplete'] ?? false,
    );
  }

  factory DriverModel.fromPrivateDoc(DriverModel pub, DocumentSnapshot doc) {
    final d = doc.data() as Map<String, dynamic>;
    return DriverModel(
      uid: pub.uid,
      name: pub.name,
      profilePhotoUrl: pub.profilePhotoUrl,
      phoneNumber: pub.phoneNumber,
      addaCity: pub.addaCity,
      rating: pub.rating,
      kycComplete: pub.kycComplete,
      email: d['email'],
      cnicNumber: d['cnicNumber'],
      cnicPhotoUrl: d['cnicPhotoUrl'],
      hasDrivingLicense: d['hasDrivingLicense'] ?? false,
      licensePhotoUrl: d['licensePhotoUrl'],
    );
  }

  DriverModel copyWith({
    String? uid,
    String? name,
    String? profilePhotoUrl,
    String? phoneNumber,
    String? addaCity,
    double? rating,
    String? email,
    String? cnicNumber,
    String? cnicPhotoUrl,
    bool? hasDrivingLicense,
    String? licensePhotoUrl,
    bool? kycComplete,
  }) {
    return DriverModel(
      uid: uid ?? this.uid,
      name: name ?? this.name,
      profilePhotoUrl: profilePhotoUrl ?? this.profilePhotoUrl,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      addaCity: addaCity ?? this.addaCity,
      rating: rating ?? this.rating,
      email: email ?? this.email,
      cnicNumber: cnicNumber ?? this.cnicNumber,
      cnicPhotoUrl: cnicPhotoUrl ?? this.cnicPhotoUrl,
      hasDrivingLicense: hasDrivingLicense ?? this.hasDrivingLicense,
      licensePhotoUrl: licensePhotoUrl ?? this.licensePhotoUrl,
      kycComplete: kycComplete ?? this.kycComplete,
    );
  }
}
