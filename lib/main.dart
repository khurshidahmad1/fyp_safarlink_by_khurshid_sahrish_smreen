// =============================================================================
// SAFARLINK — FIRESTORE SECURITY RULES
// Copy these rules into your Firebase Console → Firestore → Rules tab.
// =============================================================================
//
// rules_version = '2';
// service cloud.firestore {
//   match /databases/{database}/documents {
//
//     // ── Helper functions ────────────────────────────────────────────────────
//     function isAuthenticated() {
//       return request.auth != null;
//     }
//
//     function isOwner(uid) {
//       return request.auth != null && request.auth.uid == uid;
//     }
//
//     // ── /users/{uid} ────────────────────────────────────────────────────────
//     // PUBLIC fields (name, phoneNumber, addaCity, profilePhotoUrl, rating)
//     // are readable by any authenticated user (e.g. passengers searching).
//     // WRITE is only allowed by the owner.
//     match /users/{uid} {
//       allow read: if isAuthenticated()
//                   && resource.data.keys().hasOnly([
//                        'uid', 'name', 'phoneNumber', 'addaCity',
//                        'profilePhotoUrl', 'rating', 'role',
//                        'kycComplete', 'hasVehicle', 'primaryVehicleId',
//                        'primaryVehicle', 'updatedAt', 'createdAt',
//                        'carDetails'
//                      ]);
//       allow write: if isOwner(uid);
//
//       // ── /users/{uid}/private/profile ─────────────────────────────────────
//       // PRIVATE fields (email, cnicNumber, cnicPhotoUrl, hasDrivingLicense,
//       // licensePhotoUrl) are ONLY readable by the document owner.
//       match /private/{doc} {
//         allow read, write: if isOwner(uid);
//       }
//
//       // ── /users/{uid}/vehicles/{vehicleId} ───────────────────────────────
//       // PUBLIC vehicle spec fields are readable by authenticated users.
//       // PRIVATE fare metrics (mileageKmPerLitre, fuelPrice,
//       // profitMarginPercentage) are restricted to the owner only.
//       match /vehicles/{vehicleId} {
//         // Any authenticated user can read public specs
//         allow read: if isAuthenticated();
//
//         // Only the owner can write vehicle data
//         allow write: if isOwner(uid);
//
//         // Guard: passengers cannot read private fare fields.
//         // Implement field-level restriction via Cloud Functions
//         // or a dedicated /vehicles/{vehicleId}/private subcollection.
//       }
//
//       // ── /users/{uid}/blocked_dates ───────────────────────────────────────
//       // Only the driver can see or modify their own blocked dates.
//       match /blocked_dates/{dateId} {
//         allow read, write: if isOwner(uid);
//       }
//
//       // ── /users/{uid}/stats/{doc} ─────────────────────────────────────────
//       match /stats/{doc} {
//         allow read: if isOwner(uid);
//         allow write: if false; // Written by Cloud Functions only
//       }
//     }
//
//     // ── /ride_requests/{requestId} ──────────────────────────────────────────
//     // Passengers create requests; drivers (driverId) can read & update status.
//     match /ride_requests/{requestId} {
//       allow create: if isAuthenticated()
//                     && request.resource.data.passengerUid == request.auth.uid;
//
//       allow read:   if isAuthenticated()
//                     && (resource.data.passengerUid == request.auth.uid
//                         || resource.data.driverId   == request.auth.uid);
//
//       allow update: if isAuthenticated()
//                     && resource.data.driverId == request.auth.uid
//                     && request.resource.data.diff(resource.data)
//                          .affectedKeys()
//                          .hasOnly(['status','acceptedAt','declinedAt',
//                                    'cancelledAt','declineReason',
//                                    'cancelReason','completedAt']);
//
//       allow delete: if false;
//     }
//   }
// }
// =============================================================================

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'app/services/auth_service.dart';
import 'app/routes/app_pages.dart';
import 'app/routes/app_routes.dart';
import 'app/core/theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  Get.put(AuthService());

  runApp(const SafarlinkApp());
}

class SafarlinkApp extends StatelessWidget {
  const SafarlinkApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Safarlink',
      theme: AppTheme.lightTheme,
      initialRoute: AppRoutes.SPLASH,
      getPages: AppPages.pages,
      debugShowCheckedModeBanner: false,
    );
  }
}
