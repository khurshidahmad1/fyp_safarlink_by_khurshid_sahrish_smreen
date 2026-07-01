import 'package:get/get.dart';
import '../vehicle_listing_controller.dart';

class VehicleListingBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<VehicleListingController>(() => VehicleListingController());
  }
}
