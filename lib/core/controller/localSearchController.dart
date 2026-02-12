import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

class NormalizedResult {
  final String text;
  final List<int> indices;
  NormalizedResult(this.text, this.indices);
}

class LocalSearchController extends GetxController {
  var isLoading = true.obs;
  var allVerses = <Map<String, dynamic>>[].obs;
  var filteredVerses = <Map<String, dynamic>>[].obs;
  var currentQuery = "".obs;
  var matchedSurah = Rx<Map<String, dynamic>?>(null);
  var surahList = <Map<String, dynamic>>[].obs;

  @override
  void onInit() {
    super.onInit();
    print("LocalSearchController Initialized");
    loadJsonData();
  }

  Future<void> loadJsonData() async {
    try {
      print("Loading JSON data...");
      final String response =
          await rootBundle.loadString('assets/json/quran_full.json');
      print("JSON loaded, decoding...");
      final data = await json.decode(response) as List<dynamic>;
      print("JSON decoded, processing ${data.length} surahs...");

      List<Map<String, dynamic>> verses = [];
      List<Map<String, dynamic>> surahs = [];

      for (var sure in data) {
        String sureAdi = sure['sure_adi'] ?? sure['sureadi'];
        surahs.add({
          'sure_adi': sureAdi,
          'normalized_name': normalize(sureAdi),
          'strict_name': strictNormalize(sureAdi),
          // İlk ayetin numarası genellikle 1'dir ama sure okumaya giderken sure adı yeterli
        });

        if (sure['verses'] != null) {
          for (var verse in sure['verses']) {
            // 0. ayetler (sure açıklamaları) arama sonuçlarına dahil edilmesin
            if (verse['ayetno'] == 0) continue;

            verses.add({
              'sure_adi': verse['sure_adi'] ?? sure['sureadi'],
              'ayetno': verse['ayetno'],
              'metin': verse['metin'],
              'meal': (verse['meal'] as String)
                  .replaceAll(RegExp(r'\[\w+:\d+.*?\]'), ''),
              'search_text': normalize(
                  "${verse['sure_adi']} ${verse['metin']} ${verse['meal']}"),
            });
          }
        }
      }

      print("Processed ${verses.length} total verses.");
      allVerses.assignAll(verses);
      surahList.assignAll(surahs);
      isLoading.value = false;
    } catch (e) {
      print("Error loading JSON: $e");
      isLoading.value = false;
    }
  }

  void search(String query) {
    print("Searching for: $query");
    currentQuery.value = query;
    matchedSurah.value = null; // Her aramada sıfırla

    if (query.isEmpty) {
      filteredVerses.clear();
      return;
    }

    String normalizedQuery = normalize(query);

    // 1. KURAL: Sure Adı + Ayet No (Örn: "Bakara 55")
    // Regex: (harflerden oluşan sure adı) (boşluk) (rakamlar)
    RegExp sureAyetRegex = RegExp(r"^([a-zA-ZçğıöşüÇĞİÖŞÜ']+)\s+(\d+)$");
    Match? match = sureAyetRegex.firstMatch(query);

    if (match != null) {
      String sureInput = match.group(1)!;
      String ayetNoInput = match.group(2)!;
      String normalizedSureInput = normalize(sureInput);

      // Sureyi bul
      var foundSurah = surahList.firstWhereOrNull((s) =>
          s['normalized_name'] == normalizedSureInput ||
          s['normalized_name'].toString().startsWith(normalizedSureInput));

      if (foundSurah != null) {
        int ayetNo = int.tryParse(ayetNoInput) ?? 0;

        // O surenin o ayetini bul
        var result = allVerses.where((verse) {
          return normalize(verse['sure_adi']) ==
                  foundSurah['normalized_name'] &&
              verse['ayetno'] == ayetNo;
        }).toList();

        if (result.isNotEmpty) {
          filteredVerses.assignAll(result);
          // Bu durumda sure chip'i göstermeye gerek yok, doğrudan ayet bulundu
          return;
        }
      }
    }

    // 2. KURAL: Sadece Sure Adı (Örn: "Bakara", "ali imran")
    // Tam eşleşme veya başlangıç eşleşmesi (Boşluksuz/Strict karşılaştırma)
    String strictQuery = strictNormalize(query);

    var exactSurah = surahList.firstWhereOrNull((s) =>
        s['strict_name'] == strictQuery ||
        s['strict_name'].toString().startsWith(strictQuery));

    if (exactSurah != null) {
      matchedSurah.value = exactSurah;
      filteredVerses
          .clear(); // Kullanıcı sadece sureye gitmek istiyor olabilir, listeyi temizle
      return; // Aramayı burada bitir
    } else {
      // Kısmi eşleşme (kullanıcı yazmaya devam ediyor olabilir)
      // Ama chip sadece anlamlı bir eşleşme varsa çıksın
      // Şimdilik sadece tam eşleşme veya çok yakın eşleşme mantıklı
    }

    // 3. KURAL: Normal Arama (Mevcut Mantık)
    // Kelime sınırı kuralı: \bquery\b
    RegExp regExp = RegExp(r'\b' + RegExp.escape(normalizedQuery) + r'\b');

    var results = allVerses.where((verse) {
      return regExp.hasMatch(verse['search_text']);
    }).toList();

    print("Found ${results.length} results.");
    filteredVerses.assignAll(results);
  }

