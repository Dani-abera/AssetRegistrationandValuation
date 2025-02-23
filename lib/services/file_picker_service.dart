import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';

class FilePickerService {
    /// Pick a document from the device using File Picker
    
  Future<String> pickDocument() async {
     String? documentFile;
      try {
        final result = await FilePicker.platform.pickFiles(
          type: FileType.custom,
          allowedExtensions: ['pdf', 'doc', 'docx'], // Customize allowed file types
        );

        if (result != null) {
          documentFile = result.files.single.path;
        }
        return documentFile ?? '';
      } catch (e) {
        if (kDebugMode) {
          print('Error picking document: $e');
        }
        return '';
      }
    }
}