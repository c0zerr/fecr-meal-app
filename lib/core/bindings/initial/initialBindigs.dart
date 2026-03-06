import 'package:get/get.dart';
import 'package:fecrmeal/core/controller/homepageController.dart';
import 'package:fecrmeal/core/controller/localSearchController.dart';

class InitialBinding implements Bindings {
  @override
  void dependencies() async {
    Get.put(HomePageController());
    // Arama ekranı açılmadan önce JSON yüklensin diye permanent:true ile başlatıyoruz
    Get.put(LocalSearchController(), permanent: true);
  }
}
