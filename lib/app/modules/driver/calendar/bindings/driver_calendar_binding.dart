import 'package:get/get.dart';
import '../driver_calendar_controller.dart';

class DriverCalendarBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<DriverCalendarController>(() => DriverCalendarController());
  }
}
