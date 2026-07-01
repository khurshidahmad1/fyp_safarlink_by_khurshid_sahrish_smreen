import 'package:get/get.dart';
import '../../../routes/app_routes.dart';
import '../../../services/auth_service.dart';

class RoleController extends GetxController {
  final authService = Get.find<AuthService>();

  Future<void> selectPassengerRole() async {
    await authService.updateUserRole('passenger');
    Get.offAllNamed(AppRoutes.PASSENGER_HOME);
    Get.rawSnackbar(
      title: "Role Selected",
      message: "Entering Safarlink as Passenger",
    );
  }

  Future<void> selectDriverRole() async {
    await authService.updateUserRole('driver');
    Get.offAllNamed(AppRoutes.DRIVER_DASHBOARD);
    Get.rawSnackbar(
      title: "Role Selected",
      message: "Entering Safarlink as Driver",
    );
  }

  Future<void> logout() async {
    await authService.signOut();
    Get.offAllNamed(AppRoutes.AUTH);
    Get.rawSnackbar(
      title: "Logout",
      message: "Logged out successfully",
    );
  }
}
