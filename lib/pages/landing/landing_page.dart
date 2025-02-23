import 'package:flutter/material.dart';
import 'package:land_house_verify/services/login_or_register.dart';

import 'landing_page_container.dart';

class LandingPage extends StatelessWidget {
  const LandingPage({Key? key}) : super(key: key);


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        children: [
          landingPageContainer(
              imagepath:'assets/images/img1.png',
              title: 'Welcome to the Photo Gallery',
              subtitle:'Explore stunning images at your fingertips.',
              context: context
          ),
          landingPageContainer(
              imagepath:'assets/images/img2.png',
              title: 'View High-Quality Images',
              subtitle:'Tap on any image to view it in fullscreen.',
              context: context
          ),
          landingPageContainer(
              imagepath:'assets/images/img3.png',
              title:'Get Started Now!',
              subtitle:'Click the button below to explore the gallery.',
              context: context,
              ontap: () async {
                if(context.mounted){
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => const LoginOrRegister()),
                  );
                }
              },
              haveButton: true
          ),
        ],
      ),
    );
  }
}
