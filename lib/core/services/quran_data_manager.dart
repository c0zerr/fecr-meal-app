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
      int localVersion = prefs.getInt('quran_version') ?? 0;

      // 3. Sunucudaki versiyon daha yeniyse, yeni veriyi indir
      if (serverVersion > localVersion) {
        var responseJson = await dio.get(
          "$baseUrl$quranFileName",
          onReceiveProgress: (received, total) {
            if (total > 0 && onProgress != null) {
              onProgress(received / total);
            }
          },
        );
        String jsonContent =
            responseJson.data is String ? responseJson.data : jsonEncode(responseJson.data);

        if (kIsWeb) {
          await prefs.setString(webJsonCacheKey, jsonContent);
        } else {
          var dir = await getApplicationDocumentsDirectory();
          File file = File("${dir.path}/$quranFileName");
          await file.writeAsString(jsonContent);
        }

        await prefs.setInt('quran_version', serverVersion);
        print("Kuran verisi güncellendi! Eski: $localVersion, Yeni: $serverVersion");
        return "updated";
      } else {
        print("Kuran verisi zaten güncel. Mevcut Versiyon: $localVersion");
        return "uptodate";
      }
    } catch (e) {
      print("Kuran verileri güncellenirken hata oluştu (CORS, İnternet yok veya yanlış URL): $e");
      return "error";
    }
  }

  /// Cihaza indirilmiş güncel JSON dosyasını okur.
  static Future<String> getQuranJsonString() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();

      if (kIsWeb) {
        String? cachedJson = prefs.getString(webJsonCacheKey);
        if (cachedJson != null) {
          print("Web: Kuran verisi önbellekten (LocalStorage) okunuyor.");
          return cachedJson;
        }
      } else {
        var dir = await getApplicationDocumentsDirectory();
        File file = File("${dir.path}/$quranFileName");

        if (await file.exists()) {
          print("Mobil: Kuran verisi cihaz hafızasındaki dosyadan okunuyor.");
          return await file.readAsString();
        }
      }
    } catch (e) {
      print("Önbellek okunamadı: $e");
    }

    print("Kuran verisi gömülü asset'ten okunuyor.");
    return await rootBundle.loadString('assets/json/quran_full.json');
  }

  /// Cihazda kayıtlı yerel versiyon numarasını döner.
  /// SharedPreferences'ta kayıt yoksa assets/json/version.json'dan okur.
  static Future<int> getLocalVersion() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int? saved = prefs.getInt('quran_version');
    if (saved != null) return saved;

    // Assets'teki version.json'dan oku (fabrika değeri)
    try {
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
      if (kIsWeb) {
        SharedPreferences prefs = await SharedPreferences.getInstance();
        return prefs.containsKey(webJsonCacheKey);
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
