import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:flutter/material.dart';
import 'package:land_house_verify/components/my_button.dart';
import 'package:provider/provider.dart';
import 'package:land_house_verify/themes/themes_provider.dart';

Container landingPageContainer({
  required String imagepath,
  required String title,
  required String subtitle,
  required BuildContext context,
  VoidCallback? ontap,
  bool? haveButton = false,
}) {
  //final theme = Provider.of<ThemeProvider>(context); // Get the current theme

  return Container(
    decoration: BoxDecoration(
      gradient: LinearGradient(
        colors: [
          Colors.white30.withOpacity(0.8),
          Colors.white.withOpacity(1.0),
        ],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
    ),
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        ClipOval(
          child: Image.asset(
            imagepath,
            height: 120,
            width: 120,
            fit: BoxFit.cover,
          ),
        ),
        SizedBox(height: 20),
        DefaultTextStyle(
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Color(0xFF3855A8), // Use theme text color
          ),
          child: AnimatedTextKit(
            animatedTexts: [
              TypewriterAnimatedText(title),
            ],
            totalRepeatCount: 1,
          ),
        ),
        SizedBox(height: 10),
        DefaultTextStyle(
          style: TextStyle(fontSize: 18, color: Color(0xFF3855A8)),
          child: AnimatedTextKit(
            animatedTexts: [
              TypewriterAnimatedText(
                subtitle,
                speed: Duration(milliseconds: 100),
              ),
            ],
            totalRepeatCount: 1,
          ),
        ),
        SizedBox(height: 20),
        if (haveButton == true)
          Padding(
            padding: EdgeInsets.all(30),
            child: Container(
              width: double.infinity,
              height: 50.0,
              decoration: BoxDecoration(
                color: Color(0xFFF9A825), // Use theme button color
                borderRadius: BorderRadius.circular(10),
              ),
              child: MyButton(onTap: ontap, text: " Explore "),
            ),
          ),
      ],
    ),
  );
}
