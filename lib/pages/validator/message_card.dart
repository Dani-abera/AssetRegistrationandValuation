import 'package:flutter/material.dart';
import 'package:land_house_verify/components/custom_toast_info.dart';
import 'labeled_row.dart'; // Adjust the import based on your file structure

class MessageCard extends StatelessWidget {
  final String from;
  final String assetName;
  final String message;

  const MessageCard({
    Key? key,
    required this.from,
    required this.assetName,
    required this.message,
  }) : super(key: key);

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
            SizedBox(height: 20,),
            GestureDetector(
              onTap: () => customToastInfo(
                context: context,
                message: "Valuation Report send to $from"
              ),
              child: Text("Send Valuation Report", style: TextStyle(color: Colors.blue),
                      ),
            )],
        ),
      ),
    );
  }
}
