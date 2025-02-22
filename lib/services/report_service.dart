import 'dart:async';
import 'dart:io';

import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;

import '../model/validated_data_model.dart';

class ReportService {
  final cache = DefaultCacheManager();

  Future<File> generateValidationReport(ValidatedDataModel validation) async {
    if (validation.assetType == 'Land') {
      return _generateLandReport(validation);
    } else {
      return _generateBuildingReport(validation);
    }
  }

  Future<File> _generateLandReport(ValidatedDataModel validation) async {
    print('Testing image URLs for land report...');
    await testImageUrls(validation.imageUrls ?? []);
    final pdf = pw.Document();
    final currencyFormat = NumberFormat("#,##0.00", "en_US");

    // Create all sections, including images
    final List<pw.Widget> content = [
      _buildHeader('Land Validation Report'),
      _buildBasicInfo(validation),
      await _buildImagesSection(validation.imageUrls),
      _buildLandValuationDetails(validation, currencyFormat),
      if (validation.valuationStatus == 'Revaluation')
        _buildRevaluationInfo(validation, currencyFormat),
      _buildExchangeRatesTable(validation, currencyFormat),
      _buildSummarySection(validation),
      _buildSignatureSection(validation),
    ];

    pdf.addPage(
      pw.MultiPage(
        build: (context) => content,
      ),
    );

    return _saveDocument(pdf, 'land_validation_${validation.id}.pdf');
  }

  Future<File> _generateBuildingReport(ValidatedDataModel validation) async {
    print('Testing image URLs for land report...');
    await testImageUrls(validation.imageUrls ?? []);
    final pdf = pw.Document();
    final currencyFormat = NumberFormat("#,##0.00", "en_US");

    final List<pw.Widget> content = [
      _buildHeader('Building Validation Report'),
      _buildBasicInfo(validation),
      await _buildImagesSection(validation.imageUrls),
      _buildConstructionCosts(validation, currencyFormat),
      _buildBuildingRelatedCosts(validation, currencyFormat),
      _buildCostSummary(validation, currencyFormat),
      if (validation.valuationStatus == 'Revaluation')
        _buildRevaluationInfo(validation, currencyFormat),
      _buildExchangeRateSection(validation, currencyFormat),
      _buildSummarySection(validation),
      _buildSignatureSection(validation),
    ];

    pdf.addPage(
      pw.MultiPage(
        build: (context) => content,
      ),
    );

    return _saveDocument(pdf, 'building_validation_${validation.id}.pdf');
  }

  Future<void> testImageUrls(List<String>? urls) async {
    if (urls == null || urls.isEmpty) {
      print('No URLs to test');
      return;
    }

    print('Starting URL testing...');
    for (String url in urls) {
      try {
        print('\nTesting URL: $url');
        final response = await http.get(Uri.parse(url));
        print('Status Code: ${response.statusCode}');
        print('Content-Type: ${response.headers['content-type']}');
        print('Content-Length: ${response.contentLength}');

        if (response.statusCode == 200) {
          print('✓ URL is accessible');
          if (response.headers['content-type']?.startsWith('image/') ?? false) {
            print('✓ Content is an image');
          } else {
            print(
                '⚠ Content is not an image: ${response.headers['content-type']}');
          }
        } else {
          print('⚠ URL is not accessible');
        }
      } catch (e) {
        print('⚠ Error testing URL $url: $e');
      }
    }
    print('\nURL testing completed');
  } // Image handling methods

  Future<pw.MemoryImage?> _fetchImage(String url) async {
    try {
      print('Starting image fetch from: $url');

      // Try to get from cache first
      final file = await cache.getSingleFile(url);
      if (await file.exists()) {
        print('Loading image from cache');
        final bytes = await file.readAsBytes();
        return pw.MemoryImage(bytes);
      }

      // If not in cache, download directly
      print('Downloading image from URL');
      final response = await http.get(Uri.parse(url)).timeout(
        const Duration(seconds: 30),
        onTimeout: () {
          print('Image download timed out');
          throw TimeoutException('Image download timed out');
        },
      );

      if (response.statusCode == 200) {
        final bytes = response.bodyBytes;
        if (bytes.isNotEmpty) {
          // Cache the downloaded image
          await cache.putFile(url, bytes);
          return pw.MemoryImage(bytes);
        }
      }

      print('Failed to load image: ${response.statusCode}');
      return null;
    } catch (e, stackTrace) {
      print('Error loading image: $e');
      print('Stack trace: $stackTrace');
      return null;
    }
  }

