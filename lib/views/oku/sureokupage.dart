import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:fecrmeal/core/constants/color_constants.dart';
import 'package:fecrmeal/core/constants/customScrollbar.dart';
import 'package:fecrmeal/core/constants/navigation_constants.dart';
import 'package:fecrmeal/core/controller/homepageController.dart';
import 'package:fecrmeal/core/model/suremodel.dart';
import 'package:fecrmeal/views/pdfviewer/pdfviewer.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SureOkuPage extends StatefulWidget {
  const SureOkuPage({
    Key? key,
  }) : super(key: key);

  @override
  State<SureOkuPage> createState() => _SureOkuPageState();
}

class _SureOkuPageState extends State<SureOkuPage> {
  HomePageController homePageController = Get.find();
  String sureadi = (Get.arguments != null && Get.arguments.length > 0)
      ? Get.arguments[0]
      : "Fâtiha";
  int ayetno = (Get.arguments != null && Get.arguments.length > 1)
      ? Get.arguments[1]
      : 1;
  String? dynamicText;
  @override
  void initState() {
    _makeRequest();
    if (!kIsWeb) {
      fromAsset('assets/Hmukatta.pdf', 'Hmukatta.pdf').then((f) {
        if (mounted) {
          setState(() {
            corruptedPathPDF = f.path;
          });
        }
      }).catchError((error) {
        debugPrint("PDF yüklenirken hata oluştu: $error");
      });
    }
    super.initState();
  }

  List<TextSpan> _parseText(String text, bool showDipnotlar) {
    List<TextSpan> spans = [];

    RegExp exp = RegExp(r"(\[?[da]:\d+(-\d+|,\s*\d+)*\]?)");

    text.splitMapJoin(
      exp,
      onMatch: (match) {
        String matchedText = match.group(0)!;
        String transformedText;

        // Eğer 'showDipnotlar' false ise ve matchedText 'd:' içeriyorsa, bu kısmı atla
        if (!showDipnotlar && matchedText.contains('d:')) {
          return '';
        }

        if (matchedText.contains('d:')) {
          transformedText = matchedText.substring(3); // 'd:' ön ekini kaldır
          transformedText = " [$transformedText";
        } else if (matchedText.contains('a:')) {
          transformedText =
              '${matchedText.substring(3, matchedText.length - 1)}.'; // 'a:' ön ekini ve köşeli parantezleri kaldır, '.' ekle
        } else {
          transformedText = matchedText;
        }

        spans.add(TextSpan(
          text: transformedText,
          style: TextStyle(
            fontFamily: 'Podkova',
            fontSize: homePageController.yazipuntosu.value,
            fontWeight: FontWeight.w400,
            color: !transformedText.contains('[')
                ? Colors.black
                : ColorConstants.primaryColor,
          ),
          recognizer: TapGestureRecognizer()
            ..onTap = () {
              if (_verses[ayetno].aciklamaPTags!.tags!.length > 1) {
                String x =
                    transformedText.replaceAll('[', '').replaceAll(']', '');
                int index = (int.tryParse(x)! - 1) % 2;
                _showBottomSheet(
                    context,
                    "DİPNOT ${transformedText.replaceAll('[', '').replaceAll(']', '')}",
                    _verses[ayetno]
                        .aciklamaPTags!
                        .tags![index]
                        .content
                        .toString());
              } else {
                _showBottomSheet(
                    context,
                    "DİPNOT ${transformedText.replaceAll('[', '').replaceAll(']', '')}",
                    _verses[ayetno].aciklamaPTags!.tags![0].content.toString());
              }
            },
        ));
        return '';
      },
      onNonMatch: (nonMatch) {
        spans.add(TextSpan(
          text: nonMatch,
          style: TextStyle(
            color: Colors.black,
            fontFamily: 'Podkova',
            fontSize: homePageController.yazipuntosu.value,
            fontWeight: FontWeight.w400,
          ),
        ));
        return '';
      },
    );

    return spans;
  }

  final TextEditingController _controller1 = TextEditingController();
  final TextEditingController _controller2 = TextEditingController();
  List<Verses> _verses = [];

  String pathPDF = "";
  String corruptedPathPDF = "";
  @override
  Future<dynamic> fromAsset(String asset, String filename) async {
    if (kIsWeb) return null;
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
      debugPrint("Asset yükleme hatası ($asset): $e");
      // throw Exception('Error parsing asset file!'); // Eski hata fırlatma
      // Hata olsa bile completer'ı boş veya null ile tamamlayabiliriz veya hatayı yukarı iletebiliriz.
      // Şimdilik hatayı yukarı fırlatalım ama detaylı mesajla.
      completer.completeError(Exception('Asset yüklenemedi: $asset. Hata: $e'));
    }

