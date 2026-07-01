import 'package:get/get.dart';
import '../trip_manager_controller.dart';

class TripManagerBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<TripManagerController>(() => TripManagerController());
  }
}
