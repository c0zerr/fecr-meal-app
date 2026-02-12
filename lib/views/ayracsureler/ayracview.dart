import 'package:fecrmeal/core/constants/color_constants.dart';
import 'package:fecrmeal/core/constants/navigation_constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:get/get.dart';

class AyracSurePage extends StatefulWidget {
  const AyracSurePage({Key? key}) : super(key: key);

  @override
  _AyracSurePageState createState() => _AyracSurePageState();
}

class _AyracSurePageState extends State<AyracSurePage> {
  Future<List<Map<String, dynamic>>> _getayracAyahs() async {
    SharedPreferences prefs2 = await SharedPreferences.getInstance();
    List<String>? ayracAyahs = prefs2.getStringList('ayracAyahs');
    if (ayracAyahs != null) {
      // Decode and remove duplicates based on `sureadi` and `ayetno`
      Map<String, Map<String, dynamic>> uniqueAyahs = {};
      for (String item in ayracAyahs) {
        Map<String, dynamic> data = jsonDecode(item);
        String key = "${data['sureadi']}_${data['ayetno']}";
        uniqueAyahs[key] = {
          'sureadi': data['sureadi'],
          'ayetno': data['ayetno'] is int
              ? data['ayetno']
              : int.tryParse(data['ayetno']) ?? 0,
          'metin': data['metin'],
          'meal': data['meal']
        };
      }

      // Convert the unique map back to a list
      List<Map<String, dynamic>> ayahsList = uniqueAyahs.values.toList();

      // Save the unique list back to SharedPreferences
      List<String> uniqueAyahStrings =
          ayahsList.map((ayah) => jsonEncode(ayah)).toList();
      await prefs2.setStringList('ayracAyahs', uniqueAyahStrings);

      return ayahsList;
    }
    return [];
  }

  Future<void> _deleteSavedAyah(int index) async {
    SharedPreferences prefs2 = await SharedPreferences.getInstance();
    List<String>? ayracAyahs = prefs2.getStringList('ayracAyahs');
    if (ayracAyahs != null) {
      ayracAyahs.removeAt(index);
      await prefs2.setStringList('ayracAyahs', ayracAyahs);
      setState(() {});
    }
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
          transformedText = "";
        } else if (matchedText.contains('a:')) {
          transformedText = '${matchedText.substring(3, matchedText.length - 1)}.'; // 'a:' ön ekini ve köşeli parantezleri kaldır, '.' ekle
        } else {
          transformedText = matchedText;
        }

