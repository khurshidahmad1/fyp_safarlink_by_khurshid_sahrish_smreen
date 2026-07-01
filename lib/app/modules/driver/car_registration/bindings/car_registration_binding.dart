import 'package:get/get.dart';
import '../car_registration_controller.dart';

class CarRegistrationBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<CarRegistrationController>(() => CarRegistrationController());
  }
}
