import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:flutter/material.dart';
import 'package:land_house_verify/components/my_button.dart';

Container landingPageContainer(
    {required String imagepath,
    required String title,
    required String subtitle,
    required BuildContext context,
    VoidCallback? ontap,
    bool? haveButton = false}) {
  return Container(
    color: Colors.white30,
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Image.asset(
          imagepath,
          height: 100,
          width: 100,
          fit: BoxFit.cover,
        ),
        SizedBox(height: 20),
        DefaultTextStyle(
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.black,
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
          style: TextStyle(fontSize: 16, color: Colors.grey[600]),
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
        haveButton == false
            ? Text("")
            : Padding(
                padding: EdgeInsets.all(30),
                child: Container(
                  width: double.infinity,
                  height: 50.0,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(colors: [
                      const Color.fromARGB(255, 168, 28, 161),
                      const Color.fromARGB(58, 76, 12, 85)
                    ]),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: MyButton(onTap: ontap, text: " Explore "),
                  // child: ElevatedButton(
                  //   style: ElevatedButton.styleFrom(
                  //     padding: EdgeInsets.symmetric(vertical: 15, horizontal: 30),
                  //     textStyle: TextStyle(fontSize: 18),
                  //     backgroundColor: Colors.transparent,
                  //     shadowColor: Colors.transparent,
                  //   ),
                  //   onPressed: ontap,
                  //   child: Text(
                  //     'Next',
                  //     style: TextStyle(color: Colors.white),
                  //   ),
                  // ),
                ),
              ),
      ],
    ),
  );
}
