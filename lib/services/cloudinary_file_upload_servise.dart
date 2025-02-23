import 'dart:convert';
import 'dart:io';
// ignore: depend_on_referenced_packages
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/widgets.dart';
// ignore: depend_on_referenced_packages
import 'package:http/http.dart' as http;
import 'package:toastification/toastification.dart';

class  CloudinaryFileUploadService {
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

// Future<String?> uploadDocumentToCloudinary(String filePath) async {
//  const cloudinaryUrl = 'https://api.cloudinary.com/v1_1/dyzeb4vxu/raw/upload';

//   try {
//     final file = File(filePath);
//     final fileExtension = file.path.split('.').last;
//     final fileName = '${DateTime.now().millisecondsSinceEpoch}.$fileExtension';

//     final request = http.MultipartRequest('POST', Uri.parse(cloudinaryUrl))
//     ..fields['upload_preset'] = preset
//     ..files.add(await http.MultipartFile.fromPath('file', file.path, filename: fileName));

//     final response = await request.send();

//     if (response.statusCode == 200) {
//       final responseData = await http.Response.fromStream(response);
//       final jsonResponse = jsonDecode(responseData.body);

//       if (jsonResponse['secure_url'] != null) {
//         final uploadedUrl = jsonResponse['secure_url'];
//         toastification.show(
//           title: Text("Success"),
//           type: ToastificationType.success,
//           description: Text('Document uploaded successfully!'),
//         );
//         return uploadedUrl;
//       } else {
//         toastification.show(
//           title: Text("Warning"),
//           type: ToastificationType.warning,
//           description: Text('Upload successful, but no URL found in response.'),
//         );
//         return null;
//       }
//     } else {
//       final responseData = await http.Response.fromStream(response);
//       final errorMessage = responseData.body;
//       toastification.show(
//         title: Text("Error"),
//         type: ToastificationType.error,
//         description: Text("Failed to upload document: $errorMessage"),
//       );
//       return null;
//     }
//   } catch (e) {
//     toastification.show(
//       title: Text("Error"),
//       type: ToastificationType.error,
//       description: Text('Error uploading document to Cloudinary: $e'),
//     );
//     return null;
//   }
// }
Future<String?> uploadDocumentToCloudinary(String filePath) async {
  const cloudinaryUrl = 'https://api.cloudinary.com/v1_1/dyzeb4vxu/auto/upload';

  try {
    final file = File(filePath);
    final request = http.MultipartRequest('POST', Uri.parse(cloudinaryUrl))
      ..fields['upload_preset'] = preset
      ..files.add(await http.MultipartFile.fromPath('file', file.path));

    final response = await request.send();
    if (response.statusCode == 200) {
      final responseData = await http.Response.fromStream(response);
      final jsonResponse = jsonDecode(responseData.body);
      return jsonResponse['secure_url'];
    } else {
      final errorResponse = await http.Response.fromStream(response);
      print('Error: ${errorResponse.body}');
      return null;
    }
  } catch (e) {
    print('Exception: $e');
    return null;
  }
}

Future<String?> uploadFileToFirebase(String filePath, String destination) async {
  try {
    final file = File(filePath);
    final ref = FirebaseStorage.instance.ref(destination);
    final uploadTask = ref.putFile(file);
    final snapshot = await uploadTask.whenComplete(() => null);
    return await snapshot.ref.getDownloadURL();
    
  } catch (e) {
    toastification.show(
            title: Text("Error"),
            type: ToastificationType.error,
            description: Text("Error uploading to Firebase Storage: $e"),
          );
    return null;
  }
}


}