  Future<pw.Widget> _buildImagesSection(List<String>? imageUrls) async {
    if (imageUrls == null || imageUrls.isEmpty) {
      print('No image URLs provided');
      return pw.Container();
    }

    print('Starting to process ${imageUrls.length} images');
    List<pw.Widget> imageWidgets = [];

    for (String url in imageUrls) {
      try {
        print('Processing image URL: $url');
        final image = await _fetchImage(url);

        if (image != null) {
          imageWidgets.add(
            pw.Padding(
              padding: const pw.EdgeInsets.symmetric(vertical: 5),
              child: pw.Column(
                children: [
                  pw.SizedBox(
                    height: 200,
                    width: 400,
                    child: pw.Center(
                      child: pw.Image(
                        image,
                        fit: pw.BoxFit.contain,
                      ),
                    ),
                  ),
                  pw.SizedBox(height: 5),
                  pw.Text(
                    'Asset Image',
                    style: pw.TextStyle(
                      fontSize: 10,
                      color: PdfColors.grey700,
                    ),
                  ),
                ],
              ),
            ),
          );
          print('Successfully added image to PDF');
        } else {
          print('Failed to process image: $url');
        }
      } catch (e) {
        print('Error processing image: $e');
        continue;
      }
    }

    return pw.Container(
      margin: const pw.EdgeInsets.symmetric(vertical: 10),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            'Asset Images',
            style: pw.TextStyle(
              fontSize: 18,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
          pw.SizedBox(height: 10),
          ...imageWidgets,
        ],
      ),
    );
  }

  pw.Widget _buildSummarySection(ValidatedDataModel validation) {
    return pw.Container(
      margin: const pw.EdgeInsets.symmetric(vertical: 10),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            'Assumptions',
            style: pw.TextStyle(
              fontSize: 18,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
          pw.SizedBox(height: 10),
          pw.Text(validation.summary, style: pw.TextStyle(fontSize: 12)),
        ],
      ),
    );
  }

  pw.Widget _buildExchangeRatesTable(
    ValidatedDataModel validation,
    NumberFormat formatter,
  ) {
    try {
      if (validation.exchangeRates == null ||
          validation.exchangeRates!.isEmpty) {
        print('No exchange rates available');
        return pw.Container();
      }

      double totalAmount = 0.0;
      if (validation.assetType == 'Land') {
        totalAmount =
            (validation.landArea ?? 0.0) * (validation.landUnitRate ?? 0.0);
        print('Calculated land total amount: $totalAmount');
      } else {
        totalAmount = validation.totalCostBuilding ?? 0.0;
        print('Using building total amount: $totalAmount');
      }

      final List<String> currencies = ['USD', 'AUD', 'CAD', 'AED'];
      final List<pw.TableRow> tableRows = [
        _buildTableHeader(['Currency', 'ETB Rate', 'Equivalent Value']),
      ];

      for (String currency in currencies) {
        if (validation.exchangeRates!.containsKey(currency)) {
          try {
            final double rate =
                _parseDouble(validation.exchangeRates![currency]);
            final double etbRate =
                _parseDouble(validation.exchangeRates!['ETB']);

            if (rate > 0 && etbRate > 0) {
              final double convertedRate = etbRate / rate;
              final double equivalentValue = totalAmount / convertedRate;

              print(
                  'Processing $currency: Rate=$rate, ETB Rate=$etbRate, Converted=$convertedRate');

              tableRows.add(
                pw.TableRow(
                  children: [
                    _buildCell(currency),
                    _buildCell(formatter.format(convertedRate)),
                    _buildCell(formatter.format(equivalentValue)),
                  ],
                ),
              );
            }
          } catch (e) {
            print('Error processing currency $currency: $e');
            continue;
          }
        }
      }

      return pw.Container(
        margin: const pw.EdgeInsets.symmetric(vertical: 10),
        child: pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text(
              'Exchange Rates and Currency Conversion',
              style: pw.TextStyle(
                fontSize: 14,
                fontWeight: pw.FontWeight.bold,
              ),
            ),
            pw.SizedBox(height: 10),
            pw.Table(
              border: pw.TableBorder.all(),
              children: tableRows,
            ),
            pw.SizedBox(height: 5),
            pw.Text(
              'Exchange rates as of ${DateFormat('dd MMM yyyy').format(validation.valuationDate)}',
              style: const pw.TextStyle(
                fontSize: 10,
                color: PdfColors.grey700,
              ),
            ),
          ],
        ),
      );
    } catch (e, stackTrace) {
      print('Error building exchange rates table: $e');
      print('Stack trace: $stackTrace');
      return pw.Container();
    }
  }

  // Building sections methods
  pw.Widget _buildHeader(String title) {
    return pw.Header(
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            title,
            style: pw.TextStyle(
              fontSize: 24,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
          pw.SizedBox(height: 8),
          pw.Text(
            'Generated on: ${DateFormat('dd MMM yyyy, HH:mm').format(DateTime.now())}',
            style: const pw.TextStyle(fontSize: 14),
          ),
        ],
      ),
    );
  }

  pw.Widget _buildBasicInfo(ValidatedDataModel validation) {
    return pw.Container(
      margin: const pw.EdgeInsets.symmetric(vertical: 10),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            'Basic Information',
            style: pw.TextStyle(
              fontSize: 18,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
          pw.SizedBox(height: 10),
          _buildInfoRow('Asset Name', validation.name),
          _buildInfoRow('Valuator Name', validation.valuatorName),
          _buildInfoRow('Valuation Executor', validation.valuationExecutor),
          _buildInfoRow('Asset Type', validation.assetType),
          _buildInfoRow('Valuation Method', validation.valuationMethod),
          _buildInfoRow('Valuation Status', validation.valuationStatus),
          _buildInfoRow(
            'Valuation Date',
            DateFormat('dd MMM yyyy').format(validation.valuationDate),
          ),
          if (validation.assetInfo != null) ...[
            _buildInfoRow('Location', validation.assetInfo!['location'] ?? ''),
            _buildInfoRow(
                'Title Deed', validation.assetInfo!['titleDeedNumber'] ?? ''),
            _buildInfoRow('Owner', validation.assetInfo!['ownership'] ?? ''),
          ],
        ],
      ),
    );
  }

  pw.Widget _buildLandValuationDetails(
    ValidatedDataModel validation,
    NumberFormat formatter,
  ) {
    return pw.Container(
      margin: const pw.EdgeInsets.symmetric(vertical: 10),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            'Land Valuation Details',
            style: pw.TextStyle(
              fontSize: 18,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
          pw.SizedBox(height: 10),
          pw.Table(
            border: pw.TableBorder.all(),
            children: [
              _buildTableHeader(
                  ['Valuation Method', 'Area (m²)', 'Rate/m²', 'Total Value']),
              pw.TableRow(
                children: [
                  _buildCell(validation.selectedValuMethod ?? ''),
                  _buildCell(validation.landArea?.toString() ?? '0'),
                  _buildCell(formatter.format(validation.landUnitRate ?? 0)),
                  _buildCell(
                    formatter.format(
                      (validation.landArea ?? 0) *
                          (validation.landUnitRate ?? 0),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  pw.Widget _buildConstructionCosts(
    ValidatedDataModel validation,
    NumberFormat formatter,
  ) {
    return pw.Container(
      margin: const pw.EdgeInsets.symmetric(vertical: 10),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            'Construction Costs',
            style: pw.TextStyle(
              fontSize: 18,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
          pw.SizedBox(height: 10),
          pw.Table(
            border: pw.TableBorder.all(),
            children: [
              _buildTableHeader([
                'Description',
                'Area (m²)',
                'Buildings',
                'Unit Rate',
                'Amount'
              ]),
              ...validation.constructionCosts.map(
                (cost) => pw.TableRow(
                  children: [
                    _buildCell(cost.description),
                    _buildCell(cost.areaInM2.toString()),
                    _buildCell(cost.numberOfTypicalBuildings.toString()),
                    _buildCell(formatter.format(cost.unitRate)),
                    _buildCell(formatter.format(cost.amount)),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  pw.Widget _buildBuildingRelatedCosts(
    ValidatedDataModel validation,
    NumberFormat formatter,
  ) {
    return pw.Container(
      margin: const pw.EdgeInsets.symmetric(vertical: 10),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            'Building Related Costs',
            style: pw.TextStyle(
              fontSize: 18,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
          pw.SizedBox(height: 10),
          pw.Table(
            border: pw.TableBorder.all(),
            children: [
              _buildTableHeader(['Description', 'Amount']),
              ...validation.buildingRelatedCosts.map(
                (cost) => pw.TableRow(
                  children: [
                    _buildCell(cost.description),
                    _buildCell(formatter.format(cost.amount)),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  pw.Widget _buildCostSummary(
    ValidatedDataModel validation,
    NumberFormat formatter,
  ) {
    return pw.Container(
      margin: const pw.EdgeInsets.symmetric(vertical: 10),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            'Cost Summary',
            style: pw.TextStyle(
              fontSize: 18,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
          pw.SizedBox(height: 10),
          _buildInfoRow(
            'Total Construction Cost',
            formatter.format(validation.totalCostBuildingConstruction ?? 0),
          ),
          _buildInfoRow(
            'Total Building Related Cost',
            formatter.format(validation.totalBuildingRelatedCost ?? 0),
          ),
          pw.Divider(),
          _buildInfoRow(
            'Total Cost',
            formatter.format(validation.totalCostBuilding ?? 0),
            isBold: true,
          ),
        ],
      ),
    );
  }

  pw.Widget _buildRevaluationInfo(
    ValidatedDataModel validation,
    NumberFormat formatter,
  ) {
    return pw.Container(
      margin: const pw.EdgeInsets.symmetric(vertical: 10),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            'Revaluation Information',
            style: pw.TextStyle(
              fontSize: 18,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
          pw.SizedBox(height: 10),
          _buildInfoRow('MEMLC Factor', validation.memlcFactor.toString()),
          _buildInfoRow(
              'Currency Factor', validation.currencyFactor.toString()),
          pw.Divider(),
          _buildInfoRow(
            'Total Cost After Revaluation',
            formatter.format(validation.totalCostAfterRevaluation),
            isBold: true,
          ),
        ],
      ),
    );
  }

  pw.Widget _buildExchangeRateSection(
    ValidatedDataModel validation,
    NumberFormat formatter,
  ) {
    if (validation.exchangeRates == null) return pw.Container();

    double totalAmount = 0.0;
    if (validation.assetType == 'Land') {
      totalAmount =
          (validation.landArea ?? 0.0) * (validation.landUnitRate ?? 0.0);
    } else {
      totalAmount = validation.totalCostBuilding ?? 0.0;
    }

    List<pw.TableRow> rows = [
      _buildTableHeader(['Currency', 'ETB Rate', 'Equivalent Amount']),
    ];

    for (String currency in ['USD', 'AUD', 'CAD', 'AED']) {
      if (validation.exchangeRates!.containsKey(currency)) {
        try {
          double rate = _parseDouble(validation.exchangeRates![currency]);
          double etbRate = _parseDouble(validation.exchangeRates!['ETB']);

          if (rate > 0) {
            double convertedRate = etbRate / rate;
            double equivalentAmount = totalAmount / convertedRate;

            rows.add(
              pw.TableRow(
                children: [
                  _buildCell(currency),
                  _buildCell(formatter.format(convertedRate)),
                  _buildCell(formatter.format(equivalentAmount)),
                ],
              ),
            );
          }
        } catch (e) {
          print('Error processing currency $currency: $e');
          continue;
        }
      }
    }

    return pw.Container(
      margin: const pw.EdgeInsets.symmetric(vertical: 10),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            'Currency Exchange Rates',
            style: pw.TextStyle(
              fontSize: 14,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
          pw.SizedBox(height: 10),
          pw.Table(
            border: pw.TableBorder.all(),
            children: rows,
          ),
          pw.SizedBox(height: 5),
          pw.Text(
            'Exchange rates as of ${DateFormat('dd MMM yyyy').format(validation.valuationDate)}',
            style: const pw.TextStyle(
              fontSize: 10,
              color: PdfColors.grey700,
            ),
          ),
        ],
      ),
    );
  }

  pw.Widget _buildSignatureSection(ValidatedDataModel validation) {
    return pw.Container(
      margin: const pw.EdgeInsets.only(top: 30),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text('Prepared by:'),
              pw.SizedBox(height: 20),
              pw.Text(validation.valuatorName),
            ],
          ),
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text('Date:'),
              pw.SizedBox(height: 20),
              pw.Text(
                  DateFormat('dd MMM yyyy').format(validation.valuationDate)),
            ],
          ),
        ],
      ),
    );
  }

  // Helper methods
  pw.TableRow _buildTableHeader(List<String> headers) {
    return pw.TableRow(
      decoration: const pw.BoxDecoration(color: PdfColors.grey300),
      children: headers
          .map(
            (header) => pw.Container(
              padding: const pw.EdgeInsets.all(5),
              child: pw.Text(
                header,
                style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
              ),
            ),
          )
          .toList(),
    );
  }

  pw.Widget _buildCell(String text, {bool isHeader = false}) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(5),
      child: pw.Text(
        text,
        style: pw.TextStyle(
          fontWeight: isHeader ? pw.FontWeight.bold : null,
        ),
      ),
    );
  }

  pw.Widget _buildInfoRow(String label, String value, {bool isBold = false}) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 2),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(label),
          pw.Text(
            value,
            style: pw.TextStyle(
              fontWeight: isBold ? pw.FontWeight.bold : null,
            ),
          ),
        ],
      ),
    );
  }

  double _parseDouble(dynamic value) {
    if (value is int) {
      return value.toDouble();
    } else if (value is double) {
      return value;
    } else if (value is String) {
      return double.tryParse(value) ?? 0.0;
    }
    return 0.0;
  }

  Future<File> _saveDocument(pw.Document pdf, String filename) async {
    try {
      final dir = await getApplicationDocumentsDirectory();
      final file = File('${dir.path}/$filename');
      await file.writeAsBytes(await pdf.save());
      print('PDF saved successfully at: ${file.path}');
      return file;
    } catch (e) {
      print('Error saving PDF: $e');
      rethrow;
    }
  }
}
