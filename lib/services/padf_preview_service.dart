import 'package:flutter/material.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';

class PdfPreviewPage extends StatelessWidget {
  final String url;

  const PdfPreviewPage({super.key, required this.url});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("PDF Preview"),
      ),
      body: PDFView(
        filePath: url, // Use the URL directly if the PDF is accessible
        enableSwipe: true,
        swipeHorizontal: true,
        autoSpacing: false,
        pageFling: false,
        onPageChanged: (page, total) => print('Page $page of $total'),
      ),
    );
  }
}
