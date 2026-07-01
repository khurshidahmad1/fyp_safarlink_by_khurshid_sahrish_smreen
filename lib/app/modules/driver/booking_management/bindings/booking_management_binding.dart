import 'package:get/get.dart';
import '../booking_management_controller.dart';

class BookingManagementBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<BookingManagementController>(() => BookingManagementController());
  }
}
