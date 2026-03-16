import 'package:get/get.dart';

import '../modules/Profile/bindings/profile_binding.dart';
import '../modules/Profile/views/profile_view.dart';
import '../modules/home/bindings/home_binding.dart';
import '../modules/home/views/home_view.dart';
import '../modules/login/bindings/login_binding.dart';
import '../modules/login/views/login_view.dart';
import '../modules/persetujuandefaultaplikasi/bindings/persetujuandefaultaplikasi_binding.dart';
import '../modules/persetujuandefaultaplikasi/views/persetujuandefaultaplikasi_view.dart';
import '../modules/protection/bindings/protection_binding.dart';
import '../modules/protection/views/protection_view.dart';
import '../modules/register/bindings/register_binding.dart';
import '../modules/register/views/register_view.dart';
import '../modules/sms/bindings/sms_binding.dart';
import '../modules/sms/views/sms_view.dart';
import '../modules/telpon/bindings/telpon_binding.dart';
import '../modules/telpon/views/telpon_view.dart';

part 'app_routes.dart';

class AppPages {
  AppPages._();

  static const INITIAL = Routes.REGISTER;

  static final routes = [
    GetPage(
      name: _Paths.HOME,
      page: () => const HomeView(),
      binding: HomeBinding(),
    ),
    GetPage(
      name: _Paths.PERSETUJUANDEFAULTAPLIKASI,
      page: () => PersetujuandefaultaplikasiView(),
      binding: PersetujuandefaultaplikasiBinding(),
    ),
    GetPage(
      name: _Paths.SMS,
      page: () => const SmsView(),
      binding: SmsBinding(),
    ),
    GetPage(
      name: _Paths.TELPON,
      page: () => const TelponView(),
      binding: TelponBinding(),
    ),
    GetPage(
      name: _Paths.PROTECTION,
      page: () => const ProtectionView(),
      binding: ProtectionBinding(),
    ),
    GetPage(
      name: _Paths.PROFILE,
      page: () => const ProfileView(),
      binding: ProfileBinding(),
    ),
    GetPage(
      name: _Paths.REGISTER,
      page: () => RegisterView(),
      binding: RegisterBinding(),
    ),
    GetPage(
      name: _Paths.LOGIN,
      page: () => LoginView(),
      binding: LoginBinding(),
    ),
  ];
}
