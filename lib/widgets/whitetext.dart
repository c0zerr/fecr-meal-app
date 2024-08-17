import 'package:flutter/material.dart';

class WhiteText extends StatelessWidget {
  final String text;
  const WhiteText({
    Key? key,
    required this.text,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        text,
        style: TextStyle(
color: Colors.white,
fontSize: 18,
fontFamily: 'Axiforma',
fontWeight: FontWeight.w600,
height: 0.07,
letterSpacing: -0.41,
),
      ),
    );
  }
}
