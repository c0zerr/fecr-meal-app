import 'package:fecrmeal/core/constants/color_constants.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:get/get.dart';

class SavedSurePage extends StatefulWidget {
  const SavedSurePage({Key? key}) : super(key: key);

  @override
  _SavedSurePageState createState() => _SavedSurePageState();
}

class _SavedSurePageState extends State<SavedSurePage> {
  Future<List<Map<String, dynamic>>> _getSavedAyahs() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String>? savedAyahs = prefs.getStringList('savedAyahs');
    if (savedAyahs != null) {
      // Decode and remove duplicates based on `sureadi` and `ayetno`
      Map<String, Map<String, dynamic>> uniqueAyahs = {};
      for (String item in savedAyahs) {
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
      await prefs.setStringList('savedAyahs', uniqueAyahStrings);

      return ayahsList;
    }
    return [];
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
          style: TextStyle(
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

  Future<void> _deleteSavedAyah(int index) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String>? savedAyahs = prefs.getStringList('savedAyahs');
    if (savedAyahs != null) {
      savedAyahs.removeAt(index);
      await prefs.setStringList('savedAyahs', savedAyahs);
      setState(() {}); // Refresh the state after deletion
    }
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
              Text(text1,
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 18,
                    fontFamily: 'AxiformaBold',
                    fontWeight: FontWeight.w900,
                    height: 0,
                  )),
              SizedBox(height: 10),
              Container(
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(context).size.height * 0.64,
                ),
                child: ListView(
                  shrinkWrap: true,
                  children: [
                    Text(
                      text2,
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 26,
                        fontFamily: 'Source Serif Pro',
                        fontWeight: FontWeight.w400,
                        height: 0,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 10),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorConstants.primaryColor,
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.white, size: 30),
        backgroundColor: ColorConstants.primaryColor,
        centerTitle: true,
        title: Text(
          'Favori Ayetlerim',
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
        future: _getSavedAyahs(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          List<Map<String, dynamic>> savedAyahs = snapshot.data!;

          if (savedAyahs.isEmpty) {
            return Padding(
              padding: const EdgeInsets.all(25.0),
              child: Center(
                child: Text(
                  "Henüz bir favori ayetinizi eklemediniz",
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
            itemCount: savedAyahs.length,
            itemBuilder: (context, index) {
              String sureadi = savedAyahs[index]['sureadi'];
              int ayetno = savedAyahs[index]['ayetno'];
              String metin = savedAyahs[index]['metin'];
              String meal = savedAyahs[index]['meal'];
              return Padding(
                padding: const EdgeInsets.all(25.0),
                child: Container(
                  padding: const EdgeInsets.all(25),
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
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      SizedBox(height: 10),
                      Container(
                        width: 290,
                        height: 38,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "${sureadi.toUpperCase()} ($ayetno)",
                              style: TextStyle(
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
                                            SizedBox(
                                              height: 15,
                                            ),
                                            Text(
                                              'FAVORİ AYETLER',
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
                                              padding:
                                                  EdgeInsets.only(right: 25.w),
                                              child: Container(
                                                width: 271,
                                                decoration: ShapeDecoration(
                                                  shape: RoundedRectangleBorder(
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
                                                          "$sureadi Suresi, $ayetno. Ayet",
                                                      style: TextStyle(
                                                        color: Colors.black,
                                                        fontSize: 16,
                                                        fontFamily: 'Axiforma',
                                                        fontWeight:
                                                            FontWeight.w700,
                                                      ),
                                                    ),
                                                  ),
                                                  SizedBox(height: 8),
                                                  Text(
                                                    "Favorilerden Kaldırılsın mı?",
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
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                mainAxisAlignment:
                                                    MainAxisAlignment.start,
                                                children: [
                                                  GestureDetector(
                                                    onTap: () {
                                                      _deleteSavedAyah(index);
                                                      Navigator.pop(context);
                                                    },
                                                    child: ConstrainedBox(
                                                      constraints: BoxConstraints(
                                                          minWidth:
                                                              100), // Minimum genişlik belirledik
                                                      child: Container(
                                                        padding:
                                                            const EdgeInsets
                                                                .symmetric(
                                                                horizontal: 25,
                                                                vertical: 20),
                                                        clipBehavior:
                                                            Clip.antiAlias,
                                                        decoration:
                                                            ShapeDecoration(
                                                          color:
                                                              Color(0xFFE86014),
                                                          shape:
                                                              RoundedRectangleBorder(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        10),
                                                          ),
                                                        ),
                                                        child: Row(
                                                          mainAxisSize:
                                                              MainAxisSize.min,
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .center,
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .center,
                                                          children: [
                                                            Text(
                                                              'EVET',
                                                              textAlign:
                                                                  TextAlign
                                                                      .center,
                                                              style: TextStyle(
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
                                                      constraints: BoxConstraints(
                                                          minWidth:
                                                              100), // Aynı minimum genişlik
                                                      child: Container(
                                                        padding:
                                                            const EdgeInsets
                                                                .symmetric(
                                                                horizontal: 25,
                                                                vertical: 20),
                                                        clipBehavior:
                                                            Clip.antiAlias,
                                                        decoration:
                                                            ShapeDecoration(
                                                          color:
                                                              Color(0xFFE86014),
                                                          shape:
                                                              RoundedRectangleBorder(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        10),
                                                          ),
                                                        ),
                                                        child: Row(
                                                          mainAxisSize:
                                                              MainAxisSize.min,
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .center,
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .center,
                                                          children: [
                                                            Text(
                                                              'HAYIR',
                                                              style: TextStyle(
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
                                            )
                                          ],
                                        ));
                                  },
                                );
                              },
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child:
                                    Image.asset("assets/icon/favoriicon.png"),
                              ),
                            )
                          ],
                        ),
                      ),
                      const SizedBox(height: 25),
                      Container(
                        width: 290,
                        decoration: ShapeDecoration(
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
                            style: TextStyle(
                              fontSize: 30,
                              fontFamily: 'Kuranfont',
                              fontWeight: FontWeight.w400,
                              color: Color(0xFF2A89A5),
                            ),
                            locale: Locale('ar', ''),
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
                                style: TextStyle(
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
              );
            },
          );
        },
      ),
    );
  }
}
