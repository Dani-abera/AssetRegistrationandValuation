import 'package:flutter/material.dart';

import '../../components/my_button.dart';
import '../../components/my_textfield.dart';
import '../../services/auth_service.dart';

class RegisterPage extends StatefulWidget {
  final Function()? onTap;
  const RegisterPage({super.key, required this.onTap});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final AuthService _authService =
      AuthService(); // Instance of AuthService for authentication logic

  // Controllers for capturing input from text fields
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  String _selectedRole = 'validator'; // Default selected role for dropdown
  bool _isLoading = false; // To show loading spinner during signup
  bool isPasswordHidden = true;

  // Signup function to handle user registration
  void _signup() async {
    setState(() {
      _isLoading = true; // Show loading spinner
    });

    // Call signup method from AuthService with user inputs
    String? result = await _authService.signup(
      name: _nameController.text,
      email: _emailController.text,
      password: _passwordController.text,
      role: _selectedRole,
    );

    setState(() {
      _isLoading = false; // Hide loading spinner
    });

    if (result == null) {
      // Signup successful: Navigate to LoginScreen with success message
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Signup Successful! Now Turn to Login'),
      ));
    } else {
      // Signup failed: Show error message
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Signup Failed: $result'),
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: Icon(Icons.arrow_back)),
      ),
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "Let's Create Account",
                style: TextStyle(
                    fontSize: 16,
                    color: Theme.of(context).colorScheme.inversePrimary),
              ),
              SizedBox(
                height: 25,
              ),
              MyTextField(
                controller: _nameController,
                hintText: "Name",
                obscureText: false,
              ),
              SizedBox(
                height: 25,
              ),
              MyTextField(
                controller: _emailController,
                hintText: "Email",
                obscureText: false,
              ),
              SizedBox(
                height: 25,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 25.0),
                child: TextField(
                  controller: _passwordController,
                  obscureText: isPasswordHidden,
                  decoration: InputDecoration(
                    suffixIcon: IconButton(
                      onPressed: () {
                        setState(() {
                          isPasswordHidden = !isPasswordHidden;
                        });
                      },
                      icon: Icon(
                        isPasswordHidden
                            ? Icons.visibility_off
                            : Icons.visibility,
                      ),
                    ),
                    hintText: 'Password',
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                          color: Theme.of(context).colorScheme.tertiary),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                          color: Theme.of(context).colorScheme.primary),
                    ),
                  ),
                ),
              ),
              SizedBox(
                height: 25,
              ),
              // Dropdown for selecting role
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 25.0),
                child: DropdownButtonFormField<String>(
                  value: _selectedRole,
                  decoration: InputDecoration(
                    labelText: 'Role',
                    border: OutlineInputBorder(
                        borderSide: BorderSide(
                            color: Theme.of(context).colorScheme.tertiary)),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                          color: Theme.of(context).colorScheme.primary),
                    ),
                  ),
                  onChanged: (String? newValue) {
                    setState(() {
                      _selectedRole = newValue!; // Update role selection
                    });
                  },
                  items: ['Admin', 'validator'].map((role) {
                    return DropdownMenuItem(
                      value: role,
                      child: Text(role),
                    );
                  }).toList(),
                ),
              ),
              SizedBox(
                height: 25,
              ),
              _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : SizedBox(
                      width: double.infinity, // Button stretches across width
                      child: MyButton(
                        onTap: _signup, // Call signup function
                        text: 'Signup',
                      ),
                    ),
              SizedBox(
                height: 25,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