  /// Metni normalize eder (Arama kurallarına göre)
  /// [returnStringOnly]: true ise sadece String döner, false ise NormalizedResult döner (mapping için)
  static dynamic normalize(String text, {bool returnStringOnly = true}) {
    StringBuffer buffer = StringBuffer();
    List<int> indices = [];

    for (int i = 0; i < text.length; i++) {
      String char = text[i];

      // 1. & 2. Adım: Türkçe locale ile küçük harfe çevirme (I/İ dönüşümü)
      String lowerChar;
      if (char == 'İ') {
        lowerChar = 'i';
      } else if (char == 'I')
        lowerChar = 'ı';
      else
        lowerChar = char.toLowerCase();

      // 3. Adım: Türkçe harf sadeleştirmesi ve Aksan temizliği
      String simpleChar = lowerChar;
      switch (lowerChar) {
        case 'ç':
          simpleChar = 'c';
          break;
        case 'ğ':
          simpleChar = 'g';
          break;
        case 'ı':
          simpleChar = 'i';
          break;
        case 'ö':
          simpleChar = 'o';
          break;
        case 'ş':
          simpleChar = 's';
          break;
        case 'ü':
          simpleChar = 'u';
          break;
        case 'â':
          simpleChar = 'a';
          break;
        case 'î':
          simpleChar = 'i';
          break;
        case 'û':
          simpleChar = 'u';
          break;
        case 'ô':
          simpleChar = 'o';
          break;
        case 'ê':
          simpleChar = 'e';
          break;
      }

      // 4. Adım: Kesme işaretlerini sil (Buffer'a ekleme)
      if (RegExp(r"['’‘`ʼ]").hasMatch(simpleChar)) {
        continue;
      }

      // 5. Adım: Harf ve rakam olmayan tüm karakterleri boşluk yap
      if (RegExp(r"[^a-z0-9]").hasMatch(simpleChar)) {
        simpleChar = ' ';
      }

      // 6. Adım: Birden fazla boşluğu teke indir
      if (simpleChar == ' ') {
        if (buffer.length > 0 && buffer.toString().endsWith(' ')) {
          continue; // Önceki karakter zaten boşluksa ekleme
        }
        // Eğer buffer boşsa (metin başı) boşluk ekleme
        if (buffer.isEmpty) {
          continue;
        }
      }

      buffer.write(simpleChar);
      indices.add(i);
    }

    // Sondaki boşluğu temizle
    if (buffer.isNotEmpty && buffer.toString().endsWith(' ')) {
      String s = buffer.toString();
      buffer.clear();
      buffer.write(s.substring(0, s.length - 1));
      indices.removeLast();
    }

    if (returnStringOnly) {
      return buffer.toString();
    } else {
      return NormalizedResult(buffer.toString(), indices);
    }
  }

  /// Boşlukları da kaldıran daha katı bir normalizasyon (Sure eşleşmeleri için)
  static String strictNormalize(String text) {
    String normalized = normalize(text);
    return normalized.replaceAll(' ', '');
  }
}
