import 'package:get/get.dart';

import '../modules/home/bindings/home_binding.dart';
import '../modules/home/views/home_view.dart';
import '../modules/persetujuandefaultaplikasi/bindings/persetujuandefaultaplikasi_binding.dart';
import '../modules/persetujuandefaultaplikasi/views/persetujuandefaultaplikasi_view.dart';
import '../modules/sms/bindings/sms_binding.dart';
import '../modules/sms/views/sms_view.dart';

part 'app_routes.dart';

class AppPages {
  AppPages._();

  static const INITIAL = Routes.PERSETUJUANDEFAULTAPLIKASI;

  static final routes = [
    GetPage(
      name: _Paths.HOME,
      page: () => const HomeView(),
      binding: HomeBinding(),
    ),
    GetPage(
      name: _Paths.PERSETUJUANDEFAULTAPLIKASI,
      page: () => const PersetujuandefaultaplikasiView(),
      binding: PersetujuandefaultaplikasiBinding(),
    ),
    GetPage(
      name: _Paths.SMS,
      page: () => const SmsView(),
      binding: SmsBinding(),
    ),
  ];
}
