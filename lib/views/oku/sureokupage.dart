// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';
import 'dart:ffi';
import 'dart:io';
import 'dart:ui';

import 'package:dio/dio.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:fecrmeal/core/constants/customScrollbar.dart';
import 'package:fecrmeal/views/homepage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get_instance/get_instance.dart';
import 'package:get/get_rx/get_rx.dart';
import 'package:get/get_state_manager/get_state_manager.dart';
import 'package:get/route_manager.dart';

import 'package:fecrmeal/core/constants/color_constants.dart';
import 'package:fecrmeal/core/constants/navigation_constants.dart';
import 'package:fecrmeal/core/controller/homepageController.dart';
import 'package:fecrmeal/core/model/suremodel.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SureOkuPage extends StatefulWidget {
  SureOkuPage({
    Key? key,
  }) : super(key: key);

  @override
  State<SureOkuPage> createState() => _SureOkuPageState();
}

class _SureOkuPageState extends State<SureOkuPage> {
  HomePageController homePageController = Get.find();
  String sureadi = Get.arguments[0];
  int ayetno = Get.arguments[1] ?? 0;
  String? dynamicText;
  @override
  void initState() {
    _makeRequest();
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
          transformedText = matchedText.substring(3, matchedText.length - 1) +
              '.'; // 'a:' ön ekini ve köşeli parantezleri kaldır, '.' ekle
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
              print('Tapped on ${match.group(0)}');
              _showBottomSheet(
                  context,
                  "DİPNOT ${transformedText.replaceAll('[', '').replaceAll(']', '')}",
                  _verses[ayetno].aciklamaPTags!.tags![0].content.toString());
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

  TextEditingController _controller1 = TextEditingController();
  TextEditingController _controller2 = TextEditingController();
  List<Verses> _verses = [];
  String SureAdi = "";
  RxBool sonAyet = true.obs;
  void _makeRequest() async {
    Dio dio = Dio();
    try {
      Response response = await dio.post(
        'http://fecrapi.anilakademi.com/api/post-ayet-adi?sure=',
        data: {
          'sure': sureadi,
          // 'ayetno':ayetno,
        },
      );
      List<dynamic> dataList = response.data;
      List<SureModel> sureModelList =
          dataList.map((data) => SureModel.fromJson(data)).toList();
      print("assdasdsad ${dataList[0]['sureadi']}");
      sureadi = dataList[0]['sureadi'];
      if (sureModelList.isNotEmpty) {
        print("asaadd");
        String sureAdi = dataList.isNotEmpty ? dataList[0]['sureadi'] : "";
        print(sureAdi);
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
      return '﴾' + parts.join('﴾') + firstPart;
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
          style: TextStyle(
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
        style: TextStyle(
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

              if (number != null) {
                Get.offAndToNamed(NavigationConstants.sureOkuPage,
                    arguments: [text, number]);
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
        style: TextStyle(
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
    return Scaffold(
      backgroundColor: ColorConstants.primaryColor,
      appBar: AppBar(
        toolbarHeight: 70.h,
        leading: Padding(
          padding: EdgeInsets.only(left: 10),
          child: IconButton(
            // onPressed: () => Get.offAllNamed(NavigationConstants.home),
            onPressed: () => Get.back(),
            icon: Icon(
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
                    height: 0,
                  ),
                ),
                TextSpan(
                  text: 'AYDINLIĞI',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontFamily: 'Bw Aleta No 10',
                    fontWeight: FontWeight.w400,
                    height: 0,
                  ),
                ),
              ],
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
                  width: 390.w,
                  height: 81.h,
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  clipBehavior: Clip.antiAlias,
                  decoration: BoxDecoration(color: Color(0xFF0E5770)),
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
                          ayetno != 1
                              ? Container(
                                  height: 45,
                                  width: 45,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                        color: Color(0xff2B89A5), width: 2),
                                  ),
                                  child: Center(
                                    child: IconButton(
                                      onPressed: _previousVerse,
                                      icon: Icon(
                                        Icons.arrow_back,
                                        color: ColorConstants.primaryColor3,
                                        size: 25,
                                      ),
                                    ),
                                  ),
                                )
                              : Container(
                                  width: 45,
                                  height: 45,
                                ),
                          SizedBox(
                            width: 10,
                          ),
                          Container(
                            width: 230.w,
                            height: 72.h,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: ColorConstants.primaryColor3,
                                width: 1,
                              ),
                            ),
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton2<String>(
                                isExpanded: true,
                                hint: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Expanded(
                                      child: Container(
                                        alignment: Alignment.center,
                                        width: 230.w,
                                        height: 72.h,
                                        decoration: BoxDecoration(
                                            // borderRadius: BorderRadius.circular(10),
                                            // border: Border.all(
                                            //   color: ColorConstants.primaryColor3,
                                            //   width: 1,
                                            // ),
                                            ),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Padding(
                                              padding:
                                                  EdgeInsets.only(left: 25.w),
                                              child: Column(
                                                children: [
                                                  Text(
                                                    SureAdi,
                                                    textAlign: TextAlign.center,
                                                    style: TextStyle(
                                                      color: Color(0xFF60A6BB),
                                                      fontSize: SureAdi ==
                                                              "Hurufu Mukattaa"
                                                          ? 20
                                                          : 28,
                                                      fontFamily: 'Podkova',
                                                      fontWeight:
                                                          FontWeight.w700,
                                                      height: 0,
                                                    ),
                                                  ),
                                                  if (_verses.isNotEmpty)
                                                    Text(
                                                      '${extractATag(_verses[ayetno].meal.toString())}. Ayet',
                                                      textAlign:
                                                          TextAlign.center,
                                                      style: TextStyle(
                                                        color: Colors.white,
                                                        fontSize: 17,
                                                        //18
                                                        fontFamily: 'Podkova',
                                                        fontWeight:
                                                            FontWeight.w400,
                                                        height: 0,
                                                      ),
                                                    ),
                                                  SizedBox(
                                                    height: 5,
                                                  )
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
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
                                              style: TextStyle(
                                                color:
                                                    ColorConstants.primaryColor,
                                                fontSize: 20,
                                                fontFamily: 'Podkova',
                                                fontWeight: FontWeight.w700,
                                                height:
                                                    1.2, // Text arası boşluğu ayarladık
                                              ),
                                            ),
                                          ],
                                        ),
                                        SizedBox(
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
                                value: selectedValue,
                                onChanged: (String? value) {
                                  setState(() {
                                    String selectedValue2 =
                                        value!.split(' (')[0];
                                    print("aaabbcc $selectedValue2");
                                    Get.offAndToNamed(
                                        NavigationConstants.sureOkuPage,
                                        arguments: ["$selectedValue2", 1]);
                                  });
                                },
                                buttonStyleData: ButtonStyleData(
                                  padding:
                                      const EdgeInsets.only(left: 0, right: 4),
                                ),
                                iconStyleData: const IconStyleData(
                                  icon: Icon(
                                    Icons.keyboard_arrow_down_rounded,
                                  ),
                                  iconSize: 25,
                                  iconEnabledColor:
                                      ColorConstants.primaryColor3,
                                  iconDisabledColor: Colors.grey,
                                ),
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
                                        MaterialStateProperty.all<double>(6),
                                    thumbVisibility:
                                        MaterialStateProperty.all<bool>(true),
                                  ),
                                ),
                                menuItemStyleData: const MenuItemStyleData(
                                  height: 50,
                                  padding: EdgeInsets.only(left: 14, right: 14),
                                ),
                              ),
                            ),
                          ),
                          SizedBox(
                            width: 10,
                          ),
                          Visibility(
                            visible: ayetno != (_verses.length - 1),
                            child: Obx(
                              () => Visibility(
                                visible: sonAyet.value,
                                child: Container(
                                  height: 45,
                                  width: 45,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                        color: Color(0xff2B89A5), width: 2),
                                  ),
                                  child: Center(
                                    child: IconButton(
                                      onPressed: _nextVerse,
                                      icon: Icon(
                                        Icons.arrow_forward_outlined,
                                        color: ColorConstants.primaryColor3,
                                        size: 25,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
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
                        _nextVerse();
                      } else if (details.primaryVelocity! > 0) {
                        // Sola kaydırma işlemi
                        _previousVerse();
                      }
                    },
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          Padding(
                              padding: const EdgeInsets.all(25.0),
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
                                    shadows: [
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
                                            padding: EdgeInsets.all(16.0),
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
                                                        style: TextStyle(
                                                          fontSize: 24,
                                                          fontFamily:
                                                              'Kuranfont',
                                                          fontWeight:
                                                              FontWeight.w400,
                                                          color:
                                                              Color(0xFF2A89A5),
                                                        ),
                                                        locale:
                                                            Locale('ar', ''),
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
                          Visibility(
                            visible: ayetno == 1,
                            child: GestureDetector(
                              onTap: () {
                                _showBottomSheet(
                                    context,
                                    '${SureAdi} Suresi\nHakkında',
                                    _verses[0].meal.toString());
                              },
                              child: Center(
                                child: Padding(
                                  padding: EdgeInsets.only(bottom: 150.h),
                                  child: Container(
                                    width: 250.w,
                                    height: 70.h,
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 10),
                                    decoration: ShapeDecoration(
                                      color: Color(0xFF2A89A5),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(25),
                                      ),
                                      shadows: [
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
                                        SizedBox(
                                          width: 15,
                                        ),
                                        Container(
                                          height: 35,
                                          clipBehavior: Clip.antiAlias,
                                          decoration: BoxDecoration(),
                                          child: Icon(
                                            Icons.info_outline_rounded,
                                            size: 30,
                                            color: Colors.white,
                                          ),
                                        ),
                                        const SizedBox(width: 15),
                                        Text(
                                          'Sure Hakkında',
                                          textAlign: TextAlign.right,
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 24,
                                            fontFamily: 'Podkova',
                                            fontWeight: FontWeight.w400,
                                            height: 0.09,
                                          ),
                                        ),
                                        SizedBox(
                                          width: 15,
                                        )
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
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
              () => homePageController.isContainerVisible.value
                  ? Padding(
                      padding: const EdgeInsets.only(
                          bottom: 15, left: 15, right: 15),
                      child: Align(
                          alignment: Alignment.bottomCenter,
                          child: Fab(
                              context,
                              homePageController.yazipuntosu,
                              homePageController.arapcametin,
                              homePageController.dipnotlar)),
                    )
                  : Padding(
                      padding: const EdgeInsets.only(left: 20, bottom: 15),
                      child: Align(
                        alignment: Alignment.bottomRight,
                        child: GestureDetector(
                          onTap: toggleContainerVisibility,
                          child: Container(
                            width: 50,
                            height: 97,
                            child: Icon(
                              Icons.keyboard_arrow_left,
                              size: 42,
                              color: Colors.white,
                            ),
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.only(
                                    topLeft: Radius.circular(50),
                                    bottomLeft: Radius.circular(50)),
                                color: ColorConstants.primaryColor3),
                          ),
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
        padding: EdgeInsets.only(left: 0),
        child: Container(
          width: MediaQuery.of(context).size.width * 0.95,
          height: 97,
          padding: const EdgeInsets.symmetric(vertical: 15),
          decoration: ShapeDecoration(
            color: Color(0xFF2A89A5),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
            ),
            shadows: [
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
                          return Container(
                            width: MediaQuery.of(context).size.width *
                                0.9, // Boyutu arttır
                            child: Padding(
                              padding: const EdgeInsets.all(20.0),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  SizedBox(
                                    height: 10,
                                  ),
                                  Text(
                                    "AYARLAR",
                                    style: TextStyle(
                                      color: Colors.black, // Text1 rengi
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18,
                                    ),
                                  ),
                                  SizedBox(
                                    height: 10,
                                  ),
                                  Divider(
                                    color: Colors.black,
                                    thickness: 1,
                                  ),
                                  SizedBox(
                                    height: 10,
                                  ),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      // Metin Büyüklüğü ve Artı Eksi iconları
                                      Container(
                                        width: 190.w,
                                        height: 35.h,
                                        child: Stack(
                                          children: [
                                            Positioned(
                                              left: 0,
                                              top: 0,
                                              child: Text(
                                                'Metin Büyüklüğü',
                                                textAlign: TextAlign.center,
                                                style: TextStyle(
                                                  color: Colors.black,
                                                  fontSize: 17.5,
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
                                          SizedBox(width: 20),
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
                                  SizedBox(
                                    height: 15,
                                  ),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      // Metin Büyüklüğü ve Artı Eksi iconları
                                      Text(
                                        'Arapça Metin',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          color: Colors.black,
                                          fontSize: 18,
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
                                            SizedBox(width: 20),
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
                                  SizedBox(
                                    height: 15,
                                  ),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        'Dipnotlar',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          color: Colors.black,
                                          fontSize: 18,
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
                                            SizedBox(width: 20),
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
                                  SizedBox(
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
                  SizedBox(
                    width: 15,
                  ),
                  GestureDetector(
                      onTap: () {
                        _showAlertDialog2(context, "FAVORİ AYETLER",
                            "${sureadi} Suresi, ${ayetno}. Ayet \nFavori Ayetlere Eklendi.");
                        _saveCurrentAyah();
                      },
                      child: bottomSheetWidget(
                          asset: "favorites", text: "Favori")),
                  SizedBox(
                    width: 15,
                  ),
                  GestureDetector(
                      onTap: () {
                        _ayracCurrentAyah();
                        _showAlertDialog2(context, "AYRAÇ",
                            "${sureadi} Suresi, ${ayetno}. Ayet \nAyraç eklendi. Okumaya  buradan  devam edebilirsiniz.");
                      },
                      child:
                          bottomSheetWidget(asset: "saveicon", text: "Ayraç")),
                  SizedBox(
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
                          "$sureadi Suresi ${metin}  ${_verses[ayetno].meal}",
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
                  icon: Icon(
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
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(30.0)),
      ),
      builder: (BuildContext context) {
        return Container(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height * 0.8,
          padding: EdgeInsets.only(left: 25, right: 25, bottom: 40, top: 25),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(30.0)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.max,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              SizedBox(height: 10),
              Text(
                text1,
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 18,
                  fontFamily: 'AxiformaBold',
                  fontWeight: FontWeight.w900,
                  height: 0,
                ),
              ),
              SizedBox(height: 10),
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
              SizedBox(height: 10),
            ],
          ),
        );
      },
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
          content: Container(
            width: MediaQuery.of(context).size.width * 0.8,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                SizedBox(height: 10),
                Text(
                  text1,
                  style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                SizedBox(height: 10),
                SizedBox(height: 10),
                Container(
                  constraints: BoxConstraints(
                    maxHeight: MediaQuery.of(context).size.height * 0.3,
                  ),
                  child: ListView(
                    shrinkWrap: true,
                    children: [
                      Text(
                        text2,
                        style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.normal,
                          fontSize: 17,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 10),
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
          content: Container(
            width: MediaQuery.of(context).size.width * 0.8, // Boyutu arttır
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                SizedBox(
                  height: 10,
                ),
                Text(
                  text1,
                  style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                SizedBox(
                  height: 10,
                ),
                Divider(
                  color: Colors.black,
                  thickness: 1,
                ),
                SizedBox(
                  height: 10,
                ),
                Text(
                  text2,
                  style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.normal,
                    fontSize: 17,
                  ),
                ),
                SizedBox(
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
  "Fatiha    (7)",
  "Bakara    (286)",
  "Al-i İmran    (200)",
  "Nisa    (176)",
  "Maide    (120)",
  "Enâm    (165)",
  "Araf   (206)",
  "Enfâl    (75)",
  "Tevbe    (129)",
  "Yunus    (109)",
  "Hud    (123)",
  "Yusuf    (111)",
  "Rad    (43)",
  "İbrahim    (52)",
  "Hicr    (99)",
  "Nahl    (128)",
  "İsra    (111)",
  "Kehf    (110)",
  "Meryem    (98)",
  "Taha    (135)",
  "Enbiya    (112)",
  "Hac    (78)",
  "Müminun    (118)",
  "Nur    (64)",
  "Furkan    (77)",
  "Şuara    (227)",
  "Neml    (93)",
  "Kasas    (88)",
  "Ankebut    (69)",
  "Rum    (60)",
  "Lokman    (34)",
  "Secde    (30)",
  "Ahzab    (73)",
  "Sebe    (54)",
  "Fatır    (45)",
  "Yasin    (83)",
  "Saffat    (182)",
  "Sad    (88)",
  "Zümer    (75)",
  "Mümin    (85)",
  "Fussilet    (54)",
  "Şura    (53)",
  "Zuhruf    (89)",
  "Duhan    (59)",
  "Casiye    (37)",
  "Ahkaf    (35)",
  "Muhammed    (38)",
  "Fetih    (29)",
  "Hucurat    (18)",
  "Kaf    (45)",
  "Zariyat    (60)",
  "Tur    (49)",
  "Necm    (62)",
  "Kamer    (55)",
  "Rahman    (78)",
  "Vakia    (96)",
  "Hadid    (29)",
  "Mücadele    (22)",
  "Haşr    (24)",
  "Mümtehine    (13)",
  "Saff    (14)",
  "Cuma    (11)",
  "Münafikun    (11)",
  "Tegabun    (18)",
  "Talak    (12)",
  "Tahrim    (12)",
  "Mülk    (30)",
  "Kalem    (52)",
  "Hakka    (52)",
  "Mearic    (44)",
  "Nuh    (28)",
  "Cin    (28)",
  "Müzzemmil    (20)",
  "Müddessir    (56)",
  "Kıyamet    (40)",
  "İnsan    (31)",
  "Mürselat    (50)",
  "Nebe    (40)",
  "Naziat    (46)",
  "Abese    (42)",
  "Tekvir    (29)",
  "İnfitar    (19)",
  "Mutaffifin    (36)",
  "İnşikak    (25)",
  "Buruc    (22)",
  "Tarık    (17)",
  "Ala    (19)",
  "Gaşiye    (26)",
  "Fecr    (30)",
  "Beled    (20)",
  "Şems    (15)",
  "Leyl    (21)",
  "Duha    (11)",
  "İnşirah    (8)",
  "Tin    (8)",
  "Alak    (19)",
  "Kadir    (5)",
  "Beyyine    (8)",
  "Zilzal    (8)",
  "Adiyat    (11)",
  "Karia    (11)",
  "Tekasur    (8)",
  "Asr   (3)",
  "Hümeze    (9)",
  "Fil    (5)",
  "Kureyş    (4)",
  "Maun    (7)",
  "Kevser    (3)",
  "Kafirun    (6)",
  "Nasr    (3)",
  "Tebbet    (5)",
  "İhlas    (4)",
  "Felak    (5)",
  "Nas    (6)"
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
              decoration: BoxDecoration(),
              child: Image.asset("assets/icon/$asset.png")),
          Text(
            text,
            textAlign: TextAlign.center,
            style: TextStyle(
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
