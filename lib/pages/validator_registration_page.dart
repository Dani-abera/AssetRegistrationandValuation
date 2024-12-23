import 'package:flutter/material.dart';
import 'package:land_house_verify/components/my_button.dart';
import 'package:land_house_verify/components/my_textfield.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';

import 'approval_page.dart';

class RegisterValidatorPage extends StatefulWidget {
  final Function()? onTap;
  const RegisterValidatorPage({super.key, this.onTap});

  @override
  State<RegisterValidatorPage> createState() => _RegisterValidatorPageState();
}

class _RegisterValidatorPageState extends State<RegisterValidatorPage> {
  final _formKey = GlobalKey<FormState>();
  String validatorType = 'Individual';
  String name = '';
  String email = '';
  String phoneNumber = '';
  String role = '';
  File? cvFile;
  File? certificationFile;

  Future<void> pickFile(bool isCV) async {
    // External storage file picker logic
    final directory = await getExternalStorageDirectory();
    final file = File('${directory!.path}/example.pdf');

    setState(() {
      if (isCV) {
        cvFile = file;
      } else {
        certificationFile = file;
      }
    });
  }

  Future<void> submitForm() async {
    if (_formKey.currentState!.validate() &&
        cvFile != null &&
        certificationFile != null) {
      _formKey.currentState!.save();

      // Save validator data to Firestore
      final validatorData = {
        'validatorType': validatorType,
        'name': name,
        'email': email,
        'phoneNumber': phoneNumber,
        'role': 'Validator',
        'cvPath': cvFile!.path,
        'certificationPath': certificationFile!.path,
        'status': 'pending', // Admin must approve
        'createdAt': FieldValue.serverTimestamp(),
      };

      await FirebaseFirestore.instance
          .collection('pending_validators')
          .add(validatorData);

      // Simulate notification to admin (can be expanded with push notifications)
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Registration sent to admin for approval.')));
    } else {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Please complete the form.')));
    }
  }

  void navigateToUserDetailScreen() {
    // Navigate to UserDetailScreen and pass the email
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => UserDetailScreen(email: email),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.app_registration_rounded,
                size: 100,
                color: Theme.of(context).colorScheme.inversePrimary,
              ),
              SizedBox(
                height: 25,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 25.0),
                child: DropdownButtonFormField(
                  value: validatorType,
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
                  onChanged: (value) => setState(() => validatorType = value!),
                  items: ['Individual', 'Organization']
                      .map((type) =>
                          DropdownMenuItem(value: type, child: Text(type)))
                      .toList(),
                ),
              ),
              SizedBox(
                height: 25,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 25.0),
                child: TextFormField(
                  obscureText:
                      false, // If you want to obscure the text (e.g., for passwords)
                  decoration: InputDecoration(
                    hintText:
                        'Name / Organization Name', // Use the appropriate hint text
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: Theme.of(context).colorScheme.tertiary,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  ),
                  onSaved: (value) {
                    // Handle saving the value here
                    name = value!;
                  },
                ),
              ),
              SizedBox(
                height: 25,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 25.0),
                child: TextFormField(
                  obscureText:
                      false, // If you want to obscure the text (e.g., for passwords)
                  decoration: InputDecoration(
                    hintText: 'Email', // Use the appropriate hint text
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: Theme.of(context).colorScheme.tertiary,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  ),
                  onSaved: (value) {
                    // Handle saving the value here
                    email = value!;
                  },
                ),
              ),
              SizedBox(
                height: 25,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 25.0),
                child: TextFormField(
                  obscureText:
                      false, // If you want to obscure the text (e.g., for passwords)
                  decoration: InputDecoration(
                    hintText: 'Phone Number', // Use the appropriate hint text
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: Theme.of(context).colorScheme.tertiary,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  ),
                  onSaved: (value) {
                    // Handle saving the value here
                    phoneNumber = value!;
                  },
                ),
              ),
              SizedBox(
                height: 25,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 25.0),
                child: ListTile(
                  title: Text('Upload CV'),
                  trailing: Icon(Icons.upload_file),
                  onTap: () => pickFile(true),
                ),
              ),
              SizedBox(
                height: 25,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 25.0),
                child: ListTile(
                  title: Text('Upload Certification'),
                  trailing: Icon(Icons.upload_file),
                  onTap: () => pickFile(false),
                ),
              ),
              SizedBox(
                height: 25,
              ),
              //MyButton(onTap: submitForm, text: 'Submit'),
              GestureDetector(
                onTap: () {
                  navigateToUserDetailScreen();
                  submitForm();
                },
                child: Container(
                  padding: EdgeInsets.all(25),
                  margin: EdgeInsets.symmetric(horizontal: 25),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.secondary,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(
                    child: Text(
                      'Submit',
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: Theme.of(context).colorScheme.inversePrimary),
                    ),
                  ),
                ),
              ),
              SizedBox(
                height: 25,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'already Registered',
                    style: TextStyle(
                        color: Theme.of(context).colorScheme.inversePrimary),
                  ),
                  SizedBox(
                    width: 4,
                  ),
                  GestureDetector(
                    onTap: widget.onTap,
                    child: Text(
                      'Login now',
                      style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          letterSpacing: -1,
                          color: Theme.of(context).colorScheme.inversePrimary),
                    ),
                  )
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