        spans.add(TextSpan(
          text: transformedText,
          style: TextStyle(
            fontFamily: 'Podkova',
            fontSize: 28,
            fontWeight: FontWeight.w400,
            color: !transformedText.contains('[')
                ? Colors.black
                : ColorConstants.primaryColor,
          ),
          // recognizer: TapGestureRecognizer()..onTap = () {},
        ));
        return '';
      },
      onNonMatch: (nonMatch) {
        spans.add(TextSpan(
          text: nonMatch,
          style: const TextStyle(
            color: Colors.black,
            fontFamily: 'Podkova',
            fontWeight: FontWeight.w400,
          ),
        ));
        return '';
      },
    );

    return spans;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorConstants.primaryColor,
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white, size: 30),
        backgroundColor: ColorConstants.primaryColor,
        centerTitle: true,
        title: const Text(
          'Ayraç',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontFamily: 'Axiforma',
            fontWeight: FontWeight.w700,
            height: 0,
          ),
        ),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _getayracAyahs(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          List<Map<String, dynamic>> ayracAyahs = snapshot.data!;
          if (ayracAyahs.isEmpty) {
            return const Padding(
              padding: EdgeInsets.all(25.0),
              child: Center(
                child: Text(
                  "Henüz bir ayraç eklemediniz",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontFamily: 'Axiforma',
                    fontWeight: FontWeight.w700,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }
          return ListView.builder(
            itemCount: ayracAyahs.length,
            itemBuilder: (context, index) {
              String sureadi = ayracAyahs[index]['sureadi'];
              int ayetno = ayracAyahs[index]['ayetno'];
              String metin = ayracAyahs[index]['metin'];
              String meal = ayracAyahs[index]['meal'];
              return Padding(
                padding: const EdgeInsets.all(25.0),
                child: GestureDetector(
                  onTap: () {
                    Get.toNamed(NavigationConstants.sureOkuPage,
                        arguments: [sureadi, ayetno]);
                  },
                  child: Container(
                    padding: const EdgeInsets.all(25),
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
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        const SizedBox(
                          height: 10,
                        ),
                        SizedBox(
                          width: 290,
                          height: 38,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "${sureadi.toUpperCase()} ($ayetno) ",
                                style: const TextStyle(
                                  color: Colors.black,
                                  fontSize: 26,
                                  fontFamily: 'Source Serif Pro',
                                  fontWeight: FontWeight.w600,
                                  height: 0,
                                ),
                              ),
                              GestureDetector(
                                onTap: () {
                                  showDialog(
                                    context: context,
                                    builder: (BuildContext context) {
                                      return AlertDialog(
                                          surfaceTintColor: Colors.white,
                                          // backgroundColor: Colors.white,
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(30.0),
                                          ),
                                          content: Column(
                                            mainAxisSize: MainAxisSize.min,
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              const SizedBox(
                                                height: 25,
                                              ),
                                              const Text(
                                                'AYRAÇ',
                                                textAlign: TextAlign.center,
                                                style: TextStyle(
                                                  color: Colors.black,
                                                  fontSize: 16,
                                                  fontFamily: 'Axiforma',
                                                  fontWeight: FontWeight.w700,
                                                  height: 0,
                                                ),
                                              ),
                                              const SizedBox(height: 15),
                                              Padding(
                                                padding: EdgeInsets.only(
                                                    right: 25.w),
                                                child: Container(
                                                  width: 271,
                                                  decoration: const ShapeDecoration(
                                                    shape:
                                                        RoundedRectangleBorder(
                                                      side: BorderSide(
                                                        width: 1,
                                                        strokeAlign: BorderSide
                                                            .strokeAlignCenter,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              const SizedBox(height: 25),
                                              SizedBox(
                                                width: 271,
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    RichText(
                                                      text: TextSpan(
                                                        text:
                                                            "$sureadi Suresi, ",
                                                        style: const TextStyle(
                                                          color: Colors.black,
                                                          fontSize: 16,
                                                          fontFamily:
                                                              'Axiforma',
                                                          fontWeight:
                                                              FontWeight.w700,
                                                        ),
                                                        children: [
                                                          TextSpan(
                                                            text:
                                                                "$ayetno. Ayet",
                                                            style: const TextStyle(
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w700,
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                    const SizedBox(height: 8),
                                                    const Text(
                                                      "Ayraç Kaldırılsın mı?",
                                                      style: TextStyle(
                                                        color: Colors.black,
                                                        fontSize: 16,
                                                        fontFamily: 'Axiforma',
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              const SizedBox(height: 25),
                                              Container(
                                                child: Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.start,
                                                  children: [
                                                    GestureDetector(
                                                      onTap: () {
                                                        _deleteSavedAyah(index);
                                                        Navigator.pop(context);
                                                      },
                                                      child: ConstrainedBox(
                                                        constraints: const BoxConstraints(
                                                            minWidth:
                                                                100), // Minimum genişlik belirledik
                                                        child: Container(
                                                          padding:
                                                              const EdgeInsets
                                                                  .symmetric(
                                                                  horizontal:
                                                                      25,
                                                                  vertical: 20),
                                                          clipBehavior:
                                                              Clip.antiAlias,
                                                          decoration:
                                                              ShapeDecoration(
                                                            color: const Color(
                                                                0xFFE86014),
                                                            shape:
                                                                RoundedRectangleBorder(
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          10),
                                                            ),
                                                          ),
                                                          child: const Row(
                                                            mainAxisSize:
                                                                MainAxisSize
                                                                    .min,
                                                            mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .center,
                                                            crossAxisAlignment:
                                                                CrossAxisAlignment
                                                                    .center,
                                                            children: [
                                                              Text(
                                                                'EVET',
                                                                style:
                                                                    TextStyle(
                                                                  color: Colors
                                                                      .white,
                                                                  fontSize: 18,
                                                                  fontFamily:
                                                                      'Axiforma',
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w700,
                                                                  height: 0,
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                    const SizedBox(width: 30),
                                                    GestureDetector(
                                                      onTap: () {
                                                        Navigator.pop(context);
                                                      },
                                                      child: ConstrainedBox(
                                                        constraints: const BoxConstraints(
                                                            minWidth:
                                                                100), // Aynı minimum genişlik
                                                        child: Container(
                                                          padding:
                                                              const EdgeInsets
                                                                  .symmetric(
                                                                  horizontal:
                                                                      25,
                                                                  vertical: 20),
                                                          clipBehavior:
                                                              Clip.antiAlias,
                                                          decoration:
                                                              ShapeDecoration(
                                                            color: const Color(
                                                                0xFFE86014),
                                                            shape:
                                                                RoundedRectangleBorder(
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          10),
                                                            ),
                                                          ),
                                                          child: const Row(
                                                            mainAxisSize:
                                                                MainAxisSize
                                                                    .min,
                                                            mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .center,
                                                            crossAxisAlignment:
                                                                CrossAxisAlignment
                                                                    .center,
                                                            children: [
                                                              Text(
                                                                'HAYIR',
                                                                style:
                                                                    TextStyle(
                                                                  color: Colors
                                                                      .white,
                                                                  fontSize: 18,
                                                                  fontFamily:
                                                                      'Axiforma',
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w700,
                                                                  height: 0,
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
                                            ],
                                          ));
                                    },
                                  );
                                  // _deleteSavedAyah(index);
                                },
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child:
                                      Image.asset("assets/icon/ayracicon.png"),
                                ),
                              )
                            ],
                          ),
                        ),
                        const SizedBox(height: 25),
                        Container(
                          width: 290,
                          decoration: const ShapeDecoration(
                            shape: RoundedRectangleBorder(
                              side: BorderSide(
                                width: 1,
                                strokeAlign: BorderSide.strokeAlignCenter,
                                color: Color(0xFF60A6BB),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 30),
                        SizedBox(
                          child: RichText(
                            text: TextSpan(
                              text: metin,
                              style: const TextStyle(
                                fontSize: 30,
                                fontFamily: 'Kuranfont',
                                fontWeight: FontWeight.w400,
                                color: Color(0xFF2A89A5),
                              ),
                              locale: const Locale('ar', ''),
                            ),
                            textDirection: TextDirection.rtl,
                          ),
                        ),
                        const SizedBox(height: 25),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: SizedBox(
                            width: double.infinity,
                            child: RichText(
                              textAlign: TextAlign.center,
                              text: TextSpan(
                                  children: _parseText(meal, true),
                                  style: const TextStyle(
                                    color: Colors.black,
                                    fontSize: 26,
                                    fontFamily: 'Source Serif Pro',
                                    fontWeight: FontWeight.w600,
                                    height: 0,
                                  )),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
