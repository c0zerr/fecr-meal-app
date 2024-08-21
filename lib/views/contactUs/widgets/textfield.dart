import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fecrmeal/core/constants/color_constants.dart';

class CustomTextfield extends StatelessWidget {
  final String text;
  final TextEditingController controller;
  const CustomTextfield({
    super.key,
    required this.text,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: ColorConstants.textfieldBackground),
        child: Center(
          child: TextField(
            controller: controller,
            decoration: InputDecoration(
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
              contentPadding: EdgeInsetsDirectional.only(start: 15),
              hintText: text,
              hintStyle: TextStyle(
                color: Color(0xFF0E5770),
                fontSize: 14,
                fontFamily: 'Axiforma',
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
        ));
  }
}
