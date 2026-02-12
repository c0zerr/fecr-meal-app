import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:fecrmeal/core/constants/color_constants.dart';
import 'package:url_launcher/url_launcher.dart';

class TeamInfoPage extends StatelessWidget {
  const TeamInfoPage({super.key});

  @override
  Widget build(BuildContext context) {
    final Uri url1 = Uri.parse('https://www.linkedin.com/company/tecnobis/');
    Future<void> launchUrl1() async {
      if (!await launchUrl(url1)) {
        throw Exception('Could not launch $url1');
      }
    }

    final Uri url2 = Uri.parse('https://tecnobis.com/');
    Future<void> launchUrl2() async {
      if (!await launchUrl(url2)) {
        throw Exception('Could not launch $url2');
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
          const Center(
            child: Text(
              "Yazılım",
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
              "Tecnobis",
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
              GestureDetector(
                  onTap: launchUrl1,
                  child: Image.asset("assets/icon/linkedin.png")),
              const SizedBox(
                width: 5,
              ),
              GestureDetector(
                  onTap: launchUrl2,
                  child: Image.asset("assets/icon/domain.png")),
            ],
          ),
          SizedBox(
            height: 30.h,
          ),
          const Center(
            child: Text(
              "UI / UX Tasarım",
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
              Image.asset("assets/icon/icon1.png"),
              const SizedBox(
                width: 5,
              ),
              Image.asset("assets/icon/icon2.png"),
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
              Image.asset("assets/icon/icon2.png"),
            ],
          ),
          SizedBox(
            height: 30.h,
          ),
          const Center(
            child: Text(
              "Yönetmen",
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
              Image.asset("assets/icon/icon2.png"),
            ],
          ),
        ],
      ),
    );
  }
}
