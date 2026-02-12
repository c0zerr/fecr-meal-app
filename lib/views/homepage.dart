
import 'package:fecrmeal/core/constants/color_constants.dart';
import 'package:fecrmeal/core/constants/navigation_constants.dart';
import 'package:fecrmeal/core/controller/homepageController.dart';
import 'package:fecrmeal/core/data/sureList.dart';
import 'package:fecrmeal/core/data/surelist2.dart';
import 'package:fecrmeal/views/pdfviewer/pdfviewer.dart';
import 'package:fecrmeal/widgets/customappbar.dart';
import 'package:fecrmeal/widgets/customdrawer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:url_launcher/url_launcher_string.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  HomePageController homePageController = Get.put(HomePageController());

  final Map<String, String> surahMap = {
    "En’âm": "en'am",
    "enam": "en'am",
    "en'am": "en'am",
    "en’am": "en'am",
    "en-am": "en'am",
    "en'âm": "en'am",
    "en’âm": "en'am",
    "ali imran": "Âl-i İmran",
    "âli imran": "Âl-i İmran",
    "al'i imran": "Âl-i İmran",
    "al’i imran": "Âl-i İmran",
    "al-i imran": "Âl-i İmran",
    "a'raf": "a'raf",
    "a’raf": "a'raf",
    "araf": "a'raf",
    "hûd": "Hûd",
    "hud": "Hûd",
    "ra'd": "Ra'd",
    "rad": "Ra'd",
    "ra’d": "Ra'd",
    "isrâ": "İsrâ",
    "isra": "İsrâ",
    "tâhâ": "Tâhâ",
    "tâha": "Tâhâ",
    "tahâ": "Tâhâ",
    "taha": "Tâhâ",
    "şuara": "Şuarâ",
    "suara": "Şuarâ",
    "suarâ": "Şuarâ",
    "şuarâ": "Şuarâ",
    "sad": "Sâd",
    "sâd": "Sâd",
    "şûrâ": "Şûrâ",
    "şura": "Şûrâ",
    "şurâ": "Şûrâ",
    "şûra": "Şûrâ",
    "hucurat": "Hucurât",
    "hucurât": "Hucurât",
    "kâf": "Kâf",
    "kaf": "Kâf",
    "zâriyât": "Zâriyât",
    "zariyat": "Zâriyât",
    "zâriyat": "Zâriyât",
    "zariyât": "Zâriyât",
    "vakıa": "Vâkıa",
    "vâkıa": "Vâkıa",
    "vâkia": "Vâkıa",
    "teğabun": "Teğabun",
    "tegabun": "Teğabun",
    "hâkka": "Hâkka",
    "hakka": "Hâkka",
    "meâric": "Meâric",
    "mearic": "Meâric",
    "naziat": "Nâziât",
    "nâziât": "Nâziât",
    "nâziat": "Nâziât",
    "naziât": "Nâziât",
    "burûc": "Burûc",
    "burüc": "Burûc",
    "a'la": "A'la",
    "a’la": "A'la",
    "A’la": "A'la",
    "ala": "A'la",
    "duhâ": "Duhâ",
    "duha": "Duhâ",
    "tîn": "Tîn",
    "tin": "Tîn",
    "adiyat": "Âdiyât",
    "âdiyat": "Âdiyât",
    "adiyât": "Âdiyât",
    "âdiyât": "Âdiyât",
    "kâria": "Kâria",
    "karia": "Kâria",
    "mâûn": "Mâûn",
    "mâun": "Mâûn",
    "maûn": "Mâûn",
    "maun": "Mâûn",
    "kâfirun": "Kâfirun",
    "kafirun": "Kâfirun",
    "ahkaf": "Ahkâf",
    "ahkâf": "Ahkâf",
  };

  String validateSurahAndVerse(String surahName, int? verseNumber) {
    final normalizedSurahName =
        surahMap[surahName.toLowerCase()]?.toLowerCase() ??
            surahName.toLowerCase();
    final surah = surelerr.firstWhere(
      (surah) => surah['name'].toLowerCase() == normalizedSurahName,
      orElse: () => {'name': '', 'verseCount': 1},
    );

    print("surahname $surahName");
    if (surahName == "a'la" ||
        surahName == "maun" ||
        surahName == "mâun" ||
        surahName == "mâûn" ||
        surahName == "maûn" ||
        surahName == "enam" ||
        surahName == "en’am" ||
        surahName == "en’âm" ||
        surahName == "en-am" ||
        surahName == "en-âm") {
    } else {
      if (surah['name'] == '') {
        return 'Lütfen Sure Adını Kontrol Ediniz';
      }

      if (verseNumber == null ||
          verseNumber < 1 ||
          verseNumber > surah['verseCount']) {
        return 'Lütfen Ayet Numarasını Kontrol Ediniz';
      }
    }
    return '';
  }

  String pathPDF = "";
  String corruptedPathPDF = "";
  @override
  void initState() {
    if (!kIsWeb) {
      fromAsset('assets/Hmukatta.pdf', 'Hmukatta.pdf').then((f) {
        setState(() {
          corruptedPathPDF = f.path;
        });
      });
    } else {
      corruptedPathPDF = 'assets/Hmukatta.pdf';
    }
    super.initState();
  }

  Future<File> fromAsset(String asset, String filename) async {
    // To open from assets, you can copy them to the app storage folder, and the access them "locally"
    Completer<File> completer = Completer();

    try {
      var dir = await getApplicationDocumentsDirectory();
      File file = File("${dir.path}/$filename");
      var data = await rootBundle.load(asset);
      var bytes = data.buffer.asUint8List();
      await file.writeAsBytes(bytes, flush: true);
      completer.complete(file);
    } catch (e) {
      throw Exception('Error parsing asset file!');
    }

    return completer.future;
  }

  Future<File> createFileOfPdfUrl() async {
    Completer<File> completer = Completer();
    print("Start download file from internet!");
    try {
      // "https://berlin2017.droidcon.cod.newthinking.net/sites/global.droidcon.cod.newthinking.net/files/media/documents/Flutter%20-%2060FPS%20UI%20of%20the%20future%20%20-%20DroidconDE%2017.pdf";
      // final url = "https://pdfkit.org/docs/guide.pdf";
      const url = "http://www.pdf995.com/samples/pdf.pdf";
      final filename = url.substring(url.lastIndexOf("/") + 1);
      var request = await HttpClient().getUrl(Uri.parse(url));
      var response = await request.close();
      var bytes = await consolidateHttpClientResponseBytes(response);
      var dir = await getApplicationDocumentsDirectory();
      print("Download files");
      print("${dir.path}/$filename");
      File file = File("${dir.path}/$filename");

      await file.writeAsBytes(bytes, flush: true);
      completer.complete(file);
    } catch (e) {
      throw Exception('Error parsing asset file!');
    }

    return completer.future;
  }

  RxList<Map<String, dynamic>> searchResults = <Map<String, dynamic>>[].obs;

  // Türkçe karakterleri normalize etme fonksiyonu
  String _normalize(String text) {
    return text
        .toLowerCase()
        .replaceAll('ı', 'i')
        .replaceAll('İ', 'i')
        .replaceAll('ğ', 'g')
        .replaceAll('ü', 'u')
        .replaceAll('ş', 's')
        .replaceAll('ö', 'o')
        .replaceAll('ç', 'c')
        .replaceAll('â', 'a')
        .replaceAll('î', 'i')
        .replaceAll('û', 'u')
        .replaceAll('-', '')
        .replaceAll('\'', '')
        .replaceAll('’', '');
  }

  void _onSearchChanged(String query) {
    if (query.isEmpty) {
      searchResults.clear();
      return;
    }

    final normalizedQuery = _normalize(query);
    final parts = normalizedQuery.split(' ');
    final surahPart = parts[0];
    String? versePart;
    if (parts.length > 1 && int.tryParse(parts.last) != null) {
      versePart = parts.last;
    }

    final results = <Map<String, dynamic>>[];

    // Filter surahs
    final matchedSurahs = mushafSirasi.where((surah) {
      final surahNameNormalized = _normalize(surah['name'].toString());
      return surahNameNormalized.contains(surahPart);
    }).toList();

    for (var surah in matchedSurahs) {
      if (versePart != null) {
        // Check verse count
        final verseNum = int.parse(versePart);
        if (verseNum > 0 && verseNum <= surah['verseCount']) {
          results.add({
            'name': surah['name'],
            'verse': verseNum,
            'type': 'verse', // Specific verse
            'label': '${surah['name']} $verseNum. Ayet'
          });
        }
      } else {
        // Suggest Surah itself (goes to verse 1)
        results.add({
          'name': surah['name'],
          'verse': 1,
          'type': 'surah',
          'label': '${surah['name']} Suresi'
        });
      }
    }

    searchResults.value = results;
  }

  void _showAyeteGitModal(BuildContext context) {
    searchResults.clear(); // Reset search results
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.75,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: Column(
          children: [
            SizedBox(height: 10.h),
            Container(
              width: 40.w,
              height: 4.h,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            SizedBox(height: 20.h),
            const Text(
              "Ayete Git",
              style: TextStyle(
                color: ColorConstants.primaryColor,
                fontSize: 20,
                fontFamily: 'Axiforma',
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 20.h),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w),
              child: TextField(
                onChanged: _onSearchChanged,
                autofocus: true,
                decoration: InputDecoration(
                  labelText: 'Sure / Ayet Ara (örnek: Bakara, Enbiya 34)',
                  labelStyle: const TextStyle(
                    color: ColorConstants.primaryColor,
                    fontFamily: 'Axiforma',
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: BorderSide(
                      color: ColorConstants.primaryColor.withOpacity(0.5),
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: const BorderSide(
                      color: ColorConstants.primaryColor,
                      width: 2,
                    ),
                  ),
                  filled: true,
                  fillColor: ColorConstants.primaryColor.withOpacity(0.05),
                ),
              ),
            ),
            SizedBox(height: 15.h),
            Expanded(
              child: Obx(() {
                if (searchResults.isEmpty) {
                  return const SizedBox.shrink();
                }
                return SingleChildScrollView(
                  padding: EdgeInsets.symmetric(horizontal: 20.w),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Wrap(
                      spacing: 8.0,
                      runSpacing: 8.0,
                      alignment: WrapAlignment.start,
                      children: searchResults.map((result) {
                        return GestureDetector(
                          onTap: () {
                            Navigator.pop(context); // Close modal
                            Get.toNamed(
                              NavigationConstants.sureOkuPage,
                              arguments: [result['name'], result['verse']],
                            );
                          },
                          child: Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: 16.w, vertical: 12.h),
                            decoration: BoxDecoration(
                              color: const Color(0xFF2A89A5),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  result['label'],
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontFamily: 'Axiforma',
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                SizedBox(width: 8.w),
                                const Icon(
                                  Icons.arrow_forward_ios,
                                  color: Colors.white,
                                  size: 14,
                                )
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                );
              }),
            ),
            SizedBox(height: 20.h),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
    TextEditingController sureadi = TextEditingController();
    TextEditingController ayetno = TextEditingController();

    return Scaffold(
      key: scaffoldKey,
      // appBar: AppBar(),
      backgroundColor: ColorConstants.primaryColor,
      drawer: const CustomDrawer(),
      body: Column(
        children: [
          CustomAppBar(onTapMenu: () {
            scaffoldKey.currentState?.openDrawer();
          }, onTapSearch: () {
            Get.toNamed(NavigationConstants.searchPage);
          }),
          const SizedBox(
            height: 15,
          ),
          Expanded(
            child: Stack(
              children: [
                GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () {},
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        SizedBox(height: 5.h),
                        Padding(
                          padding: EdgeInsets.only(left: 30.w, right: 30.w),
                          child: Container(
                            height: 55.h,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              border: Border.all(
                                width: 1,
                                color: const Color(0xff60A6BB),
                              ),
                              borderRadius: BorderRadius.circular(10.h),
                            ),
                            child: ElevatedButton(
                              onPressed: () {
                                _showAyeteGitModal(context);
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.transparent,
                                shadowColor: Colors.transparent,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 10,
                                  horizontal: 20,
                                ),
                                elevation: 0,
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Text(
                                    "Ayete Git",
                                    style: TextStyle(
                                      color: Color(0xFF60A6BB),
                                      fontSize: 18,
                                      fontFamily: 'Axiforma',
                                      fontWeight: FontWeight.w600,
                                      height: 0,
                                    ),
                                  ),
                                  SizedBox(width: 10.w),
                                  const Icon(
                                    Icons.arrow_forward_ios_rounded,
                                    color: Color(0xff60A6BB),
                                    size: 20,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: 5.h),
                        Padding(
                          padding: EdgeInsets.only(
                              top: 10.h, left: 25.w, right: 25.w),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              const Text(
                                "Sure Listesi :",
                                style: TextStyle(
                                  color: Color(0xFF60A6BB),
                                  fontSize: 18,
                                  fontFamily: 'Axiforma',
                                  fontWeight: FontWeight.w600,
                                  height: 0,
                                ),
                              ),
                              SizedBox(width: 20.w),
                              Obx(
                                () => Padding(
                                  padding: const EdgeInsets.only(
                                      bottom: 1.0, top: 1),
                                  child: Container(
                                    // width: 174.w,
                                    // height: 46.h,
                                    constraints: BoxConstraints(
                                        minWidth: 160.w, minHeight: 46.h),
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                        width: 1,
                                        color: const Color(0xff60a6bb),
                                      ),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: IntrinsicWidth(
                                      child: TextButton(
                                        style: TextButton.styleFrom(
                                          padding: EdgeInsets.symmetric(
                                              horizontal: 10.w),
                                        ),
                                        onPressed: () {
                                          homePageController.changeQueue.value =
                                              !homePageController
                                                  .changeQueue.value;
                                        },
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Text(
                                              homePageController
                                                      .changeQueue.value
                                                  ? "Mushaf Sırası"
                                                  : "Nüzul Sırası",
                                              style: const TextStyle(
                                                color: Color(0xFF60A6BB),
                                                fontSize: 16,
                                                fontFamily: 'Axiforma',
                                                fontWeight: FontWeight.w400,
                                                height: 0,
                                              ),
                                            ),
                                            SizedBox(width: 5.w),
                                            Image.asset(
                                              "assets/icon/updown.png",
                                              height: 20.h,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Obx(
                          () => ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            padding: EdgeInsets.only(
                                top: 30.h, left: 25.w, right: 25.w),
                            itemCount: homePageController.changeQueue.value
                                ? mushafSirasi.length
                                : nuzulSirasi.length,
                            itemBuilder: (context, index) {
                              var chosenList =
                                  homePageController.changeQueue.value
                                      ? mushafSirasi
                                      : nuzulSirasi;

                              return Column(
                                children: [
                                  GestureDetector(
                                    onTap: () {
                                      if (chosenList[index]['name'] ==
                                          "Hurufu Mukattaa") {
                                        if (kIsWeb) {
                                          launchUrlString(
                                              'assets/Hmukatta.pdf');
                                        } else {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) => PDFScreen(
                                                  path: corruptedPathPDF),
                                            ),
                                          );
                                        }
                                      } else {
                                        Get.toNamed(
                                            NavigationConstants.sureOkuPage,
                                            arguments: [
                                              "${chosenList[index]['name']}",
                                              1
                                            ]);
                                      }
                                      // SureOkuPage(ayetno: "1",sureadi: "${chosenList[index]['title2']}",);
                                    },
                                    child: Container(
                                      width: double.infinity,
                                      // height: 90.h,
                                      padding: EdgeInsets.symmetric(
                                        horizontal: 20.w,
                                        vertical: 15.w,
                                      ),
                                      clipBehavior: Clip.antiAlias,
                                      decoration: ShapeDecoration(
                                        color: chosenList[index]['name'] ==
                                                "Hurufu Mukattaa"
                                            ? Colors.white.withOpacity(0.9)
                                            : Colors.white,
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(20),
                                        ),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: [
                                          Expanded(
                                            child: Column(
                                              // mainAxisSize: MainAxisSize.min,
                                              mainAxisAlignment:
                                                  MainAxisAlignment.start,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  chosenList[index]['name'],
                                                  style: const TextStyle(
                                                    color: Color(0xFF464646),
                                                    fontSize: 25, //28
                                                    fontFamily: 'Podkova',
                                                    fontWeight: FontWeight.w700,
                                                    height: 0,
                                                  ),
                                                ),
                                                const SizedBox(height: 5),
                                                Text(
                                                  chosenList[index]['name'] ==
                                                          "Hurufu Mukattaa"
                                                      ? ""
                                                      : "${chosenList[index]['verseCount'] - 1} Ayet",
                                                  style: const TextStyle(
                                                    color: Color(0xFF2A89A5),
                                                    fontSize: 15, //16
                                                    fontFamily: 'Podkova',
                                                    fontWeight: FontWeight.w500,
                                                    height: 0,
                                                    letterSpacing: 8,
                                                  ),
                                                ),
                                                SizedBox(
                                                  height: 5.h,
                                                )
                                              ],
                                            ),
                                          ),
                                          SizedBox(width: 10.w),
                                          chosenList[index]['name'] ==
                                                  "Hurufu Mukattaa"
                                              ? const SizedBox()
                                              : SizedBox(
                                                  width: 60,
                                                  height: 60,
                                                  child: Stack(
                                                    children: [
                                                      Positioned(
                                                        left: 0,
                                                        top: 0,
                                                        child: Container(
                                                          width: 60,
                                                          height: 60,
                                                          decoration:
                                                              const ShapeDecoration(
                                                            color: Color(
                                                                0x192A89A5),
                                                            shape: OvalBorder(),
                                                          ),
                                                        ),
                                                      ),
                                                      Center(
                                                        child: Text(
                                                          (index + 1)
                                                              .toString(),
                                                          textAlign:
                                                              TextAlign.center,
                                                          style:
                                                              const TextStyle(
                                                            color: Colors.white,
                                                            fontSize: 30,
                                                            fontFamily:
                                                                'Podkova',
                                                            fontWeight:
                                                                FontWeight.w700,
                                                            // height: 1.0,
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                          const SizedBox(width: 10),
                                          chosenList[index]['name'] ==
                                                  "Hurufu Mukattaa"
                                              ? const SizedBox()
                                              : const Icon(
                                                  Icons
                                                      .arrow_forward_ios_rounded,
                                                  color: ColorConstants
                                                      .primaryColor3,
                                                )
                                        ],
                                      ),
                                    ),
                                  ),
                                  SizedBox(height: 8.h),
                                ],
                              );
                            },
                          ),
                        ),
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),
                // Arka plan karartma katmanı
                Obx(() => IgnorePointer(
                      ignoring: !homePageController.showdialog.value,
                      child: AnimatedOpacity(
                        duration: const Duration(milliseconds: 300),
                        opacity:
                            homePageController.showdialog.value ? 0.6 : 0.0,
                        child: Container(
                          color: Colors.black,
                          width: double.infinity,
                          height: double.infinity,
                        ),
                      ),
                    )),
                // Dialog en üst katmanda ve GestureDetector dışında
                Obx(
                  () => Visibility(
                    visible: homePageController.showdialog.value,
                    child: Positioned(
                      top: 70.h, // Butonun hemen altı
                      left: 0,
                      right: 0,
                      child: Center(
                        child: Container(
                          constraints: BoxConstraints(maxWidth: 400.w),
                          margin: EdgeInsets.symmetric(horizontal: 30.w),
                          padding: EdgeInsets.all(20.w),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 10,
                                offset: const Offset(0, 5),
                              ),
                            ],
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Text(
                                "Ayete Git",
                                style: TextStyle(
                                  color: ColorConstants.primaryColor,
                                  fontSize: 20,
                                  fontFamily: 'Axiforma',
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(height: 20.h),
                              TextField(
                                controller: sureadi,
                                decoration: InputDecoration(
                                  labelText: 'Sure Adı',
                                  labelStyle: const TextStyle(
                                    color: ColorConstants.primaryColor,
                                    fontFamily: 'Axiforma',
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(15),
                                    borderSide: BorderSide(
                                      color: ColorConstants.primaryColor
                                          .withOpacity(0.5),
                                    ),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(15),
                                    borderSide: const BorderSide(
                                      color: ColorConstants.primaryColor,
                                      width: 2,
                                    ),
                                  ),
                                  filled: true,
                                  fillColor: ColorConstants.primaryColor
                                      .withOpacity(0.05),
                                ),
                              ),
                              SizedBox(height: 15.h),
                              TextField(
                                controller: ayetno,
                                keyboardType: TextInputType.number,
                                decoration: InputDecoration(
                                  labelText: 'Ayet No',
                                  labelStyle: const TextStyle(
                                    color: ColorConstants.primaryColor,
                                    fontFamily: 'Axiforma',
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(15),
                                    borderSide: BorderSide(
                                      color: ColorConstants.primaryColor
                                          .withOpacity(0.5),
                                    ),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(15),
                                    borderSide: const BorderSide(
                                      color: ColorConstants.primaryColor,
                                      width: 2,
                                    ),
                                  ),
                                  filled: true,
                                  fillColor: ColorConstants.primaryColor
                                      .withOpacity(0.05),
                                ),
                              ),
                              SizedBox(height: 20.h),
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton(
                                  onPressed: () {
                                    final surahName = sureadi.text.trim();
                                    int? verseNumber =
                                        int.tryParse(ayetno.text);
                                    verseNumber ??= 1;

                                    final validationError =
                                        validateSurahAndVerse(
                                            surahName, verseNumber);

                                    if (validationError.isNotEmpty) {
                                      Get.snackbar('Hata', validationError);
                                    } else {
                                      homePageController.showdialog.value =
                                          !homePageController.showdialog.value;
                                      Get.toNamed(
                                          NavigationConstants.sureOkuPage,
                                          arguments: [surahName, verseNumber]);
                                    }
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor:
                                        ColorConstants.primaryColor,
                                    padding:
                                        EdgeInsets.symmetric(vertical: 15.h),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(15),
                                    ),
                                    elevation: 0,
                                  ),
                                  child: const Text(
                                    'GİT',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 18,
                                      fontFamily: 'Axiforma',
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
