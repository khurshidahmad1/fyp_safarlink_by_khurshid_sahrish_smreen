import 'package:get/get.dart';
import '../requests_controller.dart';

class RequestsHubBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<RequestsHubController>(() => RequestsHubController());
  }
}
