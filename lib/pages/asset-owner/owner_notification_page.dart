import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:land_house_verify/services/padf_preview_service.dart';
import 'package:url_launcher/url_launcher.dart';

class OwnerNotificationPage extends StatelessWidget {
  final String? owner;
  const OwnerNotificationPage({super.key, this.owner});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Notification"),),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance
          .collection('valuation-report')
          .where('to', isEqualTo: owner) // Filter by the current validator's name
          .snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot){
          if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return const Center(child: Text('Error loading assets'));
        }
    
        final assets = snapshot.data?.docs ?? [];
    
        if (assets.isEmpty) {
          return const Center(child: Text('No assets found for you'));
    
        }
          return ListView.builder(
          itemCount: assets.length,
          itemBuilder: (context, index) {
            final data = assets[index].data() as Map<String, dynamic>;
            final message = data['msg'] ?? 'Unknown owner';
            final document = data['reportUrl']?? 'Unknown owner';

            print(data);
    
            return Padding(
              padding: const EdgeInsets.all(8.0),
              child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: const Color.fromARGB(179, 231, 228, 228),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Padding(
                padding: const EdgeInsets.all(5),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(message),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        ElevatedButton(
                          onPressed: () async {
                            if (document != 'Unknown owner' && Uri.tryParse(document)?.hasScheme == true) {
                              final pdfUrl = document.replaceAll('/upload/', '/upload/fl_attachment/');
                              print('Attempting to open PDF preview for URL: $pdfUrl');
                              try {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => PdfPreviewPage(url: pdfUrl),
                                  ),
                                );
                              } catch (e) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('Could not open the document: $e')),
                                );
                              }
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Invalid document URL')),
                              );
                            }
                          },
                          child: const Text('View Document'),
                        ),
                        ElevatedButton(
                          onPressed: () async {
                            if (document != 'Unknown owner' && Uri.tryParse(document)?.hasScheme == true) {
                              // Convert to PDF download URL
                              final pdfUrl = document.replaceAll('/upload/', '/upload/fl_attachment/');
                              print('Attempting to download document from URL: $pdfUrl');
                              try {
                                final response = await http.get(Uri.parse(pdfUrl));
                                if (response.statusCode == 200) {
                                  // Save the file using a suitable method, e.g., using path_provider
                                  // Implement file saving logic here
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text('Failed to download document: ${response.statusCode}')),
                                  );
                                }
                              } catch (e) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('Could not download the document: $e')),
                                );
                              }
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Invalid document URL')),
                              );
                            }
                          },
                          child: const Text('Download Document'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            );
          },
        );
        }
        ),
    );
    
  }
}