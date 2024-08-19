// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:fecrmeal/core/constants/color_constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  @override
  void Function()? onTapMenu;
  void Function()? onTapSearch;

  CustomAppBar({
    Key? key,
    required this.onTapMenu,
    required this.onTapSearch,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      toolbarHeight: 80,
      backgroundColor: ColorConstants.primaryColor,
      leading: Padding(
        padding:  EdgeInsets.only(left: 20.w),
        child: IconButton(
            icon: Icon(
              Icons.menu,
              size: 35,
              color: Colors.white,
            ),
            onPressed: onTapMenu),
      ),
      title: Center(
        child: Image.asset(
          'assets/icon/mainicon.png',
          height: 55,
        ),
      ),
      actions: [
        IconButton(
          icon: Icon(
            Icons.search,
            size: 0,
            color: ColorConstants.whiteColor,
          ),
          onPressed: onTapSearch,
        ),
      ],
    );
  }

  @override
  // TODO: implement preferredSize
  Size get preferredSize => throw UnimplementedError();
}
