import 'package:get/get.dart';
import 'passenger_booking_setup_controller.dart';

class PassengerBookingSetupBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<PassengerBookingSetupController>(
      () => PassengerBookingSetupController(),
    );
  }
}
