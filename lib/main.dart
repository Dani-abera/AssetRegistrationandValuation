import 'package:flutter/material.dart';
import 'package:land_house_verify/pages/validator/valuation_Input_page.dart';

import 'package:land_house_verify/service_locator.dart';
import 'package:land_house_verify/services/login_or_register.dart';
import 'package:land_house_verify/themes/themes_provider.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async {
  // Initialize Flutter Binding
  WidgetsFlutterBinding.ensureInitialized();
  // Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  setupLocator();
  runApp(
    MultiProvider(
      providers: [
        // ChangeNotifierProvider for ThemeProvider to manage theme-related state
        ChangeNotifierProvider(
          create: (context) => ThemeProvider(),
        ),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title:
          'Property Registration and Verification System', // Title of the application

      theme: Provider.of<ThemeProvider>(context).themeData,

      //home: LoginOrRegister(),
      home: ValidationInputScreen(
        assetId: '1',
      ),
    );
  }
}
