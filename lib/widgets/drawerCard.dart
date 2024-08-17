import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class DrawerCards extends StatelessWidget {
  final String title;
  final String imageUrl;
  final void Function()? ontap;

  const DrawerCards({
    Key? key,
    required this.title,
    required this.imageUrl,
    required this.ontap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(minWidth: 100.w, maxWidth: 300.w),
      decoration: BoxDecoration(
        color: const Color(0Xff2B89A5),
        borderRadius: BorderRadius.circular(10),
      ),
      margin: const EdgeInsets.symmetric(vertical: 3, horizontal: 3),
      child: InkWell(
        onTap: ontap,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              // SizedBox(width: 10.w),
              Image.asset(
                imageUrl,
                width: 50.w,
                height: 50.h,
              ),
              // SizedBox(width: 2.w),
              Text(
                title,
                style: const TextStyle(
                    fontFamily: "Axiforma", fontSize: 18, color: Colors.white),
                overflow: TextOverflow.ellipsis,
              ),
              SizedBox(width: 10.w),
            ],
          ),
        ),
      ),
    );
  }
}
