import 'package:get/get.dart';
import '../phone_auth_controller.dart';

class PhoneAuthBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<PhoneAuthController>(() => PhoneAuthController());
  }
}
