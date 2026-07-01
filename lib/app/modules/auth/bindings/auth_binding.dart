import 'package:get/get.dart';
import '../login/login_controller.dart';
import '../role_selection/role_controller.dart';

class AuthBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<LoginController>(() => LoginController());
    Get.lazyPut<RoleController>(() => RoleController());
  }
}
