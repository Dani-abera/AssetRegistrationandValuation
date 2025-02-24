import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:land_house_verify/components/my_button.dart';
import 'package:path/path.dart' as path_lib;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:toastification/toastification.dart';

class RegisterValidatorPage extends StatefulWidget {
  final VoidCallback? onTap;
  const RegisterValidatorPage({super.key, this.onTap});

  @override
  State<RegisterValidatorPage> createState() => _RegisterValidatorPageState();
}

class _RegisterValidatorPageState extends State<RegisterValidatorPage> {
  final _formKey = GlobalKey<FormState>();

  // Form Fields
  String _validatorType = 'Individual';
  String _name = '';
  String _email = '';
  String _phoneNumber = '';
  String? _cvFilePath;
  String? _certificationFilePath;
  bool _isLoading = false;

  /// Pick a document (CV or Certification)
  Future<void> _pickDocument({required Function(String) onFilePicked}) async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'doc', 'docx'],
      );

      if (result != null && result.files.single.path != null) {
        onFilePicked(result.files.single.path!);
      }
    } catch (e) {
      toastification.show(
        autoCloseDuration: Duration(milliseconds: 2000),
        type: ToastificationType.error,
        description: Text('Error picking document.'),
      );
    }
  }

  /// Submit the form
  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate() ||
        _cvFilePath == null ||
        _certificationFilePath == null) {
      toastification.show(
        autoCloseDuration: Duration(milliseconds: 2000),
        type: ToastificationType.error,
        description: Text('Please complete all required fields.'),
      );
      return;
    }

    _formKey.currentState!.save();

    setState(() => _isLoading = true);

    final validatorData = {
      'validatorType': _validatorType,
      'name': _name,
      'email': _email,
      'phoneNumber': _phoneNumber,
      'cvPath': _cvFilePath,
      'certificationPath': _certificationFilePath,
      'status': 'pending', // Requires admin approval
      'createdAt': FieldValue.serverTimestamp(),
    };

    try {
      await FirebaseFirestore.instance
          .collection('pending_validators')
          .add(validatorData);
      toastification.show(
        autoCloseDuration: Duration(milliseconds: 2000),
        type: ToastificationType.success,
        description: Text('Registration sent to admin for approval.'),
      );

      // Clear the form
      setState(() {
        _isLoading = false;
        _cvFilePath = null;
        _certificationFilePath = null;
      });
    } catch (e) {
      toastification.show(
        autoCloseDuration: Duration(milliseconds: 2000),
        type: ToastificationType.error,
        description: Text('Error submitting registration.'),
      );
      setState(() => _isLoading = false);
    }
  }

  /// Reusable TextFormField Widget
  Widget _buildTextField({
    required String hintText,
    required FormFieldSetter<String> onSaved,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      decoration: InputDecoration(
        hintText: hintText,
        border: const OutlineInputBorder(),
      ),
      validator: validator,
      onSaved: onSaved,
    );
  }

  /// Reusable File Picker Tile
  Widget _buildFilePickerTile({
    required String title,
    required String? filePath,
    required VoidCallback onPick,
  }) {
    return ListTile(
      title: Text(filePath != null ? path_lib.basename(filePath) : title),
      trailing: const Icon(Icons.upload_file),
      onTap: onPick,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Icon(
                    Icons.app_registration_rounded,
                    size: 100,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                const SizedBox(height: 25),
                DropdownButtonFormField<String>(
                  value: _validatorType,
                  decoration: const InputDecoration(
                    labelText: 'Validator Type',
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (value) => setState(() => _validatorType = value!),
                  items: ['Individual', 'Organization']
                      .map((type) =>
                          DropdownMenuItem(value: type, child: Text(type)))
                      .toList(),
                ),
                const SizedBox(height: 20),
                _buildTextField(
                  hintText: 'Name / Organization Name',
                  onSaved: (value) => _name = value!,
                  validator: (value) =>
                      value!.isEmpty ? 'Name is required' : null,
                ),
                const SizedBox(height: 20),
                _buildTextField(
                  hintText: 'Email',
                  onSaved: (value) => _email = value!,
                  validator: (value) =>
                      value!.isEmpty ? 'Email is required' : null,
                ),
                const SizedBox(height: 20),
                _buildTextField(
                  hintText: 'Phone Number',
                  onSaved: (value) => _phoneNumber = value!,
                  validator: (value) =>
                      value!.isEmpty ? 'Phone number is required' : null,
                ),
                const SizedBox(height: 20),
                _buildFilePickerTile(
                  title: 'Upload CV',
                  filePath: _cvFilePath,
                  onPick: () => _pickDocument(onFilePicked: (filePath) {
                    setState(() => _cvFilePath = filePath);
                  }),
                ),
                const SizedBox(height: 20),
                _buildFilePickerTile(
                  title: 'Upload Certification',
                  filePath: _certificationFilePath,
                  onPick: () => _pickDocument(onFilePicked: (filePath) {
                    setState(() => _certificationFilePath = filePath);
                  }),
                ),
                const SizedBox(height: 30),
                Center(
                    child: _isLoading
                        ? const CircularProgressIndicator()
                        : MyButton(onTap: _submitForm, text: 'Submit')),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('Already Registered?'),
                    TextButton(
                      onPressed: widget.onTap,
                      child: const Text('Login now'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
