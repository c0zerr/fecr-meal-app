import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:fecrmeal/core/constants/color_constants.dart';

class TeamInfoPage extends StatelessWidget {
  const TeamInfoPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorConstants.primaryColor,
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          "Ekip",
          style: TextStyle(
color: Colors.white,
fontSize: 20,
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
              icon: Icon(
                Icons.arrow_back,
                size: 30,
                color: ColorConstants.whiteColor,
              )),
        ),
      ),
      body: Column(
        children: [
          SizedBox(
            height: 350.h,
          ),
          Center(
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
          Center(
            child: Text(
              "Coşkun Işıkgül",
              style: TextStyle(
color: Colors.white,
fontSize: 20,
fontFamily: 'Axiforma',
fontWeight: FontWeight.w500,
height: 0,
letterSpacing: 5,
),
            ),
          ),
          SizedBox(
            height: 10,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset("assets/icon/icon1.png"),
              SizedBox(
                width: 5,
              ),
              Image.asset("assets/icon/icon2.png"),
            ],
          ),
          SizedBox(
            height: 50,
          ),
          Center(
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
          Center(
            child: Text(
              "Tecnobis",
              style: TextStyle(
color: Colors.white,
fontSize: 20,
fontFamily: 'Axiforma',
fontWeight: FontWeight.w500,
height: 0,
letterSpacing: 5,
),
            ),
          ),
          SizedBox(
            height: 5,
          ),
          Center(child: Image.asset("assets/icon/icon2.png")),
        ],
      ),
    );
  }
}
