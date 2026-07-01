import 'package:get/get.dart';
import '../driver_profile_settings_controller.dart';

class DriverProfileSettingsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<DriverProfileSettingsController>(
      () => DriverProfileSettingsController(),
    );
  }
}
