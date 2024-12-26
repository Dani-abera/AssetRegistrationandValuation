import 'package:flutter/material.dart';
import 'package:land_house_verify/components/my_textFormField.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

import 'package:get_it/get_it.dart';

import '../services/asset_register_service.dart';

class RegisterAssetPage extends StatefulWidget {
  const RegisterAssetPage({super.key});

  @override
  State<RegisterAssetPage> createState() => _RegisterAssetPageState();
}

class _RegisterAssetPageState extends State<RegisterAssetPage> {
  final _formKey = GlobalKey<FormState>();
  final assetRegister =
      GetIt.instance<AssetRegisterService>(); // Use get_it to locate service
  String? _documentFile;
  bool _isLoading = false;

  // Form controllers
  final _assetNameController = TextEditingController();
  final _ownershipController = TextEditingController();
  final _areaController = TextEditingController();
  final _locationController = TextEditingController();
  final _titleDeedController = TextEditingController();
  final _descriptionController = TextEditingController();

  String _selectedAssetType = 'Land';

  Future<void> pickDocument() async {
    final directory = await getExternalStorageDirectory();
    final file = File('${directory!.path}/asset_doc.pdf');

    setState(() {
      _documentFile = file.path;
    });
  }

  Future<void> _submitAsset() async {
    if (!_formKey.currentState!.validate() || _documentFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Please complete all fields and upload a document')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final result = await assetRegister.registerAsset(
        assetName: _assetNameController.text,
        ownership: _ownershipController.text,
        area: _areaController.text,
        location: _locationController.text,
        titleDeedNumber: _titleDeedController.text,
        assetType: _selectedAssetType,
        description: _descriptionController.text,
        documentFile: _documentFile!,
      );

      if (result == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Asset registered successfully!')),
        );
        Navigator.pop(context);
      } else {
        throw Exception(result);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    } finally {
      setState(() => _isLoading = false);
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
                  MyTextformfield(
                    label: 'Name of Asset',
                    controller: _assetNameController,
                  ),
                  MyTextformfield(
                      label: 'Ownership', controller: _ownershipController),
                  MyTextformfield(
                      label: 'Area (m2)', controller: _areaController),
                  MyTextformfield(
                      label: 'Location', controller: _locationController),
                  MyTextformfield(
                      label: 'Title Deed Number',
                      controller: _titleDeedController),
                  MyTextformfield(
                      label: 'Asset Description',
                      controller: _descriptionController),
                  const SizedBox(height: 20),
                  DropdownButtonFormField(
                    value: _selectedAssetType,
                    decoration: const InputDecoration(labelText: 'Asset Type'),
                    items: ['Land', 'House']
                        .map((type) =>
                            DropdownMenuItem(value: type, child: Text(type)))
                        .toList(),
                    onChanged: (value) =>
                        setState(() => _selectedAssetType = value!),
                  ),
                  const SizedBox(height: 20),
                  ListTile(
                    title: Text(_documentFile != null
                        ? 'Document Selected: $_documentFile'
                        : 'Upload Document'),
                    trailing: const Icon(Icons.upload_file),
                    onTap: pickDocument,
                  ),
                  const SizedBox(height: 30),
                  _isLoading
                      ? const CircularProgressIndicator()
                      : ElevatedButton(
                          onPressed: _submitAsset,
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
}
