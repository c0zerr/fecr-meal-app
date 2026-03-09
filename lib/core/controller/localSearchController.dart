import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

class NormalizedResult {
  final String text;
  final List<int> indices;
  NormalizedResult(this.text, this.indices);
}

// Isolate'te kullanılabilmesi için top-level normalize fonksiyonu
String _normalizeText(String text) {
  StringBuffer buffer = StringBuffer();
  for (int i = 0; i < text.length; i++) {
    String char = text[i];
    String lowerChar;
    if (char == 'İ') {
      lowerChar = 'i';
    } else if (char == 'I') {
      lowerChar = 'ı';
    } else {
      lowerChar = char.toLowerCase();
    }

    String simpleChar = lowerChar;
    switch (lowerChar) {
      case 'ç': simpleChar = 'c'; break;
      case 'ğ': simpleChar = 'g'; break;
      case 'ı': simpleChar = 'i'; break;
      case 'ö': simpleChar = 'o'; break;
      case 'ş': simpleChar = 's'; break;
      case 'ü': simpleChar = 'u'; break;
      case 'â': simpleChar = 'a'; break;
      case 'î': simpleChar = 'i'; break;
      case 'û': simpleChar = 'u'; break;
      case 'ô': simpleChar = 'o'; break;
      case 'ê': simpleChar = 'e'; break;
    }

    if (RegExp(r"['''`ʼ]").hasMatch(simpleChar)) continue;
    if (RegExp(r"[^a-z0-9]").hasMatch(simpleChar)) simpleChar = ' ';
    if (simpleChar == ' ') {
      if (buffer.isEmpty || buffer.toString().endsWith(' ')) continue;
    }
    buffer.write(simpleChar);
  }
  String result = buffer.toString();
  if (result.endsWith(' ')) result = result.substring(0, result.length - 1);
  return result;
}

// compute() için top-level fonksiyon (isolate'te çalışır)
List<Map<String, dynamic>> _parseQuranJson(String jsonString) {
  final data = json.decode(jsonString) as List<dynamic>;

  List<Map<String, dynamic>> verses = [];
  List<Map<String, dynamic>> surahs = [];

  for (var sure in data) {
    String sureAdi = sure['sure_adi'] ?? sure['sureadi'];
    final normName = _normalizeText(sureAdi);
    surahs.add({
      'sure_adi': sureAdi,
      'normalized_name': normName,
      'strict_name': normName.replaceAll(' ', ''),
    });

    if (sure['verses'] != null) {
      for (var verse in sure['verses']) {
        if (verse['ayetno'] == 0) continue;

        final meal = (verse['meal'] as String)
            .replaceAll(RegExp(r'\[\w+:\d+.*?\]'), '');
        verses.add({
          'sure_adi': verse['sure_adi'] ?? sure['sureadi'],
          'ayetno': verse['ayetno'],
          'metin': verse['metin'],
          'meal': meal,
          'search_text': _normalizeText(meal),
          '_surahMeta': sureAdi,
        });
      }
    }
  }

  return [...surahs.map((s) => {...s, '_type': 'surah'}), ...verses];
}

class LocalSearchController extends GetxController {
  var isLoading = true.obs;
  var allVerses = <Map<String, dynamic>>[].obs;
  var filteredVerses = <Map<String, dynamic>>[].obs;
  var currentQuery = "".obs;
  var matchedSurah = Rx<Map<String, dynamic>?>(null);
  var surahList = <Map<String, dynamic>>[].obs;
  var uniqueSurahCount = 0.obs;

  @override
  void onInit() {
    super.onInit();
    loadJsonData();
  }

  Future<void> loadJsonData() async {
    try {
      final String response =
          await rootBundle.loadString('assets/json/quran_full.json');

      // compute() ile JSON parsing'i ayrı isolate'e taşı
      final result = await compute(_parseQuranJson, response);

      final surahs = result.where((e) => e['_type'] == 'surah').map((e) {
        final copy = Map<String, dynamic>.from(e);
        copy.remove('_type');
        return copy;
      }).toList();

      final verses = result.where((e) => e['_type'] == null).map((e) {
        final copy = Map<String, dynamic>.from(e);
        copy.remove('_surahMeta');
        return copy;
      }).toList();

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
      // Listenin kelime aramasıyla dolmaya devam etmesi için artık temizlemiyoruz ve return etmiyoruz.
    }
 else {
      // Kısmi eşleşme (kullanıcı yazmaya devam ediyor olabilir)
      // Ama chip sadece anlamlı bir eşleşme varsa çıksın
      // Şimdilik sadece tam eşleşme veya çok yakın eşleşme mantıklı
    }

    // 3. KURAL: Gelişmiş Arama (Tam Eşleşme + Kelime Bazlı Arama)
    // Önce Tam Öbek Eşleşmesi (Exact Phrase)
    RegExp exactPhraseRegex = RegExp(r'\b' + RegExp.escape(normalizedQuery) + r'\b');
    
    var exactMatches = allVerses.where((verse) {
      return exactPhraseRegex.hasMatch(verse['search_text']);
    }).toList();

    // Sonra Kelime Kelime Arama (Tüm kelimeler var mı?)
    // Eğer sorgu birden fazla kelime içeriyorsa
    List<String> queryWords = normalizedQuery.split(' ').where((s) => s.isNotEmpty).toList();
    List<Map<String, dynamic>> multiWordMatches = [];

    if (queryWords.length > 1) {
      multiWordMatches = allVerses.where((verse) {
        // Zaten tam eşleşmede varsa tekrar ekleme
        if (exactPhraseRegex.hasMatch(verse['search_text'])) return false;

        // Tüm kelimeler geçiyor mu? (Her kelime için kelime sınırı \b kontrolü)
        return queryWords.every((word) {
           return RegExp(r'\b' + RegExp.escape(word) + r'\b').hasMatch(verse['search_text']);
        });
      }).toList();
    }

    // Sonuçları birleştir (Önce tam eşleşmeler, sonra kelime bazlı eşleşmeler)
    List<Map<String, dynamic>> combinedResults = [...exactMatches, ...multiWordMatches];

    print("Found ${combinedResults.length} results.");
    filteredVerses.assignAll(combinedResults);

    // İstatistikleri Hesapla
    if (combinedResults.isNotEmpty) {
      Set<String> uniqueSurahs = combinedResults.map((verse) => verse['sure_adi'].toString()).toSet();
      uniqueSurahCount.value = uniqueSurahs.length;
    } else {
      uniqueSurahCount.value = 0;
    }
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