    return completer.future;
  }

  Future<dynamic> createFileOfPdfUrl() async {
    if (kIsWeb) return null;
    Completer<File> completer = Completer();
    try {
      // "https://berlin2017.droidcon.cod.newthinking.net/sites/global.droidcon.cod.newthinking.net/files/media/documents/Flutter%20-%2060FPS%20UI%20of%20the%20future%20%20-%20DroidconDE%2017.pdf";
      // final url = "https://pdfkit.org/docs/guide.pdf";
      const url = "http://www.pdf995.com/samples/pdf.pdf";
      final filename = url.substring(url.lastIndexOf("/") + 1);
      var request = await HttpClient().getUrl(Uri.parse(url));
      var response = await request.close();
      var bytes = await consolidateHttpClientResponseBytes(response);
      var dir = await getApplicationDocumentsDirectory();
      File file = File("${dir.path}/$filename");

      await file.writeAsBytes(bytes, flush: true);
      completer.complete(file);
    } catch (e) {
      print("Error parsing asset file: $e");
    }

    return completer.future;
  }

  String SureAdi = "";
  RxBool sonAyet = true.obs;
  void _makeRequest() async {
    Dio dio = Dio();
    try {
      sureadi = sureadi.toLowerCase();
      print("aassdd $sureadi");
      if (sureadi == "en’âm" ||
          sureadi == "enam" ||
          sureadi == "en'âm" ||
          sureadi == "en’am") {
        sureadi = "en'am";
      }
      if (sureadi == "ali imran" ||
          sureadi == "âli imran" ||
          sureadi == "al'i imran" ||
          sureadi == "al-i imran") {
        sureadi = "Âl-i İmran";
      }

      if (sureadi == "insirah" || sureadi == "inşirah") {
        sureadi = "inşirah";
      }

      if (sureadi == "a’raf" || sureadi == "araf") {
        print("aassdd buradami");
        sureadi = "a'raf";
      }

      if (sureadi == "hûd" || sureadi == "hud") {
        sureadi = "Hûd";
      }

      if (sureadi == "ra’d" || sureadi == "rad") {
        sureadi = "Ra'd";
      }

      if (sureadi == "isrâ" || sureadi == "isra") {
        sureadi = "İsrâ";
      }

      if (sureadi == "tâhâ" || sureadi == "tâha" || sureadi == "tahâ") {
        sureadi = "Tâhâ";
      }

      if (sureadi == "şuara" ||
          sureadi == "suara" ||
          sureadi == "suarâ" ||
          sureadi == "şuarâ") {
        sureadi = "Şuarâ";
      }

      if (sureadi == "sad" || sureadi == "sâd") {
        sureadi = "Sâd";
      }

      if (sureadi == "şûrâ" ||
          sureadi == "şura" ||
          sureadi == "şurâ" ||
          sureadi == "şûra") {
        sureadi = "Şûrâ";
      }

      if (sureadi == "hucurat" || sureadi == "hucurât") {
        sureadi = "Hucurât";
      }

      if (sureadi == "kâf" || sureadi == "kaf") {
        sureadi = "Kâf";
      }

      if (sureadi == "zâriyât" ||
          sureadi == "zariyat" ||
          sureadi == "zâriyat" ||
          sureadi == "zariyât") {
        sureadi = "Zâriyât";
      }

      if (sureadi == "vakıa" || sureadi == "vâkıa") {
        sureadi = "Vâkıa";
      }

      if (sureadi == "teğabun" || sureadi == "tegabun") {
        sureadi = "Teğabun";
      }

      if (sureadi == "hâkka" || sureadi == "hakka") {
        sureadi = "Hâkka";
      }

      if (sureadi == "meâric" || sureadi == "mearic") {
        sureadi = "Meâric";
      }

      if (sureadi == "naziat" ||
          sureadi == "nâziât" ||
          sureadi == "nâziat" ||
          sureadi == "naziât") {
        sureadi = "Nâziât";
      }

      if (sureadi == "burûc" || sureadi == "burüc") {
        sureadi = "Burûc";
      }

      if (sureadi == "a'la" || sureadi == "a’la" || sureadi == "ala") {
        sureadi = "A'la";
      }

      if (sureadi == "duhâ" || sureadi == "duha") {
        sureadi = "Duhâ";
      }

      if (sureadi == "tîn" || sureadi == "tin") {
        sureadi = "Tîn";
      }

      if (sureadi == "adiyat" ||
          sureadi == "âdiyat" ||
          sureadi == "adiyât" ||
          sureadi == "âdiyât") {
        sureadi = "Âdiyât";
      }

      if (sureadi == "kâria" || sureadi == "karia") {
        sureadi = "Kâria";
      }

      if (sureadi == "mâûn" ||
          sureadi == "mâun" ||
          sureadi == "maûn" ||
          sureadi == "maun") {
        sureadi = "Mâûn";
      }

      if (sureadi == "kâfirun" || sureadi == "kafirun") {
        sureadi = "Kâfirun";
      }

      if (sureadi == "Ali İmran" ||
          sureadi == "Âli İmran" ||
          sureadi == "Al'i İmran" ||
          sureadi == "Al-i İmran") {
        sureadi = "Âl-i İmran";
      }

      print("aassdd cikis $sureadi");

      var response = await dio.post(
        'http://fecrapi.anilakademi.com/api/post-ayet-adi?sure=',
        data: {
          'sure': sureadi,
        },
      );
      print("http://fecrapi.anilakademi.com/api/post-ayet-adi?sure=$sureadi");
      List<dynamic> dataList = response.data;
      List<SureModel> sureModelList =
          dataList.map((data) => SureModel.fromJson(data)).toList();
      sureadi = dataList[0]['sureadi'];
      if (sureModelList.isNotEmpty) {
        String sureAdi = dataList.isNotEmpty ? dataList[0]['sureadi'] : "";
        SureAdi = sureAdi;
        setState(() {
          _verses = sureModelList.first.verses!;
        });
      }
    } catch (e) {
      print(e.toString());
    }
  }

  Future<void> _saveCurrentAyah() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> savedAyahs = prefs.getStringList('savedAyahs') ?? [];

    Map<String, dynamic> ayahData = {
      'sureadi': sureadi,
      'ayetno': ayetno ?? 0, // Ensure ayetno is an integer
      'metin': _verses[ayetno].metin,
      'meal': _verses[ayetno].meal
    };

    savedAyahs.add(jsonEncode(ayahData));
    await prefs.setStringList('savedAyahs', savedAyahs);

    // Get.snackbar('Success', 'Ayah saved.');
  }

  String moveSeparatorToFront(String text) {
    // Metni '﴾' işaretine göre böler
    List<String> parts = text.split('﴾');
    if (parts.length > 1) {
      // İlk bölümü kaldırır
      String firstPart = parts.removeAt(0);
      // Kalan bölümleri birleştirir ve başa '﴾' ekler
      return '﴾${parts.join('﴾')}$firstPart';
    }
    return text;
  }

  //a
  Future<void> _ayracCurrentAyah() async {
    SharedPreferences prefs2 = await SharedPreferences.getInstance();
    List<String> ayracAyahs = prefs2.getStringList('ayracAyahs') ?? [];

    Map<String, dynamic> ayracData = {
      'sureadi': sureadi,
      'ayetno': ayetno ?? 0, // Ensure ayetno is an integer
      'metin': _verses[ayetno].metin,
      'meal': _verses[ayetno].meal
    };

    ayracAyahs.add(jsonEncode(ayracData));
    await prefs2.setStringList('ayracAyahs', ayracAyahs);

    // Get.snackbar('Success', 'Ayah saved.');
  }

  void _nextVerse() {
    print("basıldı");
    setState(() {
      print("saddfsa ${_verses[ayetno]..toString()}");
      if (ayetno < _verses.length - 1) {
        if (_verses[ayetno].sonrakiayet == 1 ||
            _verses[ayetno].sonrakiayet == 0) {
          sonAyet.value = false;
        } else {
          ayetno = _verses[ayetno].sonrakiayet ?? 1;
          print("ayetno: $ayetno");
        }
      }
    });
  }

  void _previousVerse() {
    print("basıldı");
    setState(() {
      if (ayetno > 1) {
        sonAyet.value = true;
        ayetno = _verses[ayetno].oncekiayet ?? 1;
        print("ayetno: $ayetno");
      }
    });
  }

  bool isContainerVisible = false;

  void toggleContainerVisibility() {
    homePageController.isContainerVisible.value =
        !homePageController.isContainerVisible.value;
  }

  String extractATag(String text) {
    RegExp exp = RegExp(r"\[a:(\d+(-\d+)?(,\s*\d+)*)\]");
    Match? match = exp.firstMatch(text);
    if (match != null) {
      return match.group(1)!.replaceAll(' ', '');
    }
    return '1';
  }

  List<TextSpan> _buildTextSpans(String text) {
    final regex = RegExp(r'\[([^\]]+)\]');
    final matches = regex.allMatches(text);

    List<TextSpan> spans = [];
    int lastMatchEnd = 0;

    for (var match in matches) {
      final citation = match.group(1)!;
      final start = match.start;
      final end = match.end;
      if (start > lastMatchEnd) {
        spans.add(TextSpan(
          text: text.substring(lastMatchEnd, start),
          style: const TextStyle(
            color: Colors.black,
            fontSize: 26,
            fontFamily: 'Source Serif Pro',
            fontWeight: FontWeight.w400,
            height: 0,
          ),
        ));
      }

      spans.add(TextSpan(
        text: citation,
        style: const TextStyle(
          color: Colors.blue,
          fontSize: 26,
          fontFamily: 'Source Serif Pro',
          fontWeight: FontWeight.w700,
          height: 0,
        ),
        recognizer: TapGestureRecognizer()
          ..onTap = () {
            final parts = citation.split(' ');
            if (parts.length >= 2) {
              final text = parts.sublist(0, parts.length - 1).join(' ');
              final numberStr = parts.last;
              final number = int.tryParse(numberStr);

              // Print the separated text and number
              print("Metin: $text");
              print("Sayı: $numberStr");

              if (text == "Hurufu") {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => PDFScreen(path: corruptedPathPDF),
                  ),
                );
              } else if (number != null) {
                if (text == "Hurufu") {
                } else {
                  Get.offAndToNamed(NavigationConstants.sureOkuPage,
                      arguments: [text, number]);
                }
              } else {
                print("Failed to parse number: $numberStr");
              }
            } else {
              print("Unexpected format: $citation");
            }
          },
      ));

      lastMatchEnd = end;
    }

    if (lastMatchEnd < text.length) {
      spans.add(TextSpan(
        text: text.substring(lastMatchEnd),
        style: const TextStyle(
          color: Colors.black,
          fontSize: 26,
          fontFamily: 'Source Serif Pro',
          fontWeight: FontWeight.w400,
          height: 0,
        ),
      ));
    }

    return spans;
  }

  @override
  Widget build(BuildContext context) {
    // Veri yüklenene kadar loading göster
    if (_verses.isEmpty) {
      return Scaffold(
        backgroundColor: ColorConstants.primaryColor,
        appBar: AppBar(
          backgroundColor: ColorConstants.primaryColor,
          elevation: 0,
          leading: IconButton(
            onPressed: () => Get.back(),
            icon: const Icon(Icons.arrow_back, color: Colors.white),
          ),
        ),
        body: const Center(
          child: CircularProgressIndicator(color: Colors.white),
        ),
      );
    }

    return Scaffold(
      backgroundColor: ColorConstants.primaryColor,
      appBar: AppBar(
        toolbarHeight: 70.h,
        leading: Padding(
          padding: const EdgeInsets.only(left: 10),
          child: IconButton(
            // onPressed: () => Get.offAllNamed(NavigationConstants.home),
            onPressed: () => Get.back(),
            icon: const Icon(
              Icons.arrow_back,
              color: Colors.white,
              size: 35,
            ),
          ),
        ),
        // actions: [
        //   IconButton(
        //     onPressed: toggleContainerVisibility,
        //     icon: Icon(Icons.search, color: Colors.white, size: 35),
        //   )
        // ],
        centerTitle: true,
        backgroundColor: ColorConstants.primaryColor,
        title: GestureDetector(
          onTap: () {
            Get.offAllNamed(NavigationConstants.home);
          },
          child: const FittedBox(
            fit: BoxFit.scaleDown,
            child: Text.rich(
              TextSpan(
                children: [
                  TextSpan(
                    text: 'KUR’AN ',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontFamily: 'Bw Aleta No 10 Bold',
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  TextSpan(
                    text: 'AYDINLIĞI',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontFamily: 'Bw Aleta No 10',
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: double.infinity, // Tam genişlik (390.w yerine)
                  // Yüksekliği içeriğe göre esnek bırakıyoruz veya minHeight veriyoruz
                  constraints: BoxConstraints(minHeight: 81.h),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 5), // Dikey padding ekledik
                  clipBehavior: Clip.antiAlias,
                  decoration: const BoxDecoration(color: Color(0xFF0E5770)),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          SizedBox(
                            width: 15.w,
                          ),
                          ayetno != 1 && _verses[ayetno].oncekiayet != 0
                              ? Container(
                                  height: 45,
                                  width: 45,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                        color: const Color(0xff2B89A5),
                                        width: 2),
                                  ),
                                  child: Center(
                                    child: IconButton(
                                      onPressed: _previousVerse,
                                      icon: const Icon(
                                        Icons.arrow_back,
                                        color: ColorConstants.primaryColor3,
                                        size: 25,
                                      ),
                                    ),
                                  ),
                                )
                              : const SizedBox(
                                  width: 45,
                                  height: 45,
                                ),
                          const SizedBox(
                            width: 10,
                          ),
                          Expanded(
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton2(
                                customButton: Container(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 10.w, vertical: 10.h),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(
                                      color: ColorConstants.primaryColor3,
                                      width: 1,
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Text(
                                              SureAdi,
                                              textAlign: TextAlign.center,
                                              style: TextStyle(
                                                color: const Color(0xFF60A6BB),
                                                fontSize:
                                                    SureAdi == "Hurufu Mukattaa"
                                                        ? 20
                                                        : 28,
                                                fontFamily: 'Podkova',
                                                fontWeight: FontWeight.w700,
                                                height: 0.9,
                                              ),
                                            ),
                                            const SizedBox(height: 5),
                                            if (_verses.isNotEmpty)
                                              Text(
                                                '${extractATag(_verses[ayetno].meal.toString())}. Ayet',
                                                textAlign: TextAlign.center,
                                                style: const TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 17,
                                                  fontFamily: 'Podkova',
                                                  fontWeight: FontWeight.w400,
                                                  height: 0.9,
                                                ),
                                              ),
                                          ],
                                        ),
                                      ),
                                      const Icon(
                                        Icons.keyboard_arrow_down_rounded,
                                        color: ColorConstants.primaryColor3,
                                        size: 30,
                                      ),
                                    ],
                                  ),
                                ),
                                items: sureler.asMap().entries.map((entry) {
                                  int index = entry.key;
                                  String sure = entry.value;
                                  return DropdownMenuItem<String>(
                                    value: sure,
                                    child: Column(
                                      children: [
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          children: [
                                            Text(
                                              "${index + 1}. $sure",
                                              style: const TextStyle(
                                                color:
                                                    ColorConstants.primaryColor,
                                                fontSize: 20,
                                                fontFamily: 'Podkova',
                                                fontWeight: FontWeight.w700,
                                                height: 1.2,
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(
                                          height: 10,
                                        ),
                                        Divider(
                                          color: ColorConstants.primaryColor3
                                              .withOpacity(0.4),
                                          height: 1,
                                        )
                                      ],
                                    ),
                                  );
                                }).toList(),
                                onChanged: (String? value) {
                                  setState(() {
                                    String selectedValue2 =
                                        value!.split(' (')[0];
                                    Get.offAndToNamed(
                                        NavigationConstants.sureOkuPage,
                                        arguments: [selectedValue2, 1]);
                                  });
                                },
                                dropdownStyleData: DropdownStyleData(
                                  maxHeight: 600.h,
                                  width: 270.w,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(14),
                                    color: Colors.white.withOpacity(0.9),
                                  ),
                                  offset: const Offset(-20, 0),
                                  scrollbarTheme: ScrollbarThemeData(
                                    radius: const Radius.circular(40),
                                    thickness:
                                        WidgetStateProperty.all<double>(6),
                                    thumbVisibility:
                                        WidgetStateProperty.all<bool>(true),
                                  ),
                                ),
                                menuItemStyleData: const MenuItemStyleData(
                                  height: 50,
                                  padding: EdgeInsets.only(left: 14, right: 14),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(
                            width: 10,
                          ),
                          Visibility(
                            visible: (_verses.isNotEmpty &&
                                ayetno != (_verses.length - 1) &&
                                _verses[ayetno].sonrakiayet != 0),
                            child: Obx(
                              () => Visibility(
                                visible: sonAyet.value,
                                child: Container(
                                  height: 45,
                                  width: 45,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                        color: const Color(0xff2B89A5),
                                        width: 2),
                                  ),
                                  child: Center(
                                    child: IconButton(
                                      onPressed: _nextVerse,
                                      icon: const Icon(
                                        Icons.arrow_forward_outlined,
                                        color: ColorConstants.primaryColor3,
                                        size: 25,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          )
                        ],
                      ),
                    ],
                  ),
                ),
                Expanded(
                  flex: 3,
                  child: GestureDetector(
                    onHorizontalDragEnd: (details) {
                      if (details.primaryVelocity! < 0) {
                        // Sağa kaydırma işlemi
                        if ((ayetno != (_verses.length - 1) &&
                            _verses[ayetno].sonrakiayet != 0)) {
                          _nextVerse();
                        }
                      } else if (details.primaryVelocity! > 0) {
                        // Sola kaydırma işlemi
                        if (ayetno != 1 && _verses[ayetno].oncekiayet != 0) {
                          _previousVerse();
                        }
                      }
                    },
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          Visibility(
                            visible: ayetno == 1,
                            child: GestureDetector(
                              onTap: () {
                                _showBottomSheet(
                                    context,
                                    '$SureAdi Suresi\nHakkında',
                                    _verses[0].meal.toString());
                              },
                              child: Center(
                                child: Padding(
                                  padding:
                                      EdgeInsets.only(bottom: 35.h, top: 25),
                                  child: Container(
                                    width: 260.w,
                                    height: 70.h,
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 10),
                                    decoration: ShapeDecoration(
                                      color: const Color(0xFF2A89A5),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(25),
                                      ),
                                      shadows: const [
                                        BoxShadow(
                                          color: Color(0x3F000000),
                                          blurRadius: 10,
                                          offset: Offset(0, 8),
                                          spreadRadius: 0,
                                        )
                                      ],
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        const SizedBox(
                                          width: 8,
                                        ),
                                        Container(
                                          height: 35,
                                          clipBehavior: Clip.antiAlias,
                                          decoration: const BoxDecoration(),
                                          child: const Icon(
                                            Icons.info_outline_rounded,
                                            size: 30,
                                            color: Colors.white,
                                          ),
                                        ),
                                        const SizedBox(width: 10),
                                        const Text(
                                          'Sure Hakkında',
                                          textAlign: TextAlign.right,
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 21,
                                            fontFamily: 'Podkova',
                                            fontWeight: FontWeight.w400,
                                            height: 0.07,
                                          ),
                                        ),
                                        const SizedBox(
                                          width: 8,
                                        )
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Padding(
                              padding: const EdgeInsets.only(
                                left: 25.0,
                                right: 25,
                              ),
                              child: Container(
                                  width: MediaQuery.of(context).size.width,
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 15, vertical: 30),
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
                                      mainAxisSize: MainAxisSize.min,
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        if (_verses.isNotEmpty)
                                          Container(
                                            width: double.infinity,
                                            padding: const EdgeInsets.all(16.0),
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.center,
                                              children: [
                                                Obx(
                                                  () => Visibility(
                                                    visible: homePageController
                                                        .arapcametin.value,
                                                    child: RichText(
                                                      text: TextSpan(
                                                        text: _verses[ayetno]
                                                            .metin!,
                                                        style: const TextStyle(
                                                          fontSize: 24,
                                                          fontFamily:
                                                              'KuranFont',
                                                          fontWeight:
                                                              FontWeight.w400,
                                                          color:
                                                              Color(0xFF2A89A5),
                                                        ),
                                                        locale: const Locale(
                                                            'ar', ''),
                                                      ),
                                                      textDirection:
                                                          TextDirection.rtl,
                                                    ),
                                                  ),
                                                ),
                                                SizedBox(
                                                  height: 30.h,
                                                ),
                                                SizedBox(
                                                  width: double.infinity,
                                                  child: Obx(
                                                    () => homePageController
                                                            .dipnotlar.value
                                                        ? RichText(
                                                            textAlign: TextAlign
                                                                .center,
                                                            text: TextSpan(
                                                              style: TextStyle(
                                                                fontFamily:
                                                                    'Podkova',
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w400,
                                                                fontSize:
                                                                    homePageController
                                                                        .yazipuntosu
                                                                        .value,
                                                              ),
                                                              children: _parseText(
                                                                  _verses[ayetno]
                                                                      .meal!,
                                                                  homePageController
                                                                      .dipnotlar
                                                                      .value),
                                                            ),
                                                          )
                                                        : RichText(
                                                            text: TextSpan(
                                                              style: TextStyle(
                                                                fontFamily:
                                                                    'Podkova',
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w400,
                                                                fontSize:
                                                                    homePageController
                                                                        .yazipuntosu
                                                                        .value,
                                                              ),
                                                              children: _parseText(
                                                                  _verses[ayetno]
                                                                      .meal!,
                                                                  homePageController
                                                                      .dipnotlar
                                                                      .value),
                                                            ),
                                                          ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                      ]))),
                          SizedBox(
                            height: 120.h,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            Obx(
              () => Padding(
                padding: EdgeInsets.only(
                    bottom: (defaultTargetPlatform == TargetPlatform.iOS ? 45 : 20) +
                        MediaQuery.of(context).padding.bottom,
                    right: 20),
                child: Align(
                  alignment: Alignment.bottomRight,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      // Açılır Menü İçeriği (Yatay)
                      AnimatedSize(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                        child: homePageController.isContainerVisible.value
                            ? Container(
                                margin: const EdgeInsets.only(right: 10),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 5),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF2A89A5),
                                  borderRadius: BorderRadius.circular(30),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.2),
                                      blurRadius: 10,
                                      offset: const Offset(0, 5),
                                    ),
                                  ],
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    _buildMenuItem(
                                      context,
                                      icon: Icons.settings,
                                      label: "Ayarlar",
                                      onTap: () {
                                        showModalBottomSheet(
                                          context: context,
                                          builder: (BuildContext context) {
                                            return _buildSettingsModal(context);
                                          },
                                        );
                                      },
                                    ),
                                    const SizedBox(width: 5),
                                    _buildMenuItem(
                                      context,
                                      icon: Icons.favorite_border,
                                      label: "Favori",
                                      onTap: () {
                                        _showAlertDialog2(
                                            context,
                                            "FAVORİ AYETLER",
                                            "$sureadi Suresi, $ayetno. Ayet \nFavori Ayetlere Eklendi.");
                                        _saveCurrentAyah();
                                      },
                                    ),
                                    const SizedBox(width: 5),
                                    _buildMenuItem(
                                      context,
                                      icon: Icons.bookmark_border,
                                      label: "Ayraç",
                                      onTap: () {
                                        _ayracCurrentAyah();
                                        _showAlertDialog2(context, "AYRAÇ",
                                            "$sureadi Suresi, $ayetno. Ayet \nAyraç eklendi. Okumaya buradan devam edebilirsiniz.");
                                      },
                                    ),
                                    const SizedBox(width: 5),
                                    _buildMenuItem(
                                      context,
                                      icon: Icons.share,
                                      label: "Paylaş",
                                      onTap: () async {
                                        // Meali temizle (Köşeli parantezleri kaldır)
                                        String meal =
                                            _verses[ayetno].meal ?? "";
                                        meal = meal.replaceAll(
                                            RegExp(r'\[.*?\]'), '');

                                        // Paylaşılacak metni oluştur
                                        final shareText =
                                            "$sureadi Suresi, $ayetno. Ayet\n\n$meal\n\nFecr Meal Uygulaması";

                                        await Share.share(shareText,
                                            subject:
                                                "$sureadi Suresi, $ayetno. Ayet");
                                      },
                                    ),
                                  ],
                                ),
                              )
                            : const SizedBox.shrink(),
                      ),
                      // Ana Buton (Toggle)
                      GestureDetector(
                        onTap: toggleContainerVisibility,
                        child: Container(
                          width: 56,
                          height: 56,
                          decoration: BoxDecoration(
                            color: const Color(0xFF2A89A5),
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.3),
                                blurRadius: 8,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Icon(
                            homePageController.isContainerVisible.value
                                ? Icons.close
                                : Icons.menu,
                            color: Colors.white,
                            size: 28,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Padding Fab(BuildContext context, RxDouble yazipuntosu, RxBool arapcametin,
      RxBool dipnotlar) {
    return Padding(
        padding: const EdgeInsets.only(left: 0),
        child: Container(
          width: MediaQuery.of(context).size.width * 0.95,
          height: 97,
          padding: const EdgeInsets.symmetric(vertical: 15),
          decoration: ShapeDecoration(
            color: const Color(0xFF2A89A5),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
            ),
            shadows: const [
              BoxShadow(
                color: Color(0x3F000000),
                blurRadius: 10,
                offset: Offset(0, 8),
                spreadRadius: 0,
              )
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    width: 35.w,
                  ),
                  GestureDetector(
                    onTap: () {
                      showModalBottomSheet(
                        context: context,
                        builder: (BuildContext context) {
                          return SizedBox(
                            width: MediaQuery.of(context).size.width *
                                0.9, // Boyutu arttır
                            child: Padding(
                              padding: const EdgeInsets.all(20.0),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  const SizedBox(
                                    height: 10,
                                  ),
                                  const Text(
                                    "AYARLAR",
                                    style: TextStyle(
                                      color: Colors.black, // Text1 rengi
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18,
                                    ),
                                  ),
                                  const SizedBox(
                                    height: 5,
                                  ),
                                  const Divider(
                                    color: Colors.black,
                                    thickness: 1,
                                  ),
                                  const SizedBox(
                                    height: 5,
                                  ),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      // Metin Büyüklüğü ve Artı Eksi iconları
                                      SizedBox(
                                        width: 190.w,
                                        height: 35.h,
                                        child: Stack(
                                          children: [
                                            const Positioned(
                                              left: 0,
                                              top: 0,
                                              child: Text(
                                                'Metin Büyüklüğü',
                                                textAlign: TextAlign.center,
                                                style: TextStyle(
                                                  color: Colors.black,
                                                  fontSize: 17,
                                                  fontFamily: 'Axiforma',
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                            ),
                                            Positioned(
                                              left: 0,
                                              top: 20,
                                              child: Obx(
                                                () => Text(
                                                  '${(yazipuntosu.value).toInt()} Punto',
                                                  style: TextStyle(
                                                    color: Colors.black
                                                        .withOpacity(0.7),
                                                    fontSize: 12,
                                                    fontFamily: 'Axiforma',
                                                    fontWeight: FontWeight.w500,
                                                    letterSpacing: 1.20,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Row(
                                        children: [
                                          GestureDetector(
                                              onTap: () {
                                                yazipuntosu.value =
                                                    yazipuntosu.value - 1;
                                                print(yazipuntosu.value);
                                              },
                                              child: Image.asset(
                                                  "assets/icon/eksi.png")),
                                          const SizedBox(width: 20),
                                          GestureDetector(
                                              onTap: () {
                                                yazipuntosu.value =
                                                    yazipuntosu.value + 1;
                                                print(yazipuntosu.value);
                                              },
                                              child: Image.asset(
                                                  "assets/icon/arti.png")),
                                        ],
                                      ),
                                    ],
                                  ),
                                  const SizedBox(
                                    height: 15,
                                  ),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      // Metin Büyüklüğü ve Artı Eksi iconları
                                      const Text(
                                        'Arapça Metin',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          color: Colors.black,
                                          fontSize: 17,
                                          fontFamily: 'Axiforma',
                                          fontWeight: FontWeight.w500,
                                          height: 0,
                                        ),
                                      ),
                                      Obx(
                                        () => Row(
                                          children: [
                                            GestureDetector(
                                                onTap: () {
                                                  arapcametin.value = false;
                                                },
                                                child: SvgPicture.asset(
                                                  "assets/icon/kapaligoz.svg",
                                                  color: arapcametin.value
                                                      ? Colors.grey
                                                      : Colors.black,
                                                )),
                                            const SizedBox(width: 20),
                                            GestureDetector(
                                                onTap: () {
                                                  arapcametin.value = true;
                                                },
                                                child: SvgPicture.asset(
                                                  "assets/icon/acikgozsiyah.svg",
                                                  color: arapcametin.value
                                                      ? Colors.black
                                                      : Colors.grey,
                                                )),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(
                                    height: 15,
                                  ),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      const Text(
                                        'Dipnotlar',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          color: Colors.black,
                                          fontSize: 17,
                                          fontFamily: 'Axiforma',
                                          fontWeight: FontWeight.w500,
                                          height: 0,
                                        ),
                                      ),
                                      // Arapça metin ve göz ikonları
                                      Obx(
                                        () => Row(
                                          children: [
                                            GestureDetector(
                                                onTap: () {
                                                  dipnotlar.value = false;
                                                },
                                                child: SvgPicture.asset(
                                                  "assets/icon/kapaligoz.svg",
                                                  color: dipnotlar.value
                                                      ? Colors.grey
                                                      : Colors.black,
                                                )),
                                            const SizedBox(width: 20),
                                            GestureDetector(
                                                onTap: () {
                                                  dipnotlar.value = true;
                                                },
                                                child: SvgPicture.asset(
                                                  "assets/icon/acikgozsiyah.svg",
                                                  color: dipnotlar.value
                                                      ? Colors.black
                                                      : Colors.grey,
                                                )),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(
                                    height: 15,
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      );
                    },
                    child:
                        bottomSheetWidget(asset: "settings", text: "Ayarlar"),
                  ),
                  const SizedBox(
                    width: 15,
                  ),
                  GestureDetector(
                      onTap: () {
                        _showAlertDialog2(context, "FAVORİ AYETLER",
                            "$sureadi Suresi, $ayetno. Ayet \nFavori Ayetlere Eklendi.");
                        _saveCurrentAyah();
                      },
                      child: bottomSheetWidget(
                          asset: "favorites", text: "Favori")),
                  const SizedBox(
                    width: 15,
                  ),
                  GestureDetector(
                      onTap: () {
                        _ayracCurrentAyah();
                        _showAlertDialog2(context, "AYRAÇ",
                            "$sureadi Suresi, $ayetno. Ayet \nAyraç eklendi. Okumaya  buradan  devam edebilirsiniz.");
                      },
                      child:
                          bottomSheetWidget(asset: "saveicon", text: "Ayraç")),
                  const SizedBox(
                    width: 15,
                  ),
                  GestureDetector(
                      onTap: () async {
                        String meal = _verses[ayetno].meal!;
                        meal = meal.replaceAll(RegExp(r'\[.*?\]'), '');
                        _verses[ayetno].meal = meal;

                        String metin = _verses[ayetno].metin!;
                        if (metin.isNotEmpty) {
                          metin = metin[metin.length - 1] +
                              metin.substring(0, metin.length - 1);
                        }

                        await Share.share(
                          "$sureadi Suresi $metin  ${_verses[ayetno].meal}",
                        );
                      },
                      child: bottomSheetWidget(asset: "share", text: "Paylaş")),
                  SizedBox(
                    width: 0.w,
                  ),
                ],
              ),
              IconButton(
                  onPressed: toggleContainerVisibility,
                  icon: const Icon(
                    Icons.arrow_forward_ios_sharp,
                    color: Color(0xFF88E3FF),
                    size: 20,
                  )),
              // Expanded(
              //   flex: 3,
              //   child: SingleChildScrollView(
              //     child: Padding(
              //       padding: const EdgeInsets.all(25.0),
              //       child: Container(
              //         width: MediaQuery.of(context).size.width,
              //         padding: const EdgeInsets.symmetric(
              //             horizontal: 25, vertical: 50),
              //         clipBehavior: Clip.antiAlias,
              //         decoration: ShapeDecoration(
              //           color: Colors.white,
              //           shape: RoundedRectangleBorder(
              //             borderRadius: BorderRadius.circular(30),
              //           ),
              //           shadows: [
              //             BoxShadow(
              //               color: Color(0x26000000),
              //               blurRadius: 10,
              //               offset: Offset(4, 4),
              //               spreadRadius: 0,
              //             ),
              //           ],
              //         ),
              //         child: Column(
              //           mainAxisSize: MainAxisSize.min,
              //           mainAxisAlignment: MainAxisAlignment.start,
              //           crossAxisAlignment: CrossAxisAlignment.center,
              //           children: [
              //             if (_verses.isNotEmpty)
              //               Container(
              //                 width: double.infinity,
              //                 padding: EdgeInsets.all(16.0),
              //                 child: Column(
              //                   crossAxisAlignment: CrossAxisAlignment.center,
              //                   children: [
              //                     Obx(
              //                       () => Visibility(
              //                         visible: arapcametin.value,
              //                         child: Text(
              //                           _verses[ayetno].metin!,
              //                           style: TextStyle(
              //                             fontSize: 24,
              //                             fontFamily: 'KuranFont',
              //                             fontWeight: FontWeight.w400,
              //                             color: Color(0xFF2A89A5),
              //                           ),
              //                         ),
              //                       ),
              //                     ),
              //                     SizedBox(height: 20),
              //                     ElevatedButton(
              //                       onPressed: _saveCurrentAyah,
              //                       child: Text('Save Current Ayah'),
              //                     ),
              //                   ],
              //                 ),
              //               ),
              //           ],
              //         ),
              //       ),
              //     ),
              //   ),
              // ),
            ],
          ),
        ));
  }

  void _showBottomSheet(BuildContext context, String text1, String text2) {
    showModalBottomSheet(
      isScrollControlled: true,
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(30.0)),
      ),
      builder: (BuildContext context) {
        return Container(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height * 0.8,
          padding:
              const EdgeInsets.only(left: 25, right: 25, bottom: 40, top: 25),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(30.0)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.max,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              const SizedBox(height: 10),
              Text(
                text1,
                style: const TextStyle(
                  color: Colors.black,
                  fontSize: 18,
                  fontFamily: 'AxiformaBold',
                  fontWeight: FontWeight.w900,
                  height: 0,
                ),
              ),
              const SizedBox(height: 10),
              Expanded(
                child: CustomScrollbar(
                  thickness: 6.0,
                  child: SingleChildScrollView(
                    child: RichText(
                      text: TextSpan(
                        children: _buildTextSpans(text2),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMenuItem(BuildContext context,
      {required IconData icon,
      required String label,
      required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.1),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: Colors.white, size: 24),
      ),
    );
  }

  Widget _buildSettingsModal(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.only(
        top: 20,
        left: 20,
        right: 20,
        bottom: 20 + MediaQuery.of(context).padding.bottom,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(25),
          topRight: Radius.circular(25),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            "Görünüm Ayarları",
            style: TextStyle(
              color: Color(0xFF2A89A5),
              fontWeight: FontWeight.bold,
              fontSize: 20,
              fontFamily: 'Axiforma',
            ),
          ),
          const SizedBox(height: 25),
          // Metin Büyüklüğü
          Row(
            children: [
              const Icon(Icons.format_size, color: Color(0xFF2A89A5), size: 28),
              const SizedBox(width: 15),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Metin Büyüklüğü',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        fontFamily: 'Axiforma',
                      ),
                    ),
                    Obx(
                      () => Text(
                        '${homePageController.yazipuntosu.value.toInt()} Punto',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey[600],
                          fontFamily: 'Axiforma',
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Obx(
            () => Row(
              children: [
                Text(
                  "A",
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Expanded(
                  child: SliderTheme(
                    data: SliderTheme.of(context).copyWith(
                      activeTrackColor: const Color(0xFF2A89A5),
                      inactiveTrackColor:
                          const Color(0xFF2A89A5).withOpacity(0.2),
                      thumbColor: const Color(0xFF2A89A5),
                      overlayColor: const Color(0xFF2A89A5).withOpacity(0.2),
                      trackHeight: 4.0,
                    ),
                    child: Slider(
                      value: homePageController.yazipuntosu.value,
                      min: 14.0,
                      max: 40.0,
                      divisions: 26,
                      onChanged: (value) {
                        homePageController.yazipuntosu.value = value;
                      },
                    ),
                  ),
                ),
                Text(
                  "A",
                  style: TextStyle(
                    fontSize: 24,
                    color: Colors.grey[800],
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          const Divider(thickness: 1, height: 30),
          // Arapça Metin Toggle
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.language,
                      color: Color(0xFF2A89A5), size: 28),
                  const SizedBox(width: 15),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Arapça Metin',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          fontFamily: 'Axiforma',
                        ),
                      ),
                      Text(
                        'Arapça metni göster/gizle',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                          fontFamily: 'Axiforma',
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              Obx(
                () => Switch(
                  value: homePageController.arapcametin.value,
                  onChanged: (value) {
                    homePageController.arapcametin.value = value;
                  },
                  activeThumbColor: const Color(0xFF2A89A5),
                ),
              ),
            ],
          ),
          const SizedBox(height: 15),
          // Dipnotlar Toggle
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.notes, color: Color(0xFF2A89A5), size: 28),
                  const SizedBox(width: 15),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Dipnotlar',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          fontFamily: 'Axiforma',
                        ),
                      ),
                      Text(
                        'Dipnotları göster/gizle',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                          fontFamily: 'Axiforma',
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              Obx(
                () => Switch(
                  value: homePageController.dipnotlar.value,
                  onChanged: (value) {
                    homePageController.dipnotlar.value = value;
                  },
                  activeThumbColor: const Color(0xFF2A89A5),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
        ],
      ),
    );
  }

  void _showAlertDialog(BuildContext context, String text1, String text2) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          surfaceTintColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30.0),
          ),
          content: SizedBox(
            width: MediaQuery.of(context).size.width * 0.8,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                const SizedBox(height: 10),
                Text(
                  text1,
                  style: const TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                const SizedBox(height: 10),
                const SizedBox(height: 10),
                Container(
                  constraints: BoxConstraints(
                    maxHeight: MediaQuery.of(context).size.height * 0.3,
                  ),
                  child: ListView(
                    shrinkWrap: true,
                    children: [
                      Text(
                        text2,
                        style: const TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.normal,
                          fontSize: 17,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showAlertDialog2(BuildContext context, String text1, String text2) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          surfaceTintColor: Colors.white,
          // backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30.0),
          ),
          content: SizedBox(
            width: MediaQuery.of(context).size.width * 0.8, // Boyutu arttır
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                const SizedBox(
                  height: 10,
                ),
                Text(
                  text1,
                  style: const TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                const SizedBox(
                  height: 10,
                ),
                const Divider(
                  color: Colors.black,
                  thickness: 1,
                ),
                const SizedBox(
                  height: 10,
                ),
                Text(
                  text2,
                  style: const TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.normal,
                    fontSize: 17,
                  ),
                ),
                const SizedBox(
                  height: 10,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

String? selectedValue;
List<String> sureler = [
  "Fâtiha    (6)",
  "Bakara    (286)",
  "Âl-i İmrân    (200)",
  "Nisâ    (176)",
  "Mâide    (120)",
  "En'âm    (165)",
  "A'râf    (206)",
  "Enfâl    (75)",
  "Tevbe    (129)",
  "Yûnus    (109)",
  "Hûd    (123)",
  "Yûsuf    (111)",
  "Ra'd    (43)",
  "İbrâhim    (52)",
  "Hicr    (99)",
  "Nahl    (128)",
  "İsrâ    (111)",
  "Kehf    (110)",
  "Meryem    (98)",
  "Tâ-Hâ    (135)",
  "Enbiyâ    (112)",
  "Hac    (78)",
  "Mü'minûn    (118)",
  "Nûr    (64)",
  "Furkân    (77)",
  "Şuarâ    (227)",
  "Neml    (93)",
  "Kasas    (88)",
  "Ankebût    (69)",
  "Rûm    (60)",
  "Lokmân    (34)",
  "Secde    (30)",
  "Ahzâb    (73)",
  "Sebe    (54)",
  "Fâtır    (45)",
  "Yâsîn    (83)",
  "Sâffât    (182)",
  "Sâd    (88)",
  "Zümer    (75)",
  "Mü'min    (85)",
  "Fussilet    (54)",
  "Şûrâ    (53)",
  "Zuhruf    (89)",
  "Duhân    (59)",
  "Câsiye    (37)",
  "Ahkâf    (35)",
  "Muhammed    (38)",
  "Fetih    (29)",
  "Hucurât    (18)",
  "Kâf    (45)",
  "Zâriyât    (60)",
  "Tûr    (49)",
  "Necm    (62)",
  "Kamer    (55)",
  "Rahmân    (78)",
  "Vâkıa    (96)",
  "Hadîd    (29)",
  "Mücâdele    (22)",
  "Haşr    (24)",
  "Mümtehine    (13)",
  "Saff    (14)",
  "Cuma    (11)",
  "Münâfikûn    (11)",
  "Teğâbün    (18)",
  "Talâk    (12)",
  "Tahrîm    (12)",
  "Mülk    (30)",
  "Kalem    (52)",
  "Hâkka    (52)",
  "Meâric    (44)",
  "Nûh    (28)",
  "Cin    (28)",
  "Müzzemmil    (20)",
  "Müddessir    (56)",
  "Kıyâmet    (40)",
  "İnsân    (31)",
  "Mürselât    (50)",
  "Nebe    (40)",
  "Nâziât    (46)",
  "Abese    (42)",
  "Tekvîr    (29)",
  "İnfitâr    (19)",
  "Mutaffifîn    (36)",
  "İnşikâk    (25)",
  "Bürûc    (22)",
  "Târık    (17)",
  "A'lâ    (19)",
  "Gâşiye    (26)",
  "Fecr    (30)",
  "Beled    (20)",
  "Şems    (15)",
  "Leyl    (21)",
  "Duhâ    (11)",
  "İnşirâh    (8)",
  "Tîn    (8)",
  "Alak    (19)",
  "Kadr    (5)",
  "Beyyine    (8)",
  "Zilzâl    (8)",
  "Âdiyât    (11)",
  "Kâria    (11)",
  "Tekâsür    (8)",
  "Asr    (3)",
  "Hümeze    (9)",
  "Fîl    (5)",
  "Kureyş    (4)",
  "Mâûn    (7)",
  "Kevser    (3)",
  "Kâfirûn    (6)",
  "Nasr    (3)",
  "Tebbet    (5)",
  "İhlâs    (4)",
  "Felâk    (5)",
  "Nâs    (6)"
];

class bottomSheetWidget extends StatelessWidget {
  String text;
  String asset;
  bottomSheetWidget({
    Key? key,
    required this.text,
    required this.asset,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 55,
      height: 67,
      padding: const EdgeInsets.only(bottom: 2),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
              width: 50,
              height: 50,
              clipBehavior: Clip.antiAlias,
              decoration: const BoxDecoration(),
              child: Image.asset("assets/icon/$asset.png")),
          Text(
            text,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Color(0xFF88E3FF),
              fontSize: 12,
              fontFamily: 'Work Sans',
              fontWeight: FontWeight.w500,
              height: 0,
            ),
          ),
        ],
      ),
    );
  }
}

//a
