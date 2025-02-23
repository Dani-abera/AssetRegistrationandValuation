// ignore_for_file: use_build_context_synchronously

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

import 'package:get_it/get_it.dart';
import 'package:land_house_verify/components/my_textFormField.dart';
import 'package:land_house_verify/pages/admin/admin_page.dart';
import 'package:land_house_verify/services/add_room_service.dart';
import 'package:land_house_verify/services/asset_register_service.dart';
import 'package:land_house_verify/services/cloudinary_file_upload_servise.dart';

class AddRoomsPage extends StatefulWidget {
  final String assetId;
  final String id;
  const AddRoomsPage({super.key, required this.assetId, required this.id});

  @override
  State<AddRoomsPage> createState() => _AddRoomsPageState();
}

class _AddRoomsPageState extends State<AddRoomsPage> {
  final _formKey = GlobalKey<FormState>();
  final addRoom = GetIt.instance<AssetRegisterService>();
  final room = AddRoomService();
  bool _isLoading = false;

  // Form controllers
  final _roomIdController = TextEditingController();
  final _roomAreaController = TextEditingController();
  final _roomDescriptionController = TextEditingController();


  List<File> roomCurrentPhoto = [];
  PlatformFile? pickedImage;
  XFile? image;
  List<String> uploadedUrls = [];
  String? uploadedDocumentUrl;
  String assetId = '';

  /// Pick a document from the device using File Picker

  Future<void> _addRoom() async {
    if (!_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please complete all fields')),
      );
      return;
    }

    setState(() => _isLoading = true);
    uploadedUrls = await CloudinaryFileUploadService().uploadMultipleImagesToCloudinary(roomCurrentPhoto);

    try {
      final result = await room.addRoom(
        roomId: "${widget.id}/${_roomIdController.text}",
        area: _roomAreaController.text,
        description: _roomDescriptionController.text,
        roomCurrentPhoto: uploadedUrls,
        evaluator: "Not Assigned",
        roomEvaluationStatus: "In Progress",
      );

      if (result != null) {
        final saveRoomResult = await room.saveRoomToAsset(assetId: widget.assetId, room: result);
        if (saveRoomResult == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Room registered successfully!')),
          );
          Navigator.pop(context);
        } else {
          throw Exception(saveRoomResult);
        }
      } else {
        throw Exception('Failed to create room');
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
            roomCurrentPhoto.add(File(imagePath));
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
      appBar: AppBar(title: const Text('Add Single Building Room')),
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
                    label: 'Room Id',
                    controller: _roomIdController,
                  ),
                  MyTextformfield(
                      label: 'Area (m2)', controller: _roomAreaController),
                  MyTextformfield(
                    label: 'Room status description',
                    controller: _roomDescriptionController,
                    length: 3,
                  ),
                  const SizedBox(height: 20),
                  _isLoading
                      ? const CircularProgressIndicator()
                      : SizedBox(
                      height: 40,
                      width: double.infinity,
                      child: ElevatedButton(
                      onPressed: _addRoom,
                      child: const Text('Add Room'),
                    ),
                  )
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
        const Text('Building Room Current Photo', style: TextStyle(fontSize: 16.0)),
        const SizedBox(height: 8.0),
        Stack(
          children: [
            Container(
              height: 100,
              width: double.infinity,
              decoration: BoxDecoration(border: Border.all(), borderRadius: BorderRadius.circular(8.0)),
              child:ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: roomCurrentPhoto.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.only(right: 10.0),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8.0),
                      child: Image.file(
                        roomCurrentPhoto[index],
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