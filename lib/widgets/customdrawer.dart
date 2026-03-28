import 'package:fecrmeal/core/constants/color_constants.dart';
import 'package:fecrmeal/core/constants/navigation_constants.dart';
import 'package:fecrmeal/views/pdfviewer/pdfviewer.dart';
import 'package:fecrmeal/widgets/drawerCard.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

// dart:io ve path_provider yalnızca mobil/desktop'ta çalışır.
// Web yapısında bu importlar derleme hatasına neden olur,
// bu yüzden conditional import kullanıyoruz.
import 'package:fecrmeal/widgets/pdf_helper_mobile.dart'
    if (dart.library.html) 'package:fecrmeal/widgets/pdf_helper_web.dart'
    as pdfHelper;

class CustomDrawer extends StatefulWidget {
  const CustomDrawer({
    super.key,
  });

  @override
  State<CustomDrawer> createState() => _CustomDrawerState();
}

class _CustomDrawerState extends State<CustomDrawer> {
  String corruptedPathPDF = "";

  @override
  void initState() {
    super.initState();
    if (!kIsWeb) {
      pdfHelper
          .fromAsset('assets/Kahakkinda.pdf', 'Kahakkinda.pdf')
          .then((filePath) {
        setState(() {
          corruptedPathPDF = filePath;
        });
      }).catchError((e) {
        debugPrint('PDF yüklenemedi: $e');
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      width: MediaQuery.of(context).size.width * 0.90,
      backgroundColor: ColorConstants.primaryColor,
      child: Padding(
        padding: EdgeInsets.only(left: 15.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 60.h),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10.0),
              height: 100.0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Image.asset("assets/icon/mainicon.png"),
                  IconButton(
                    icon: const Icon(
                      Icons.close,
                      color: Color(0xff60A6BB),
                      size: 30,
                    ),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                ],
              ),
            ),
            SizedBox(height: 40.h),
            DrawerCards(
              title: "Kaldığım Yer",
              imageUrl: "assets/icon/kayit.png",
              ontap: () {
                Get.toNamed(NavigationConstants.ayracSurePage);
              },
            ),
            DrawerCards(
              title: "Favoriler Ayetlerim",
              imageUrl: "assets/icon/favori.png",
              ontap: () {
                Get.toNamed(NavigationConstants.sureSavedPage);
              },
            ),
            DrawerCards(
              title: "Ayarlar",
              iconData: Icons.settings_outlined,
              ontap: () {
                Get.toNamed(NavigationConstants.settingsPage);
              },
            ),
            const SizedBox(height: 15),
            DrawerCards(
              title: "Önsöz  ",
              imageUrl: "assets/icon/info.png",
              ontap: () {
                Get.toNamed(NavigationConstants.kuranAydinliginaDair);
              },
            ),
            DrawerCards(
              title: "Kur'an Aydınlığına Dair",
              imageUrl: "assets/icon/info.png",
              ontap: () {
                if (!kIsWeb) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          PDFScreen(path: corruptedPathPDF),
                    ),
                  );
                }
              },
            ),
            DrawerCards(
              title: "Tuncer Namlı",
              imageUrl: "assets/icon/user.png",
              ontap: () {
                Get.toNamed(NavigationConstants.tuncerNamliPage);
              },
            ),
            const SizedBox(height: 15),
            DrawerCards(
              title: "Görüş ve Önerileriniz",
              imageUrl: "assets/icon/ulasin.png",
              ontap: () {
                Get.toNamed(NavigationConstants.contactUsPage);
              },
            ),
            DrawerCards(
              title: "Ekip",
              imageUrl: "assets/icon/team.png",
              ontap: () {
                Get.toNamed(NavigationConstants.teamPage);
              },
            ),
          ],
        ),
      ),
    );
  }
}
