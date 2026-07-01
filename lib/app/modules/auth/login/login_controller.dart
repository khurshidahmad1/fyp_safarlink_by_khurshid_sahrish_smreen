import 'package:get/get.dart';
import '../../../services/auth_service.dart';

class LoginController extends GetxController {
  final authService = Get.find<AuthService>();
  
  final RxBool isLoadingGoogle = false.obs;
  final RxBool isLoadingPhone = false.obs;

  void loginWithPhone() {
    navigateToPhoneAuth();
  }
  
  void navigateToPhoneAuth() {
    Get.toNamed('/otp');
  }

  Future<void> loginWithGoogle() async {
    isLoadingGoogle.value = true;
    try {
      final userCredential = await authService.signInWithGoogle();
      if (userCredential != null) {
        await authService.handleAuthRedirect();
      }
    } finally {
      isLoadingGoogle.value = false;
    }
  }

  void loginWithEmail() {
    // TODO: Implement email authentication logic
    Get.rawSnackbar(title: "Authentication", message: "Email login clicked");
  }

  void showTermsAndPrivacy() {
    // TODO: Navigate to terms and privacy page
    Get.rawSnackbar(title: "Info", message: "Terms & Privacy clicked");
  }
}
