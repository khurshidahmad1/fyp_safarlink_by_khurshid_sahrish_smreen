import 'package:get/get.dart';
import 'passenger_main_wrapper_controller.dart';
import '../home/passenger_home_controller.dart';
import '../bookings/passenger_bookings_controller.dart';
import '../profile/passenger_profile_controller.dart';

class PassengerMainWrapperBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<PassengerMainWrapperController>(
      () => PassengerMainWrapperController(),
    );
    // Bind all child subtab controllers to guarantee they are alive
    Get.lazyPut<PassengerHomeController>(
      () => PassengerHomeController(),
    );
    Get.lazyPut<PassengerBookingsController>(
      () => PassengerBookingsController(),
    );
    Get.lazyPut<PassengerProfileController>(
      () => PassengerProfileController(),
    );
  }
}
