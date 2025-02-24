import 'package:flutter/material.dart';
import 'package:land_house_verify/services/login_or_register.dart';

import 'landing_page_container.dart';

class LandingPage extends StatelessWidget {
  const LandingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        children: [
          landingPageContainer(
              imagepath: 'assets/images/img1.png',
              title: "Welcome to Property Verify",
              subtitle: "Secure Your Land and Home with Confidence",
              context: context),
          landingPageContainer(
              imagepath: 'assets/images/img2.png',
              title: "Your Trusted Property Partner",
              subtitle: "Ensuring Authenticity in Every Transaction",
              context: context),
          landingPageContainer(
              imagepath: 'assets/images/img3.png',
              title: 'Get Started Now!',
              subtitle: 'Click the button below to explore.',
              context: context,
              ontap: () async {
                if (context.mounted) {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const LoginOrRegister()),
                  );
                }
              },
              haveButton: true),
        ],
      ),
    );
  }
}
