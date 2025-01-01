import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:land_house_verify/components/custom_toast_info.dart';
import 'package:land_house_verify/services/cloudinary_file_upload_servise.dart';
import 'package:land_house_verify/services/file_picker_service.dart';
import 'labeled_row.dart';
import 'package:path/path.dart' as path;

class MessageCard extends StatelessWidget {
  final String from;
  final String assetName;
  final String message;
  final String notificationId;

  const MessageCard({
    super.key,
    required this.from,
    required this.assetName,
    required this.message, required this.notificationId,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color.fromARGB(179, 231, 228, 228),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            LabeledRow(label: "From", value: from),
            const SizedBox(height: 5),
            LabeledRow(label: "AssetName", value: assetName),
            const SizedBox(height: 5),
            LabeledRow(label: "Message", value: message),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children:[
              TextButton(
              onPressed: () async {
                await handleFileUpload();
              },
              child: const Text(
                "Send Valuation Report",
                style: TextStyle(color: Colors.blue),
              ),
            ),
            const SizedBox(height: 10),
            TextButton(
              onPressed: () async {
                await deleteNotification();
              },
              child: const Text(
                "Delete Notification",
                style: TextStyle(color: Colors.red),
              ),
            ),])
          ],
        ),
      ),
    );
  }

  Future<void> handleFileUpload() async {
    try {
      String valuationReport = await FilePickerService().pickDocument();
       String? uploadedDocumentUrl = await CloudinaryFileUploadService()
            .uploadDocumentToCloudinary(valuationReport);
            print(uploadedDocumentUrl);
      if(uploadedDocumentUrl != null){
      try{
          await FirebaseFirestore.instance.collection("valuation-report").add({
          'reportUrl': uploadedDocumentUrl,
          'to': from,
          'msg': 'Jemo michael valuation report document',
          'createdAt': FieldValue.serverTimestamp()
        });
        customToastInfo(message: 'report sent successfully!');
        }catch(e){
            customToastInfo(message: 'Error sending report. try again');
        }
      }
        } catch (e) {
      customToastInfo(message: "Error picking file: $e");
    }
  }

  Future<void> deleteNotification() async {
    try {
      await FirebaseFirestore.instance
          .collection("report_request")
          .doc(notificationId)
          .delete();
      customToastInfo(message: "Notification deleted successfully.");
    } catch (e) {
      customToastInfo(message: "Error deleting notification: $e");
    }
  }
}
