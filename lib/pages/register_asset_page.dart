import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';

class RegisterAssetPage extends StatefulWidget {
  const RegisterAssetPage({super.key});

  @override
  State<RegisterAssetPage> createState() => _RegisterAssetPageState();
}

class _RegisterAssetPageState extends State<RegisterAssetPage> {
  final _formKey = GlobalKey<FormState>();
  String assetId = '';
  String assetName = '';
  String ownership = '';
  String area = '';
  String location = '';
  String titleDeedNumber = '';
  String assetType = 'Land';
  String description = '';
  File? documentFile;

  Future<void> pickDocument() async {
    final directory = await getExternalStorageDirectory();
    final file = File('${directory!.path}/asset_doc.pdf');

    setState(() {
      documentFile = file;
    });
  }

  Future<void> submitAsset() async {
    if (_formKey.currentState!.validate() && documentFile != null) {
      _formKey.currentState!.save();

      final assetData = {
        'assetId': assetId,
        'assetName': assetName,
        'ownership': ownership,
        'area': area,
        'location': location,
        'titleDeedNumber': titleDeedNumber,
        'assetType': assetType,
        'description': description,
        'documentPath': documentFile!.path,
        'createdAt': FieldValue.serverTimestamp(),
      };

      await FirebaseFirestore.instance.collection('assets').add(assetData);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Asset registered successfully!')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Please complete all fields and upload a document.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Register Asset')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                children: [
                  _buildTextField('Asset ID', (value) => assetId = value!),
                  _buildTextField(
                      'Name of Asset', (value) => assetName = value!),
                  _buildTextField('Ownership', (value) => ownership = value!),
                  _buildTextField('Area (m2)', (value) => area = value!),
                  _buildTextField('Location', (value) => location = value!),
                  _buildTextField(
                      'Title Deed Number', (value) => titleDeedNumber = value!),
                  _buildTextField(
                      'Asset Description', (value) => description = value!),
                  const SizedBox(height: 20),
                  DropdownButtonFormField(
                    value: assetType,
                    decoration: const InputDecoration(labelText: 'Asset Type'),
                    items: ['Land', 'House']
                        .map((type) =>
                            DropdownMenuItem(value: type, child: Text(type)))
                        .toList(),
                    onChanged: (value) => setState(() => assetType = value!),
                  ),
                  const SizedBox(height: 20),
                  ListTile(
                    title: Text(documentFile != null
                        ? 'Document Selected: ${documentFile!.path} '
                        : 'Upload Document'),
                    trailing: const Icon(Icons.upload_file),
                    onTap: pickDocument,
                  ),
                  const SizedBox(height: 30),
                  ElevatedButton(
                    onPressed: submitAsset,
                    child: const Text('Submit'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(String label, FormFieldSetter<String> onSave) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: TextFormField(
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
        validator: (value) => value!.isEmpty ? 'Enter $label' : null,
        onSaved: onSave,
      ),
    );
  }
}
