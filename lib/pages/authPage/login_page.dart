// ignore_for_file: use_build_context_synchronously

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:land_house_verify/pages/asset-owner/asset_owner_page.dart';
import 'package:land_house_verify/pages/validator/validator_page.dart';
import '../../components/my_button.dart';
import '../../components/my_textfield.dart';
import '../../services/auth_service.dart';
import '../admin/admin_page.dart';

class LoginPage extends StatefulWidget {
  final Function()? onTap;
  const LoginPage({super.key, required this.onTap});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final AuthService _authService = AuthService(); // Instance of AuthService
  final _emailController =
      TextEditingController(); // Controller for email input
  final _passwordController =
      TextEditingController(); // Controller for password input
  bool _isLoading = false; // To show spinner during login

  // Function to fetch the id of the user (both Admin and Validator)
  Future<String> _fetchUserId() async {
    try {
      // Assuming the email is used as the document ID or a unique field in the 'users' collection
      QuerySnapshot userSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('email', isEqualTo: _emailController.text)
          .get();

      if (userSnapshot.docs.isNotEmpty) {
        // Fetch the 'id' field for both Admin and Validator
        return userSnapshot.docs.first['name'] ?? 'Unknown';
      } else {
        return 'Unknown'; // Return a default value if not found
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching user id: $e');
      }
      return 'Unknown'; // Return default value in case of error
    }
  }

  // Login function to handle user authentication
  void _login() async {
    setState(() {
      _isLoading = true; // Show spinner
    });

    // Call login method from AuthService with user inputs
    String? result = await _authService.login(
      email: _emailController.text,
      password: _passwordController.text,
    );

    setState(() {
      _isLoading = false; // Hide spinner
    });

    // Navigate based on role or show error message
    if (result == 'Admin') {
      String adminId = await _fetchUserId(); // Fetch admin's id
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => AdminPage(
            name: adminId,
          ), // Pass id to AdminPage
        ),
      );
    } else if (result == 'validator') {
      String validatorId = await _fetchUserId(); // Fetch validator's id
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) =>
              ValidatorPage(name: validatorId), // Pass id to ValidatorPage
        ),
      );
    } else if (result == 'Assetowner') {
      String assetOwnerId = await _fetchUserId(); // Fetch assetOwner's id
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => AssetOwnerPage(isEqualTo: assetOwnerId, condition: 'ownership',), // Pass id to ValidatorPage
        ),
      );
    }
    
    else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Login Failed: $result'), // Show error message
      ));
    }
  }

  bool isPasswordHidden = true;

  @override
  Widget build(BuildContext context) {
    // ignore: deprecated_member_use
    return WillPopScope(
      onWillPop: () async => false, // Prevent back button action
      child: Scaffold(
        backgroundColor: Theme.of(context).colorScheme.surface,
        body: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.lock_outline_rounded,
              size: 100,
              color: Theme.of(context).colorScheme.inversePrimary,
            ),
            SizedBox(height: 25),
            Text(
              "Land and House Registration and Validation System",
              style: TextStyle(
                fontSize: 16,
                color: Theme.of(context).colorScheme.inversePrimary,
              ),
            ),
            SizedBox(height: 25),
            MyTextField(
              controller: _emailController,
              hintText: "Email",
            ),
            SizedBox(height: 25),
            MyTextField(
              controller: _passwordController,
              hintText: "Password",
              obscureText: isPasswordHidden,
              suffixIcon: IconButton(
                onPressed: () {
                  setState(() {
                    isPasswordHidden = !isPasswordHidden;
                  });
                },
                icon: Icon(
                  isPasswordHidden ? Icons.visibility_off : Icons.visibility,
                ),
              ),
            ),
            SizedBox(height: 25),
            SizedBox(height: 25),
            _isLoading
                ? const CircularProgressIndicator()
                : SizedBox(
                    width: double.infinity,
                    child: MyButton(onTap: _login, text: "Login"),
                  ),
            SizedBox(height: 25),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'not a member?',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.inversePrimary,
                  ),
                ),
                SizedBox(width: 4),
                GestureDetector(
                  onTap: widget.onTap,
                  child: Text(
                    'Register as Validator',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.inversePrimary,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
