import 'package:get/get.dart';
import 'passenger_bookings_controller.dart';

class PassengerBookingsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<PassengerBookingsController>(
      () => PassengerBookingsController(),
    );
  }
}
