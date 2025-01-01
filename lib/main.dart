import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:land_house_verify/service_locator.dart';
import 'package:land_house_verify/services/login_or_register.dart';
import 'package:land_house_verify/themes/themes_provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:toastification/toastification.dart';
import 'firebase_options.dart';

void main() async {
  // Initialize Flutter Binding
  WidgetsFlutterBinding.ensureInitialized();
  // Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  // Setup service locator
  setupLocator();

  // Run the app with ProviderScope
  runApp(
    ProviderScope(
      child: const MyApp(),
    ),
  );
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeData = ref.watch(themeProvider); // Watch the theme provider

    return ToastificationWrapper(
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Property Registration and Verification System',
        theme: themeData, // Use the theme from Riverpod
        home: LoginOrRegister(), // Initial screen for user authentication
      ),
    );
  }
}
