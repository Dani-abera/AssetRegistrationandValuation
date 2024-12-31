// ignore_for_file: use_build_context_synchronously

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

import 'package:get_it/get_it.dart';
import 'package:land_house_verify/components/my_textFormField.dart';
import 'package:land_house_verify/pages/admin/admin_page.dart';
import 'package:land_house_verify/services/asset_register_service.dart';
import 'package:land_house_verify/services/cloudinary_file_upload_servise.dart';

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
    final _assetIdController = TextEditingController();
  final _assetNameController = TextEditingController();
  final _ownershipController = TextEditingController();
  final _areaController = TextEditingController();
  final _locationController = TextEditingController();
  final _titleDeedController = TextEditingController();
  final _descriptionController = TextEditingController();

  String _selectedAssetType = 'Land';
   List<File> assetThumbnails = [];
   PlatformFile? pickedImage;
    XFile? image;
    List<String> uploadedUrls = [];
    String? uploadedDocumentUrl;

  /// Pick a document from the device using File Picker
  Future<void> pickDocument() async {
      try {
        final result = await FilePicker.platform.pickFiles(
          type: FileType.custom,
          allowedExtensions: ['pdf', 'doc', 'docx'], // Customize allowed file types
        );

        if (result != null) {
          _documentFile = result.files.single.path;
        }
      } catch (e) {
        if (kDebugMode) {
          print('Error picking document: $e');
        }
      }
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
          uploadedUrls = await CloudinaryFileUploadService().uploadMultipleImagesToCloudinary(assetThumbnails);
          if (kDebugMode) {
            print('Thumbnail selected: $uploadedUrls');
          }
          uploadedDocumentUrl = await CloudinaryFileUploadService().uploadDocumentToCloudinary(_documentFile!);
          if (kDebugMode) {
            print('Document selected: $uploadedDocumentUrl');
          }


    try {
      final result = await assetRegister.registerAsset(
        assetId: _assetIdController.text,
        assetName: _assetNameController.text,
        ownership: _ownershipController.text,
        area: _areaController.text,
        location: _locationController.text,
        titleDeedNumber: _titleDeedController.text,
        assetType: _selectedAssetType,
        description: _descriptionController.text,
        documentFile: uploadedDocumentUrl!,
        assetThumbnails: uploadedUrls,
        valuator: "Not Assigned",
        status: "In Progress"
      );

      if (result == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Asset registered successfully!')),
        );
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => AdminPage(name: "name")));
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
  // Image picker for thumbnails
  Future<void> _pickThumbnail() async {
     try {
    // Open the file picker to select image files
    final image = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['jpg', 'jpeg', 'png'], // Restrict to image formats
    );

    if (image != null) {
      final String? imagePath = image.files.single.path;
      if (imagePath != null) {
        setState(() {
          assetThumbnails.add(File(imagePath));
        });
            // Use the selected image path for your app's functionality
          } else {
            if (kDebugMode) {
              print('No file selected');
            }
          }
        } else {
          if (kDebugMode) {
            print('User canceled the picker');
          }
        }
      } catch (e) {
        if (kDebugMode) {
          print('Error picking image: $e');
        }
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
                  _buildThumbnailsSection(),
              const SizedBox(height: 16.0),
                MyTextformfield(
                    label: 'Asset Id',
                    controller: _assetIdController,
                  ),
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
                      controller: _descriptionController,
                      length: 3,
                      ),
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
  // Thumbnails Section
  Widget _buildThumbnailsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Asset Current Photo', style: TextStyle(fontSize: 16.0)),
        const SizedBox(height: 8.0),
        Stack(
          children: [
            Container(
              height: 100,
              width: double.infinity,
              decoration: BoxDecoration(border: Border.all(), borderRadius: BorderRadius.circular(8.0)),
              child:ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: assetThumbnails.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.only(right: 10.0),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8.0),
                      child: Image.file(
                        assetThumbnails[index],
                        width: 100,
                        height: 100,
                        fit: BoxFit.cover,
                      ),
                    ),
                  );
                },
              ),
            ),
            Positioned(
              bottom: 5, 
              right: 5,
              child: GestureDetector(
                onTap: _pickThumbnail,
                child: CircleAvatar(
                  
                  child: Icon(Icons.upload),
                ),
              )
            ),
          ],
        ),
      
      ],
    );
  }
}