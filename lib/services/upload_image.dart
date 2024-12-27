import 'dart:convert';
import 'dart:io';

// ignore: depend_on_referenced_packages
import 'package:http/http.dart' as http;

final cloudinaryUrl = 'https://api.cloudinary.com/v1_1/dyzeb4vxu/image/upload';
final preset = 'Asset-Registry';

Future<List<String>> uploadMultipleImagesToCloudinary(List<File> images) async {

  List<String> uploadedUrls = [];

  try {
    // Use Future.wait to upload all images concurrently
    final uploadTasks = images.map<Future<String>>((image) async {
      final request = http.MultipartRequest('POST', Uri.parse(cloudinaryUrl))
        ..fields['upload_preset'] = preset
        ..files.add(await http.MultipartFile.fromPath('file', image.path));

      final response = await request.send();
      if (response.statusCode == 200) {
        final responseBody = await response.stream.bytesToString();
        final data = jsonDecode(responseBody);
        return data['secure_url']; // Extract the secure URL
      } else {
        throw Exception('Failed to upload image: ${response.statusCode}');
      }
    });

    // Wait for all uploads to complete
    uploadedUrls = await Future.wait(uploadTasks);
  } catch (e) {
    print('Error uploading images: $e');
  }

  return uploadedUrls; // Return the list of uploaded image URLs
}

Future<String?> uploadDocumentToCloudinary(String filePath) async {
  final cloudinaryUrl = 'https://api.cloudinary.com/v1_1/dyzeb4vxu/auto/upload';

  try {
    final file = File(filePath);
    final fileName = file.path.split('/').last;

    // Create the request
    final request = http.MultipartRequest('POST', Uri.parse(cloudinaryUrl))
      ..fields['upload_preset'] = preset
      ..files.add(await http.MultipartFile.fromPath('file', file.path, filename: fileName));

    // Send the request
    final response = await request.send();

    if (response.statusCode == 200) {
      final responseData = await http.Response.fromStream(response);
      final data = responseData.body;
      print('Document uploaded successfully: $data');

      // Parse and return the URL from Cloudinary's response
      final url = data.contains('url') ? data.split('"url":"')[1].split('"')[0] : null;
      return url;
    } else {
      print('Failed to upload document: ${response.reasonPhrase}');
      return null;
    }
  } catch (e) {
    print('Error uploading document to Cloudinary: $e');
    return null;
  }
}
