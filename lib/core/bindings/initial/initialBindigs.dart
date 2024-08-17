import 'package:get/get.dart';
import 'package:fecrmeal/core/controller/homepageController.dart';

class InitialBinding implements Bindings {
  @override
  void dependencies() async {
    Get.put(HomePageController());
  }
}
