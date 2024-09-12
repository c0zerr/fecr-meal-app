import 'package:fecrmeal/core/constants/color_constants.dart';
import 'package:fecrmeal/core/constants/navigation_constants.dart';
import 'package:fecrmeal/widgets/drawerCard.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

class CustomDrawer extends StatelessWidget {
  const CustomDrawer({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Drawer(
      width: MediaQuery.of(context).size.width * 0.90,
      backgroundColor: ColorConstants.primaryColor,
      child: Padding(
        padding: EdgeInsets.only(left: 15.w),
        child: Column(
          // mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: 60.h,
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10.0),
              height: 100.0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Image.asset(
                    "assets/icon/mainicon.png", // Adjust image path
                  ),
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
            SizedBox(
              height: 40.h,
            ),
            DrawerCards(
                title: "Kaldığım Yer",
                imageUrl: "assets/icon/kayit.png",
                ontap: () {
                  Get.toNamed(
                    NavigationConstants.ayracSurePage,
                  );
                }),
            DrawerCards(
                title: "Favoriler Ayetlerim",
                imageUrl: "assets/icon/favori.png",
                ontap: () {
                  Get.toNamed(
                    NavigationConstants.sureSavedPage,
                  );
                }),
            const SizedBox(
              height: 15,
            ),
            DrawerCards(
                title: "Önsöz  ",
                imageUrl: "assets/icon/info.png",
                ontap: () {
                  Get.toNamed(
                    NavigationConstants.kuranAydinliginaDair,
                  );
                }),
            DrawerCards(
                title: "Kur’an Aydınlığına Dair",
                imageUrl: "assets/icon/info.png",
                ontap: () {
                  Get.toNamed(
                    NavigationConstants.kuranAydinliginaDair,
                  );
                }),
            DrawerCards(
                title: "Tuncer Namlı",
                imageUrl: "assets/icon/user.png",
                ontap: () {
                  Get.toNamed(
                    NavigationConstants.tuncerNamliPage,
                  );
                }),
            const SizedBox(
              height: 15,
            ),
            DrawerCards(
                title: "Görüş ve Önerileriniz",
                imageUrl: "assets/icon/ulasin.png",
                ontap: () {
                  Get.toNamed(
                    NavigationConstants.contactUsPage,
                  );
                }),
            DrawerCards(
                title: "Ekip",
                imageUrl: "assets/icon/team.png",
                ontap: () {
                  Get.toNamed(
                    NavigationConstants.teamPage,
                  );
                }),
          ],
        ),
      ),
    );
  }
}
