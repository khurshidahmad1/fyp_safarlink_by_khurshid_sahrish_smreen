import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../services/auth_service.dart';

class PhoneAuthController extends GetxController {
  final authService = Get.find<AuthService>();
  
  final phoneController = TextEditingController();
  final otpController = TextEditingController();
  
  final RxBool isLoading = false.obs;

  @override
  void onClose() {
    phoneController.dispose();
    otpController.dispose();
    super.onClose();
  }

  Future<void> sendOtp() async {
    final phone = phoneController.text.trim();
    if (phone.isEmpty) {
      Get.snackbar('Error', 'Please enter your phone number', snackPosition: SnackPosition.BOTTOM);
      return;
    }
    isLoading.value = true;
    try {
      await authService.sendOTP(phone);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> verifyOtp() async {
    final otp = otpController.text.trim();
    if (otp.isEmpty || otp.length < 6) {
      Get.snackbar('Error', 'Please enter a valid 6-digit OTP', snackPosition: SnackPosition.BOTTOM);
      return;
    }
    isLoading.value = true;
    try {
      final success = await authService.verifyOTP(otp);
      if (success) {
        await authService.handleAuthRedirect();
      }
    } finally {
      isLoading.value = false;
    }
  }
}
