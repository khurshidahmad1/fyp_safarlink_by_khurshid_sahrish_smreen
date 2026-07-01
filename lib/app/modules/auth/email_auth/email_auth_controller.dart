import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../services/auth_service.dart';

class EmailAuthController extends GetxController {
  final authService = Get.find<AuthService>();
  
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  
  final RxBool isLoginMode = true.obs;
  final RxBool isLoading = false.obs;

  @override
  void onClose() {
    emailController.dispose();
    passwordController.dispose();
    super.onClose();
  }

  void toggleMode() {
    isLoginMode.value = !isLoginMode.value;
  }

  Future<void> authenticate() async {
    final email = emailController.text.trim();
    final password = passwordController.text.trim();
    
    if (email.isEmpty || password.isEmpty) {
      Get.snackbar('Error', 'Please fill all fields', snackPosition: SnackPosition.BOTTOM);
      return;
    }
    
    isLoading.value = true;
    try {
      final credential = isLoginMode.value
          ? await authService.loginWithEmail(email, password)
          : await authService.registerWithEmail(email, password);
          
      if (credential != null) {
        await authService.handleAuthRedirect();
      }
    } finally {
      isLoading.value = false;
    }
  }
}
