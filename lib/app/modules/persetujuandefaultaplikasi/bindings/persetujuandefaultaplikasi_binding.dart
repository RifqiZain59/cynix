import 'package:get/get.dart';

import '../controllers/persetujuandefaultaplikasi_controller.dart';

class PersetujuandefaultaplikasiBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<PersetujuandefaultaplikasiController>(
      () => PersetujuandefaultaplikasiController(),
    );
  }
}
