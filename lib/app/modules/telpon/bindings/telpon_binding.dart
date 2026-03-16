import 'package:get/get.dart';

import '../controllers/telpon_controller.dart';

class TelponBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<TelponController>(
      () => TelponController(),
    );
  }
}
