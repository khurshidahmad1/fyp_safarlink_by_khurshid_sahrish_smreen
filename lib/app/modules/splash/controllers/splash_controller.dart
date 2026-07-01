import 'package:get/get.dart';
import '../../../services/auth_service.dart';
import '../../../services/permission_service.dart';

class SplashController extends GetxController {
  @override
  void onInit() {
    super.onInit();
    _navigateToNext();
  }

  void _navigateToNext() async {
    await Future.delayed(const Duration(seconds: 3));

    // Request runtime permissions before proceeding
    final permissionService = Get.put(PermissionService());
    await permissionService.requestAppPermissions();

    final authService = Get.find<AuthService>();
    await authService.handleAuthRedirect();
  }
}
