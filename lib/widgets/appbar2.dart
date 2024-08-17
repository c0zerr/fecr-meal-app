import 'package:fecrmeal/core/constants/color_constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

class AppBar2 extends StatelessWidget {
  final String title;

  AppBar2({
    Key? key,
    required this.title,
  }) : super(key: key);

  @override
  AppBar build(BuildContext context) {
    return AppBar(
      centerTitle: true,
      title: Text(
        title,
        style: TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
            letterSpacing: 1),
      ),
      // toolbarHeight: 100,
      backgroundColor: ColorConstants.primaryColor,
      leading: IconButton(
          onPressed: () => Get.back(),
          icon: Icon(
            Icons.arrow_back,
            size: 30,
            color: ColorConstants.whiteColor,
          )),
    );
  }
}
