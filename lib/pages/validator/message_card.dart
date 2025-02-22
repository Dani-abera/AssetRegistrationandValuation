import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:land_house_verify/services/cloudinary_file_upload_servise.dart';
import 'package:land_house_verify/services/file_picker_service.dart';
import 'package:toastification/toastification.dart';
import 'labeled_row.dart';

class MessageCard extends StatefulWidget {
  final String from;
  final String assetName;
  final String message;
  final String notificationId;

  const MessageCard({
    super.key,
    required this.from,
    required this.assetName,
    required this.message,
    required this.notificationId,
  });
  
  @override
  State<MessageCard> createState() => _MessageCardState();
}

class _MessageCardState extends State<MessageCard> {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withAlpha(127),
            spreadRadius: 2,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            LabeledRow(label: "From", value: widget.from),
            const SizedBox(height: 8),
            LabeledRow(label: "Asset Name", value: widget.assetName),
            const SizedBox(height: 8),
            LabeledRow(label: "Message", value: widget.message),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton(
                  onPressed: handleFileUpload,
                  child: const Text("Send Valuation Report", style: TextStyle(color: Colors.blue)),
                ),
                TextButton(
                  onPressed: deleteNotification,
                  child: const Text("Delete Notification", style: TextStyle(color: Colors.red)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> handleFileUpload() async {
    try {
      String valuationReport = await FilePickerService().pickDocument();
      String? uploadedDocumentUrl = await CloudinaryFileUploadService()
          .uploadFileToFirebase(valuationReport, 'valuation-report');
      
      if (uploadedDocumentUrl != null) {
        await FirebaseFirestore.instance.collection("valuation-report").add({
          'reportUrl': uploadedDocumentUrl,
          'to': widget.from,
          'msg': '${widget.assetName} valuation report document',
          'createdAt': FieldValue.serverTimestamp()
        });
        
        toastification.show(
          title: const Text("Success"),
          type: ToastificationType.success,
          description: const Text("Report sent successfully!"),
        );
      }
    } catch (e) {
      toastification.show(
        title: const Text("Error"),
        type: ToastificationType.error,
        description: Text("Error: $e"),
      );
    }
  }

  Future<void> deleteNotification() async {
    try {
      await FirebaseFirestore.instance
          .collection("report_request")
          .doc(widget.notificationId)
          .delete();
      
      toastification.show(
        title: const Text("Success"),
        type: ToastificationType.success,
        description: const Text("Notification deleted successfully."),
      );    
    } catch (e) {
      toastification.show(
        title: const Text("Error"),
        type: ToastificationType.error,
        description: Text("Error deleting notification: $e"),
      );  
    }
  }
}
