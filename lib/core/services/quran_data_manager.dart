import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io' show File;
import 'package:path_provider/path_provider.dart';

class QuranDataManager {
  static const String baseUrl = "https://www.anilakademi.com/kuran_aydinligi_api/";

  static const String quranFileName = "quran_full.json";
  static const String versionFileName = "version.json";
  static const String webJsonCacheKey = "quran_json_cache";

  /// Sunucudaki versiyonu kontrol eder, büyükse güncel json'ı indirir
  static Future<String> checkAndUpdateData({
    void Function(double progress)? onProgress,
  }) async {
    try {
      Dio dio = Dio();

      // 1. Sunucudaki version.json dosyasını çek
      var response = await dio.get("$baseUrl$versionFileName");
      var data = response.data is String ? jsonDecode(response.data) : response.data;
      int serverVersion = data['version'] ?? 0;

      // 2. Cihazda kayıtlı versiyonu al
      SharedPreferences prefs = await SharedPreferences.getInstance();
      int localVersion = await getLocalVersion();

      // 3. Sunucudaki versiyon daha yeniyse, yeni veriyi indir
      if (serverVersion > localVersion) {
        // Web'de 10MB+ veriyi LocalStorage'a (SharedPreferences) yazmak QuotaExceededError verir.
        // Bu yüzden Web'de sadece indirip kontrol ediyoruz, kaydı tarayıcı cache'ine bırakıyoruz.
        var responseJson = await dio.get(
          "$baseUrl$quranFileName",
          onReceiveProgress: (received, total) {
            if (total > 0 && onProgress != null) {
              onProgress(received / total);
            }
          },
        );

        if (!kIsWeb) {
          // Mobil: Dosya sistemine kaydet
          String jsonContent =
              responseJson.data is String ? responseJson.data : jsonEncode(responseJson.data);
          var dir = await getApplicationDocumentsDirectory();
          File file = File("${dir.path}/$quranFileName");
          await file.writeAsString(jsonContent);
        }

        // Versiyonu her durumda kaydet
        await prefs.setInt('quran_version', serverVersion);
        print("Kuran verisi güncellendi! Eski: $localVersion, Yeni: $serverVersion");
        return "updated";
      } else {
        print("Kuran verisi zaten güncel. Mevcut Versiyon: $localVersion");
        return "uptodate";
      }
    } catch (e) {
      print("Kuran verileri güncellenirken hata oluştu: $e");
      return "error";
    }
  }

  /// Cihaza indirilmiş güncel JSON dosyasını okur.
  static Future<String> getQuranJsonString() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();

      if (kIsWeb) {
        // Web: Eğer güncel versiyon varsa, dosyayı URL'den çekiyoruz.
        // Tarayıcı bunu otomatik olarak kendi cache'inden getirecektir.
        if (prefs.containsKey('quran_version')) {
          print("Web: Kuran verisi URL'den çekiliyor (Tarayıcı önbelleği kullanılır).");
          var response = await Dio().get("$baseUrl$quranFileName");
          return response.data is String ? response.data : jsonEncode(response.data);
        }
      } else {
        // Mobil: Dosya sisteminden oku
        var dir = await getApplicationDocumentsDirectory();
        File file = File("${dir.path}/$quranFileName");

        if (await file.exists()) {
          print("Mobil: Kuran verisi cihaz hafızasındaki dosyadan okunuyor.");
          return await file.readAsString();
        }
      }
    } catch (e) {
      print("Önbellek okunamadı veya ağ hatası: $e");
    }

    print("Kuran verisi gömülü asset'ten okunuyor.");
    return await rootBundle.loadString('assets/json/quran_full.json');
  }

  /// Cihazda kayıtlı yerel versiyon numarasını döner.
  static Future<int> getLocalVersion() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      int? saved = prefs.getInt('quran_version');
      if (saved != null) return saved;

      // Assets'teki version.json'dan oku (fabrika değeri)
      String raw = await rootBundle.loadString('assets/json/version.json');
      var decoded = jsonDecode(raw);
      return decoded['version'] ?? 0;
    } catch (_) {
      return 0;
    }
  }

  /// Sunucudaki versiyon numarasını döner. Hata olursa -1 döner.
  static Future<int> getServerVersion() async {
    try {
      Dio dio = Dio();
      var response = await dio.get("$baseUrl$versionFileName");
      var data = response.data is String ? jsonDecode(response.data) : response.data;
      return data['version'] ?? 0;
    } catch (_) {
      return -1;
    }
  }

  /// İndirilmiş veri var mı kontrol eder.
  static Future<bool> isDataDownloaded() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      if (kIsWeb) {
        // Web'de sadece versiyon kaydı var mı diye bakıyoruz
        return prefs.containsKey('quran_version');
      } else {
        var dir = await getApplicationDocumentsDirectory();
        File file = File("${dir.path}/$quranFileName");
        return await file.exists();
      }
    } catch (_) {
      return false;
    }
  }

  /// İndirilmiş veriyi ve kaydedilmiş versiyonu siler.
  static Future<void> deleteLocalData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('quran_version');

    if (kIsWeb) {
      await prefs.remove(webJsonCacheKey);
    } else {
      try {
        var dir = await getApplicationDocumentsDirectory();
        File file = File("${dir.path}/$quranFileName");
        if (await file.exists()) {
          await file.delete();
        }
      } catch (_) {}
    }
    print("Yerel Kuran verisi silindi.");
  }
}
