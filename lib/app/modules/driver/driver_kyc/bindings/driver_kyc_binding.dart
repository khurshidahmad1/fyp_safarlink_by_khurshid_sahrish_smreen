import 'package:get/get.dart';
import '../driver_kyc_controller.dart';

class DriverKycBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<DriverKycController>(() => DriverKycController());
  }
}
