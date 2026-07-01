import 'package:get/get.dart';
import '../my_vehicles_list_controller.dart';

class MyVehiclesListBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<MyVehiclesListController>(() => MyVehiclesListController());
  }
}
