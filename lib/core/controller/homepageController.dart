import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomePageController extends GetxController {
  RxBool showdialog = false.obs;
  RxBool ayeteGit = false.obs;
  RxBool changeQueue = false.obs;
  
  // Metin Boyutları
  RxDouble yazipuntosu = 16.0.obs;    // Meal Metin
  RxDouble arapcaPuntosu = 24.0.obs;  // Arapça Metin
  RxDouble dipnotPuntosu = 14.0.obs;  // Dipnot Metin
  
  RxBool isContainerVisible = true.obs;
  RxBool arapcametin = true.obs;
  RxBool dipnotlar = true.obs;

  @override
  void onInit() {
    super.onInit();
    _loadSettings();

    // Değişiklikleri otomatik kaydet
    ever(yazipuntosu, (double val) => _saveDouble('font_size', val));
    ever(arapcaPuntosu, (double val) => _saveDouble('arapca_font_size', val));
    ever(dipnotPuntosu, (double val) => _saveDouble('dipnot_font_size', val));
    
    ever(arapcametin, (bool val) => _saveBool('show_arabic', val));
    ever(dipnotlar, (bool val) => _saveBool('show_footnote', val));
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    yazipuntosu.value = (prefs.getDouble('font_size') ?? 16.0).clamp(12.0, 40.0);
    arapcaPuntosu.value = (prefs.getDouble('arapca_font_size') ?? 24.0).clamp(14.0, 50.0);
    dipnotPuntosu.value = (prefs.getDouble('dipnot_font_size') ?? 14.0).clamp(10.0, 30.0);
    
    arapcametin.value = prefs.getBool('show_arabic') ?? true;
    dipnotlar.value = prefs.getBool('show_footnote') ?? true;
  }

  Future<void> _saveDouble(String key, double val) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(key, val);
  }

  Future<void> _saveBool(String key, bool val) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(key, val);
  }
}
