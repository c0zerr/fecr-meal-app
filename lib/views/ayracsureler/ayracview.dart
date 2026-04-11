import 'package:fecrmeal/core/constants/color_constants.dart';
import 'package:fecrmeal/core/constants/navigation_constants.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:get/get.dart';
import 'package:fecrmeal/core/data/sureList.dart';

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

              String formatSureAdiForDisplay(String value) {
                final v = value.trim();
                if (v.isEmpty) return value;
                final first = v[0];
                final String upperFirst;
                if (first == 'i') {
                  upperFirst = 'İ';
                } else if (first == 'ı') {
                  upperFirst = 'I';
                } else {
                  upperFirst = first.toUpperCase();
                }
                return upperFirst + v.substring(1).toLowerCase();
              }

              int getSureId(String name) {
                final normalizedName = name.trim().toLowerCase().replaceAll('ı', 'i').replaceAll('i̇', 'i').replaceAll('ğ', 'g').replaceAll('ü', 'u').replaceAll('ş', 's').replaceAll('ö', 'o').replaceAll('ç', 'c').replaceAll('â', 'a').replaceAll('î', 'i').replaceAll('û', 'u').replaceAll('-', '').replaceAll('\'', '').replaceAll('’', '');
                int idx = mushafSirasi.indexWhere((element) {
                  final sName = element['name'].toString().trim().toLowerCase().replaceAll('ı', 'i').replaceAll('i̇', 'i').replaceAll('ğ', 'g').replaceAll('ü', 'u').replaceAll('ş', 's').replaceAll('ö', 'o').replaceAll('ç', 'c').replaceAll('â', 'a').replaceAll('î', 'i').replaceAll('û', 'u').replaceAll('-', '').replaceAll('\'', '').replaceAll('’', '');
                  return sName == normalizedName;
                });
                return idx != -1 ? idx + 1 : 0;
              }
              
              int sureId = getSureId(sureadi);
              String idPrefix = sureId > 0 ? "$sureId- " : "";

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
                                "$idPrefix${formatSureAdiForDisplay(sureadi)} ($ayetno) ",
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
                                      String formatSureAdiForDisplay(String value) {
                                        final v = value.trim();
                                        if (v.isEmpty) return value;
                                        final first = v[0];
                                        final String upperFirst;
                                        if (first == 'i') {
                                          upperFirst = 'İ';
                                        } else if (first == 'ı') {
                                          upperFirst = 'I';
                                        } else {
                                          upperFirst = first.toUpperCase();
                                        }
                                        return upperFirst + v.substring(1);
                                      }

                                      const primaryColor = Color(0xFF2A89A5);
                                      const dangerColor = Color(0xFFE86014);
                                      return AlertDialog(
                                        surfaceTintColor: Colors.white,
                                        backgroundColor: const Color(0xFFF3F3F5),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(30.0),
                                        ),
                                        insetPadding: const EdgeInsets.symmetric(horizontal: 24),
                                        titlePadding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
                                        contentPadding: const EdgeInsets.fromLTRB(24, 12, 24, 0),
                                        actionsPadding: const EdgeInsets.fromLTRB(24, 0, 24, 20),
                                        title: const Text(
                                          'AYRAÇ',
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                            color: Colors.black,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 20,
                                          ),
                                        ),
                                        content: SizedBox(
                                          width: MediaQuery.of(context).size.width * 0.9,
                                          child: Column(
                                            mainAxisSize: MainAxisSize.min,
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              const Divider(
                                                color: Colors.black26,
                                                thickness: 1,
                                                height: 1,
                                              ),
                                              const SizedBox(height: 18),
                                              Text(
                                                "${formatSureAdiForDisplay(sureadi)} Suresi, $ayetno. Ayet",
                                                style: const TextStyle(
                                                  color: Colors.black,
                                                  fontWeight: FontWeight.w700,
                                                  fontSize: 18,
                                                  height: 1.25,
                                                ),
                                              ),
                                              const SizedBox(height: 10),
                                              const Text(
                                                "Ayraç Kaldırılsın mı?",
                                                style: TextStyle(
                                                  color: Colors.black,
                                                  fontWeight: FontWeight.w400,
                                                  fontSize: 18,
                                                  height: 1.25,
                                                ),
                                              ),
                                              const SizedBox(height: 18),
                                            ],
                                          ),
                                        ),
                                        actions: [
                                          SizedBox(
                                            width: double.infinity,
                                            child: Row(
                                              children: [
                                                Expanded(
                                                  child: OutlinedButton(
                                                    onPressed: () => Navigator.pop(context),
                                                    style: OutlinedButton.styleFrom(
                                                      foregroundColor: primaryColor,
                                                      side: const BorderSide(color: primaryColor, width: 1.5),
                                                      padding: const EdgeInsets.symmetric(vertical: 14),
                                                      textStyle: const TextStyle(
                                                        fontSize: 16,
                                                        fontWeight: FontWeight.w700,
                                                      ),
                                                      shape: RoundedRectangleBorder(
                                                        borderRadius: BorderRadius.circular(14),
                                                      ),
                                                    ),
                                                    child: const Text("HAYIR"),
                                                  ),
                                                ),
                                                const SizedBox(width: 12),
                                                Expanded(
                                                  child: FilledButton(
                                                    onPressed: () {
                                                      _deleteSavedAyah(index);
                                                      Navigator.pop(context);
                                                    },
                                                    style: FilledButton.styleFrom(
                                                      backgroundColor: dangerColor,
                                                      foregroundColor: Colors.white,
                                                      padding: const EdgeInsets.symmetric(vertical: 14),
                                                      textStyle: const TextStyle(
                                                        fontSize: 16,
                                                        fontWeight: FontWeight.w800,
                                                      ),
                                                      shape: RoundedRectangleBorder(
                                                        borderRadius: BorderRadius.circular(14),
                                                      ),
                                                    ),
                                                    child: const Text("EVET"),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      );
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
                                fontFamily: 'KuranFont',
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
