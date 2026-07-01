import 'package:get/get.dart';
import 'passenger_home_controller.dart';

class PassengerHomeBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<PassengerHomeController>(
      () => PassengerHomeController(),
    );
  }
}
