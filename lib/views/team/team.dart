import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:fecrmeal/core/constants/color_constants.dart';
import 'package:url_launcher/url_launcher.dart';

class TeamInfoPage extends StatelessWidget {
  const TeamInfoPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Web Sitesi Linki
    final Uri urlWebsite = Uri.parse('https://kuranmeal.tr');
    Future<void> launchWebsite() async {
      if (!await launchUrl(urlWebsite)) {
        throw Exception('Could not launch $urlWebsite');
      }
    }

    // Mail Linki (Coşkun Işıkgül)
    final Uri urlMailCoskun = Uri.parse('mailto:coskunmail@gmail.com');
    Future<void> launchMailCoskun() async {
      if (!await launchUrl(urlMailCoskun)) {
        throw Exception('Could not launch $urlMailCoskun');
      }
    }

    // Mail Linki (Muhammed Nazlıaydın)
    final Uri urlMailMuhammed = Uri.parse('mailto:mnzlydn@gmail.com');
    Future<void> launchMailMuhammed() async {
      if (!await launchUrl(urlMailMuhammed)) {
        throw Exception('Could not launch $urlMailMuhammed');
      }
    }

    // Mail Linki (Hüseyin Nazlıaydın)
    final Uri urlMailHuseyin = Uri.parse('mailto:hnazliaydin@hotmail.com');
    Future<void> launchMailHuseyin() async {
      if (!await launchUrl(urlMailHuseyin)) {
        throw Exception('Could not launch $urlMailHuseyin');
      }
    }

    return Scaffold(
      backgroundColor: ColorConstants.primaryColor,
      appBar: AppBar(
        centerTitle: true,
        title: const Text(
          "Ekip",
          style: TextStyle(
            color: Colors.white,
            fontSize: 19,
            fontFamily: 'Axiforma',
            fontWeight: FontWeight.w700,
            height: 0,
          ),
        ),
        toolbarHeight: 100,
        backgroundColor: ColorConstants.primaryColor,
        leading: Padding(
          padding: const EdgeInsets.all(0.0),
          child: IconButton(
              onPressed: () => Get.back(),
              icon: const Icon(
                Icons.arrow_back,
                size: 30,
                color: ColorConstants.whiteColor,
              )),
        ),
      ),
      body: Column(
        children: [
          SizedBox(
            height: 150.h,
          ),
          // Yazılım/Tecnobis Bölümü Kaldırıldı
          
          const Center(
            child: Text(
              "Tasarımcısı ve Geliştiricisi",
              style: TextStyle(
                color: Color(0xFF60A6BB),
                fontSize: 16,
                fontFamily: 'Axiforma',
                fontWeight: FontWeight.w400,
                height: 0,
              ),
            ),
          ),
          const Center(
            child: Text(
              "Coşkun Işıkgül",
              style: TextStyle(
                color: Colors.white,
                fontSize: 19,
                fontFamily: 'Axiforma',
                fontWeight: FontWeight.w500,
                height: 0,
                letterSpacing: 3,
              ),
            ),
          ),
          const SizedBox(
            height: 10,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Modern Web Sitesi Butonu
              IconButton(
                onPressed: launchWebsite,
                icon: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withOpacity(0.1),
                  ),
                  child: const Icon(
                    Icons.language, // Web Sitesi ikonu
                    color: Colors.white,
                    size: 24,
                  ),
                ),
              ),
              const SizedBox(
                width: 10,
              ),
              // Modern Mail Butonu
              IconButton(
                onPressed: launchMailCoskun,
                icon: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withOpacity(0.1),
                  ),
                  child: const Icon(
                    Icons.mail_outline,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(
            height: 30.h,
          ),
          const Center(
            child: Text(
              "Meal API Editörü",
              style: TextStyle(
                color: Color(0xFF60A6BB),
                fontSize: 16,
                fontFamily: 'Axiforma',
                fontWeight: FontWeight.w400,
                height: 0,
              ),
            ),
          ),
          const Center(
            child: Text(
              "Muhammed Nazlıaydın",
              style: TextStyle(
                color: Colors.white,
                fontSize: 19,
                fontFamily: 'Axiforma',
                fontWeight: FontWeight.w500,
                height: 0,
                letterSpacing: 3,
              ),
            ),
          ),
          const SizedBox(
            height: 5,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
               // Modern Mail Butonu
              IconButton(
                onPressed: launchMailMuhammed,
                icon: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withOpacity(0.1),
                  ),
                  child: const Icon(
                    Icons.mail_outline,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(
            height: 30.h,
          ),
          const Center(
            child: Text(
              "Editör",
              style: TextStyle(
                color: Color(0xFF60A6BB),
                fontSize: 16,
                fontFamily: 'Axiforma',
                fontWeight: FontWeight.w400,
                height: 0,
              ),
            ),
          ),
          const Center(
            child: Text(
              "Hüseyin Nazlıaydın",
              style: TextStyle(
                color: Colors.white,
                fontSize: 19,
                fontFamily: 'Axiforma',
                fontWeight: FontWeight.w500,
                height: 0,
                letterSpacing: 3,
              ),
            ),
          ),
          const SizedBox(
            height: 5,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
               // Modern Mail Butonu
              IconButton(
                onPressed: launchMailHuseyin,
                icon: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withOpacity(0.1),
                  ),
                  child: const Icon(
                    Icons.mail_outline,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
