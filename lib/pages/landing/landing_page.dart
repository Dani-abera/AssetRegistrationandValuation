import 'package:flutter/material.dart';
import '../../services/login_or_register.dart';
import 'landing_page_container.dart';

class LandingPage extends StatefulWidget {
  const LandingPage({super.key});

  @override
  State<LandingPage> createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _pageController.addListener(() {
      setState(() {
        _currentPage = _pageController.page!.round();
      });
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          PageView(
            controller: _pageController,
            children: [
              landingPageContainer(
                imagepath: 'assets/images/img1.png',
                title: "Welcome to Property Verify",
                subtitle: "Secure Your Land and Home with Confidence",
                context: context,
              ),
              landingPageContainer(
                imagepath: 'assets/images/img2.png',
                title: "Your Trusted Property Partner",
                subtitle: "Ensuring Authenticity in Every Transaction",
                context: context,
              ),
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
                haveButton: true,
              ),
            ],
          ),
          Positioned(
            bottom: 200,
            left: 0,
            right: 0,
            child: AnimatedOpacity(
              opacity: _currentPage < 2
                  ? 1.0
                  : 0.0, // Show arrow only on the first two pages
              duration: Duration(milliseconds: 300),
              child: Column(
                children: [
                  IconButton(
                    onPressed: () {
                      // Move to the next page
                      if (_currentPage < 2) {
                        // Ensure we don't go out of bounds
                        _pageController.nextPage(
                          duration:
                              Duration(milliseconds: 300), // Animation duration
                          curve: Curves.easeInOut, // Animation curve
                        );
                      }
                    },
                    icon: Icon(
                      Icons.arrow_forward,
                      color: Colors.green,
                      size: 30,
                    ),
                  ),
                  SizedBox(height: 5),
                  Text(
                    'Swipe to explore',
                    style: TextStyle(
                      color: Colors.green.withOpacity(0.8),
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
