import 'package:flutter/material.dart';
import 'package:land_house_verify/pages/validator_registration_page.dart';

import 'package:land_house_verify/services/login_or_register.dart';
import 'package:land_house_verify/themes/themes_provider.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
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
      title:
          'Property Registration and Verification System', // Title of the application
      // The theme of the app is provided by ThemeProvider
      theme: Provider.of<ThemeProvider>(context).themeData,

      //home: RegisterValidatorPage(),
      home: LoginOrRegister(), // Initial screen for user authentication
    );
  }
}
