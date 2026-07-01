import 'package:get/get.dart';
import 'passenger_dashboard_controller.dart';

class PassengerDashboardBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<PassengerDashboardController>(
      () => PassengerDashboardController(),
    );
  }
}
