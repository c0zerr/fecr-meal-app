import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:fecrmeal/core/constants/color_constants.dart';
import 'package:fecrmeal/core/constants/navigation_constants.dart';
import 'package:fecrmeal/core/controller/homepageController.dart';
import 'package:fecrmeal/widgets/customappbar.dart';
import 'package:fecrmeal/widgets/customdrawer.dart';
import 'package:fecrmeal/core/data/sureList.dart';
import 'package:fecrmeal/core/data/sureList2.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  HomePageController homePageController = Get.put(HomePageController());

  String validateSurahAndVerse(String surahName, int? verseNumber) {
    // Surenin adı büyük/küçük harf duyarlı olabilir
    final surah = surelerr.firstWhere(
        (surah) => surah['name'].toLowerCase() == surahName.toLowerCase(),
        orElse: () => {'name': '', 'verseCount': 0});

    if (surah['name'] == '') {
      return 'Lütfen Sure Adını Kontrol Ediniz';
    }

    if (verseNumber == null ||
        verseNumber < 1 ||
        verseNumber > surah['verseCount']) {
      return 'Lütfen Ayet Numarasını Kontrol Ediniz';
    }

    return '';
  }

  @override
  Widget build(BuildContext context) {
    final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
    TextEditingController sureadi = TextEditingController();
    TextEditingController ayetno = TextEditingController();

    return Scaffold(
      key: _scaffoldKey,
      // appBar: AppBar(),
      backgroundColor: ColorConstants.primaryColor,
      drawer: CustomDrawer(),
      body: Column(
        children: [
          CustomAppBar(
              onTapMenu: () {
                _scaffoldKey.currentState?.openDrawer();
              },
              onTapSearch: null),
          SizedBox(
            height: 15,
          ),
          Expanded(
            child: Stack(
              children: [
                GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () {
                    if (homePageController.showdialog.value) {
                      homePageController.showdialog.value = false;
                    }
                  },
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        SizedBox(height: 5.h),
                        Obx(() => Padding(
                              padding: EdgeInsets.only(left: 30.w, right: 30.w),
                              child: Container(
                                height: 55.h,
                                width: double.infinity,
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    width: 1,
                                    color: homePageController.showdialog.value
                                        ? Colors.white
                                        : Color(0xff60A6BB),
                                  ),
                                  borderRadius: BorderRadius.circular(10.h),
                                ),
                                child: ElevatedButton(
                                  onPressed: () {
                                    homePageController.showdialog.value =
                                        !homePageController.showdialog.value;
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.transparent,
                                    shadowColor: Colors.transparent,
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 10,
                                      horizontal: 20,
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
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
                                      Obx(
                                        () => Icon(
                                          homePageController.showdialog.value
                                              ? Icons.keyboard_arrow_up_outlined
                                              : Icons
                                                  .keyboard_arrow_down_outlined,
                                          color: Color(0xff60A6BB),
                                          size: 30,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            )),
                        SizedBox(height: 5.h),
                        Padding(
                          padding: EdgeInsets.only(
                              top: 10.h, left: 25.w, right: 25.w),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              Text(
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
                                () => Container(
                                  width: 174.w,
                                  height: 46.h,
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                      width: 1,
                                      color: Color(0xff60a6bb),
                                    ),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      TextButton(
                                        onPressed: () {
                                          homePageController.changeQueue.value =
                                              !homePageController
                                                  .changeQueue.value;
                                        },
                                        child: Row(
                                          children: [
                                            Text(
                                              homePageController
                                                      .changeQueue.value
                                                  ? "Mushaf Sırası"
                                                  : "Nüzul Sırası",
                                              style: TextStyle(
                                                color: Color(0xFF60A6BB),
                                                fontSize: 16,
                                                fontFamily: 'Axiforma',
                                                fontWeight: FontWeight.w400,
                                                height: 0,
                                              ),
                                            ),
                                            SizedBox(width: 5.w),
                                            Image.asset(
                                                "assets/icon/updown.png"),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Obx(
                          () => ListView.builder(
                            shrinkWrap: true,
                            physics: NeverScrollableScrollPhysics(),
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
                                      print('Item $index tapped');
                                      print(
                                          'Item ${chosenList[index]['name']} tapped');

                                      Get.toNamed(
                                          NavigationConstants.sureOkuPage,
                                          arguments: [
                                            "${chosenList[index]['name']}",
                                            1
                                          ]);
                                      // SureOkuPage(ayetno: "1",sureadi: "${chosenList[index]['title2']}",);
                                    },
                                    child: Container(
                                      width: 340.w,
                                      // height: 90.h,
                                      padding: EdgeInsets.symmetric(
                                        horizontal: 30.h,
                                        vertical: 15.w,
                                      ),
                                      clipBehavior: Clip.antiAlias,
                                      decoration: ShapeDecoration(
                                        color: Colors.white,
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
                                          Container(
                                            // width: 182.w,
                                            child: Column(
                                              // mainAxisSize: MainAxisSize.min,
                                              mainAxisAlignment:
                                                  MainAxisAlignment.start,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                SizedBox(
                                                  width: 182.w,
                                                  height: 30.h,
                                                  child: Text(
                                                    chosenList[index]['name'],
                                                    style: TextStyle(
                                                      color: Color(0xFF464646),
                                                      fontSize: 28,
                                                      fontFamily: 'Podkova',
                                                      fontWeight:
                                                          FontWeight.w700,
                                                      height: 0,
                                                    ),
                                                  ),
                                                ),
                                                const SizedBox(height: 5),
                                                SizedBox(
                                                  width: 182.w,
                                                  child: Text(
                                                    "${chosenList[index]['verseCount'] - 1} Ayet",
                                                    style: TextStyle(
                                                      color: Color(0xFF2A89A5),
                                                      fontSize: 16,
                                                      fontFamily: 'Podkova',
                                                      fontWeight:
                                                          FontWeight.w500,
                                                      height: 0,
                                                      letterSpacing: 8,
                                                    ),
                                                  ),
                                                ),
                                                SizedBox(
                                                  height: 5.h,
                                                )
                                              ],
                                            ),
                                          ),
                                          SizedBox(width: 0.w),
                                          Container(
                                            width: 60.w,
                                            height: 60.h,
                                            child: Stack(
                                              children: [
                                                Positioned(
                                                  left: 0,
                                                  top: 0,
                                                  child: Container(
                                                    width: 60.w,
                                                    height: 60.h,
                                                    decoration: ShapeDecoration(
                                                      color: Color(0x192A89A5),
                                                      shape: OvalBorder(),
                                                    ),
                                                  ),
                                                ),
                                                Center(
                                                  child: Text(
                                                    (index + 1).toString(),
                                                    textAlign: TextAlign.center,
                                                    style: TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 38,
                                                      fontFamily: 'Podkova',
                                                      fontWeight:
                                                          FontWeight.w700,
                                                      height: 1.0,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          const SizedBox(width: 10),
                                          Icon(
                                            Icons.arrow_forward_ios_rounded,
                                            color: ColorConstants.primaryColor3,
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
                        SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),
                Obx(
                  () => Visibility(
                    visible: homePageController.showdialog.value,
                    child: Positioned(
                      left: 10.w,
                      right: 10.w,
                      top: 60.h,
                      child: AnimatedOpacity(
                        opacity:
                            homePageController.showdialog.value ? 1.0 : 0.0,
                        duration: Duration(milliseconds: 500),
                        child: AnimatedContainer(
                          duration: Duration(milliseconds: 500),
                          margin: EdgeInsets.only(top: 20.h),
                          decoration: BoxDecoration(
                            color: ColorConstants.primaryColor,
                            border:
                                Border.all(color: Color(0xFF60A6BB), width: 2),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: GestureDetector(
                            onTap: () {},
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(15),
                              child: BackdropFilter(
                                filter:
                                    ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
                                child: Column(
                                  children: [
                                    SizedBox(height: 15.h),
                                    Padding(
                                      padding: const EdgeInsets.all(4.0),
                                      child: Row(
                                        children: [
                                          SizedBox(width: 5.w),
                                          Text(
                                            'Sure Adı :',
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 20,
                                            ),
                                          ),
                                          SizedBox(width: 10.w),
                                          Expanded(
                                            flex: 8,
                                            child: TextField(
                                              controller: sureadi,
                                              decoration: InputDecoration(
                                                hintText:
                                                    'Surenin adını giriniz',
                                                hintStyle:
                                                    TextStyle(fontSize: 17),
                                                filled: true,
                                                fillColor: Colors.white,
                                                border: OutlineInputBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(15),
                                                  borderSide: BorderSide.none,
                                                ),
                                              ),
                                            ),
                                          ),
                                          SizedBox(width: 10.w),
                                        ],
                                      ),
                                    ),
                                    SizedBox(height: 20.h),
                                    Padding(
                                      padding: const EdgeInsets.all(4.0),
                                      child: Row(
                                        children: [
                                          SizedBox(width: 5.w),
                                          Text(
                                            'Ayet No : ',
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 20,
                                            ),
                                          ),
                                          SizedBox(width: 10.w),
                                          Container(
                                            width: 90.w,
                                            child: TextField(
                                              controller: ayetno,
                                              textAlign: TextAlign.center,
                                              decoration: InputDecoration(
                                                hintText: '***',
                                                filled: true,
                                                fillColor: Colors.white,
                                                border: OutlineInputBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(15),
                                                  borderSide: BorderSide.none,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    SizedBox(height: 20.h),
                                    Padding(
                                      padding: const EdgeInsets.only(
                                          left: 15, right: 15),
                                      child: Container(
                                        width: double.infinity,
                                        decoration: BoxDecoration(
                                          color: Colors.deepOrange,
                                          borderRadius:
                                              BorderRadius.circular(15),
                                        ),
                                        child: ElevatedButton(
                                          onPressed: () {
                                            // Kullanıcının girdiği surahName stringindeki baştaki ve sondaki boşlukları sil
                                            final surahName =
                                                sureadi.text.trim();
                                            final verseNumber =
                                                int.tryParse(ayetno.text);

                                            final validationError =
                                                validateSurahAndVerse(
                                                    surahName, verseNumber);

                                            if (validationError.isNotEmpty) {
                                              // Hata mesajını göster
                                              Get.snackbar(
                                                  'Hata', validationError);
                                            } else {
                                              // Hata yok, ayete git
                                              homePageController
                                                      .showdialog.value =
                                                  !homePageController
                                                      .showdialog.value;
                                              Get.toNamed(
                                                  NavigationConstants
                                                      .sureOkuPage,
                                                  arguments: [
                                                    surahName,
                                                    verseNumber
                                                  ]);
                                            }
                                          },
                                          style: ElevatedButton.styleFrom(
                                            padding: EdgeInsets.symmetric(
                                              vertical: 16,
                                              horizontal: 32,
                                            ),
                                            backgroundColor: Colors.transparent,
                                            elevation: 0,
                                          ),
                                          child: Text(
                                            'AYETE GİT',
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 20,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                    SizedBox(height: 15.h),
                                  ],
                                ),
                              ),
                            ),
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
