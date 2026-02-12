import 'package:fecrmeal/core/constants/color_constants.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class CustomScrollbar extends StatelessWidget {
  final Widget child;
  final double thickness;

  const CustomScrollbar({super.key, required this.child, this.thickness = 4.0});

  @override
  Widget build(BuildContext context) {
    return RawScrollbar(
      thumbColor: ColorConstants.primaryColor3,
      thickness: 4,
      interactive: true,
      thumbVisibility: true,
      padding: const EdgeInsets.only(left: 5),
      radius: const Radius.circular(8),
      child: child,
    );
  }
}
