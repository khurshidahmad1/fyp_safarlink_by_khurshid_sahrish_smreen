import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../routes/app_routes.dart';

class AuthService extends GetxService {
  FirebaseAuth auth = FirebaseAuth.instance;
  GoogleSignIn googleSignIn = GoogleSignIn();
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  final Rx<User?> firebaseUser = Rx<User?>(null);
  var verificationId = ''.obs;

  @override
  void onInit() {
    super.onInit();
    firebaseUser.bindStream(auth.authStateChanges());
  }

  Future<void> signOut() async {
    try {
      await auth.signOut();
      await googleSignIn.signOut();
    } catch (e) {
      Get.snackbar('Error', e.toString(), snackPosition: SnackPosition.BOTTOM);
    }
  }

  Future<void> handleAuthRedirect() async {
    final User? user = auth.currentUser;
    if (user == null) {
      Get.offAllNamed(AppRoutes.AUTH);
      return;
    }

    try {
      final doc = await firestore.collection('users').doc(user.uid).get();
      if (doc.exists) {
        final data = doc.data();
        final role = data?['role'];
        if (role == 'passenger') {
          Get.offAllNamed(AppRoutes.PASSENGER_HOME);
        } else if (role == 'driver') {
          Get.offAllNamed(AppRoutes.DRIVER_DASHBOARD);
        } else {
          Get.offAllNamed(AppRoutes.ROLE_SELECTION);
        }
      } else {
        // Create user document if it doesn't exist
        await firestore.collection('users').doc(user.uid).set({
          'uid': user.uid,
          'email': user.email,
          'phone': user.phoneNumber,
          'name': user.displayName ?? user.email?.split('@')[0] ?? 'User',
          'role': null,
          'createdAt': FieldValue.serverTimestamp(),
        });
        Get.offAllNamed(AppRoutes.ROLE_SELECTION);
      }
    } catch (e) {
      Get.offAllNamed(AppRoutes.ROLE_SELECTION);
    }
  }

  Future<void> updateUserRole(String role) async {
    final User? user = auth.currentUser;
    if (user != null) {
      await firestore.collection('users').doc(user.uid).update({
        'role': role,
      });
    }
  }

  Future<UserCredential?> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();
      if (googleUser == null) return null;
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      return await auth.signInWithCredential(credential);
    } catch (e) {
      Get.snackbar('Error', e.toString());
      return null;
    }
  }

  Future<void> sendOTP(String phoneNumber) async {
    try {
      await auth.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        verificationCompleted: (PhoneAuthCredential credential) async {
          await auth.signInWithCredential(credential);
        },
        verificationFailed: (FirebaseAuthException e) {
          Get.snackbar(
            'Error',
            e.message ?? 'Phone verification failed',
            snackPosition: SnackPosition.BOTTOM,
          );
        },
        codeSent: (String verId, int? resendToken) {
          verificationId.value = verId;
          Get.toNamed(AppRoutes.OTP_VERIFY);
        },
        codeAutoRetrievalTimeout: (String verId) {
          verificationId.value = verId;
        },
      );
    } catch (e) {
      Get.snackbar('Error', e.toString(), snackPosition: SnackPosition.BOTTOM);
    }
  }

  Future<bool> verifyOTP(String smsCode) async {
    try {
      final AuthCredential credential = PhoneAuthProvider.credential(
        verificationId: verificationId.value,
        smsCode: smsCode,
      );
      final UserCredential userCredential = await auth.signInWithCredential(credential);
      return userCredential.user != null;
    } catch (e) {
      Get.snackbar('Error', e.toString(), snackPosition: SnackPosition.BOTTOM);
      return false;
    }
  }

  Future<UserCredential?> registerWithEmail(String email, String password) async {
    try {
      final credential = await auth.createUserWithEmailAndPassword(email: email, password: password);
      if (credential.user != null) {
        await firestore.collection('users').doc(credential.user!.uid).set({
          'uid': credential.user!.uid,
          'email': email,
          'phone': null,
          'name': email.split('@')[0],
          'role': null,
          'createdAt': FieldValue.serverTimestamp(),
        });
      }
      return credential;
    } catch (e) {
      Get.snackbar('Error', e.toString(), snackPosition: SnackPosition.BOTTOM);
      return null;
    }
  }

  Future<UserCredential?> loginWithEmail(String email, String password) async {
    try {
      return await auth.signInWithEmailAndPassword(email: email, password: password);
    } catch (e) {
      Get.snackbar('Error', e.toString(), snackPosition: SnackPosition.BOTTOM);
      return null;
    }
  }
}
