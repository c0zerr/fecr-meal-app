import 'package:fecrmeal/core/constants/color_constants.dart';
import 'package:fecrmeal/core/controller/localSearchController.dart';
import 'package:fecrmeal/core/constants/navigation_constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

class SearchPage extends StatelessWidget {
  const SearchPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Get.find ile mevcut controller'ı al (uygulama başlangıcında yüklendi)
    final LocalSearchController controller = Get.find<LocalSearchController>();

    return Scaffold(
      backgroundColor: ColorConstants.primaryColor,
      appBar: AppBar(
        backgroundColor: ColorConstants.primaryColor,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          "Arama",
          style: TextStyle(
            color: Colors.white,
            fontFamily: 'Podkova',
            fontWeight: FontWeight.w700,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.maybePop(context),
        ),
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h),
        child: Column(
          children: [
            TextField(
              onChanged: (value) => controller.search(value),
              onSubmitted: (value) => controller.search(value),
              decoration: InputDecoration(
                hintText: 'Sure veya Ayet ara...',
                hintStyle: const TextStyle(
                  color: Colors.grey,
                  fontFamily: 'Podkova',
                ),
                filled: true,
                fillColor: Colors.white,
                prefixIcon: const Icon(Icons.search,
                    color: ColorConstants.primaryColor),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: BorderSide.none,
                ),
                contentPadding:
                    EdgeInsets.symmetric(vertical: 15.h, horizontal: 20.w),
              ),
              style: const TextStyle(
                color: Colors.black,
                fontFamily: 'Podkova',
                fontSize: 16,
              ),
            ),
            SizedBox(height: 20.h),

            // Arama İstatistikleri (X kelimesi Y surede Z kere geçiyor)
            Obx(() {
              if (controller.filteredVerses.isNotEmpty && controller.currentQuery.value.isNotEmpty) {
                return Padding(
                  padding: EdgeInsets.only(bottom: 20.h),
                  child: RichText(
                    textAlign: TextAlign.center,
                    text: TextSpan(
                      style: const TextStyle(
                        color: Colors.white,
                        fontFamily: 'Podkova',
                        fontSize: 16,
                      ),
                      children: [
                        TextSpan(
                          text: '"${controller.currentQuery.value}"',
                          style: const TextStyle(fontWeight: FontWeight.normal),
                        ),
                        const TextSpan(text: ' kelimesi '),
                        TextSpan(
                          text: '${controller.uniqueSurahCount.value}',
                          style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFFFFF176)), // Sarı Vurgu
                        ),
                        const TextSpan(text: ' surede toplam '),
                        TextSpan(
                          text: '${controller.filteredVerses.length}',
                          style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFFFFF176)), // Sarı Vurgu
                        ),
                        const TextSpan(text: ' kere geçiyor.'),
                      ],
                    ),
                  ),
                );
              }
              return const SizedBox.shrink();
            }),

            // Sure Eşleşme Chip'i (Eğer varsa)
            Obx(() {
              if (controller.matchedSurah.value != null) {
                return Padding(
                  padding: EdgeInsets.only(bottom: 20.h),
                  child: GestureDetector(
                    onTap: () {
                      // Sureye git
                      Get.toNamed(NavigationConstants.sureOkuPage, arguments: [
                        controller.matchedSurah.value!['sure_adi'],
                        1
                      ] // 1. ayetten başla
                          );
                    },
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Container(
                        // Figma Frame 615 özellikleri
                        // width: 150px (Metne göre esnemesi için min-width veya içeriğe bağlı bırakıyoruz, padding ile destekliyoruz)
                        height: 40.h,
                        padding: EdgeInsets.symmetric(horizontal: 15.w),
                        decoration: BoxDecoration(
                          color: const Color(0xFF2B89A5), // #2b89a5
                          borderRadius:
                              BorderRadius.circular(10), // 10px radius
                        ),
                        child: Row(
                          mainAxisSize:
                              MainAxisSize.min, // İçeriği kadar yer kapla
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "${controller.matchedSurah.value!['sure_adi']} Suresi",
                              style: const TextStyle(
                                color: Colors.white,
                                fontFamily: 'Axiforma', // Figma'daki font
                                fontSize: 18,
                                letterSpacing: 0,
                                height: 1.0, // line-height hizalaması için
                              ),
                            ),
                            SizedBox(width: 8.w), // İkon ile metin arası boşluk
                            const Icon(
                              Icons.arrow_forward_ios,
                              size: 14,
                              color: Colors.white,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              }
              return const SizedBox.shrink();
            }),

            Expanded(
              child: Obx(() {
                if (controller.isLoading.value) {
                  return const Center(
                      child: CircularProgressIndicator(color: Colors.white));
                }

                if (controller.filteredVerses.isEmpty) {
                  return const Center(
                    child: Text(
                      "",
                      style: TextStyle(color: Colors.white70),
                    ),
                  );
                }

                return ListView.builder(
                  itemCount: controller.filteredVerses.length,
                  itemBuilder: (context, index) {
                    var verse = controller.filteredVerses[index];
                    return GestureDetector(
                      onTap: () {
                        // Ayet detayına gitmek için
                        Get.toNamed(NavigationConstants.sureOkuPage,
                            arguments: [verse['sure_adi'], verse['ayetno']]);
                      },
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 20.0),
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 15, vertical: 20),
                          clipBehavior: Clip.antiAlias,
                          decoration: ShapeDecoration(
                            color: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                            shadows: const [
                              BoxShadow(
                                color: Color(0x26000000),
                                blurRadius: 10,
                                offset: Offset(4, 4),
                                spreadRadius: 0,
                              )
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    "${verse['sure_adi']} - ${verse['ayetno']}. Ayet",
                                    style: const TextStyle(
                                      color: ColorConstants.primaryColor,
                                      fontWeight: FontWeight.bold,
                                      fontFamily: 'Podkova',
                                      fontSize: 22,
                                    ),
                                  ),
                                  const Icon(Icons.arrow_forward_ios,
                                      size: 16,
                                      color: ColorConstants.primaryColor),
                                ],
                              ),
                              SizedBox(height: 10.h),
                              SizedBox(height: 10.h),
                              Obx(() => RichText(
                                    text: TextSpan(
                                      children: _highlightText(
                                        verse['meal'] ?? "",
                                        controller.currentQuery.value,
                                      ),
                                      style: const TextStyle(
                                        color: Colors.black87,
                                        fontFamily: 'Podkova',
                                        fontSize: 26,
                                      ),
                                    ),
                                  )),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  List<TextSpan> _highlightText(String text, String query) {
    if (query.isEmpty) {
      return [TextSpan(text: text)];
    }

    // 1. Metni normalize et ve mapping al
    var normResult =
        LocalSearchController.normalize(text, returnStringOnly: false)
            as NormalizedResult;
    String normText = normResult.text;

    // 2. Sorguyu normalize et
    String normQuery = LocalSearchController.normalize(query);
    if (normQuery.isEmpty) return [TextSpan(text: text)];

    List<TextSpan> spans = [];
    int currentOriginalIndex = 0;

    // 3. Regex ile eşleşmeleri bul (Kelime sınırı kuralı)
    RegExp regex = RegExp(r'\b' + RegExp.escape(normQuery) + r'\b');
    Iterable<Match> matches = regex.allMatches(normText);

    for (Match match in matches) {
      // Mapping kullanarak orijinal indeksleri bul
      int normStart = match.start;
      int normEnd = match.end;

      if (normStart >= normResult.indices.length) continue;

      int originalStart = normResult.indices[normStart];

      // Bitiş indeksi hesabı:
      int lastCharNormIndex = normEnd - 1;
      if (lastCharNormIndex >= normResult.indices.length) {
        lastCharNormIndex = normResult.indices.length - 1;
      }

      int originalEnd = normResult.indices[lastCharNormIndex] + 1;

      // Highlight öncesi metin
      if (originalStart > currentOriginalIndex) {
        spans.add(TextSpan(
            text: text.substring(currentOriginalIndex, originalStart)));
      }

      // Highlight edilen metin
      spans.add(TextSpan(
        text: text.substring(originalStart, originalEnd),
        style: const TextStyle(
          backgroundColor: Color(0xFFFFF176),
          fontWeight: FontWeight.bold,
        ),
      ));

      currentOriginalIndex = originalEnd;
    }

    // Kalan metin
    if (currentOriginalIndex < text.length) {
      spans.add(TextSpan(text: text.substring(currentOriginalIndex)));
    }

    return spans;
  }
}
