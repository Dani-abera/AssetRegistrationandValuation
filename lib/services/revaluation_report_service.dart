import 'dart:io';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../model/validated_data_model.dart';

class RevaluationReportService {
  static Future<File> generateRevaluationReport({
    required ValidatedDataModel previousValidation,
    required ValidatedDataModel newValidation,
    required Map<String, double> currentExchangeRates,
    required double exchangeRateFactor,
    required double totalRevaluationFactor,
  }) async {
    final pdf = pw.Document();
    final formatter = NumberFormat('#,##0.00');

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        build: (context) => [
          _buildHeader(),
          _buildAssetInfo(previousValidation),
          _buildPreviousValidationDetails(previousValidation, formatter),
          _buildExchangeRateTable(
            previousValidation.exchangeRates!,
            currentExchangeRates,
            formatter,
          ),
          _buildRevaluationFactors(
            newValidation.memlcFactor,
            exchangeRateFactor,
            totalRevaluationFactor,
          ),
          _buildCostSummary(previousValidation, newValidation, formatter),
          _buildSignatureSection(),
        ],
      ),
    );

    return _saveDocument(pdf, previousValidation.name);
  }

  static pw.Widget _buildHeader() {
    return pw.Header(
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.center,
        children: [
          pw.Text(
            'Asset Revaluation Report',
            style: pw.TextStyle(
              fontSize: 24,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
          pw.SizedBox(height: 8),
          pw.Text(
            'Generated on ${DateFormat('dd MMMM yyyy').format(DateTime.now())}',
            style: const pw.TextStyle(
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  static pw.Widget _buildAssetInfo(ValidatedDataModel validation) {
    return pw.Container(
      margin: const pw.EdgeInsets.symmetric(vertical: 20),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            'Asset Information',
            style: pw.TextStyle(
              fontSize: 18,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
          pw.SizedBox(height: 10),
          _buildInfoRow('Asset Name', validation.name),
          _buildInfoRow('Asset Type', validation.assetType),
          _buildInfoRow(
              'Asset Location', validation.assetInfo?['location'] ?? 'N/A'),
          _buildInfoRow('Title Deed Number',
              validation.assetInfo?['titleDeedNumber'] ?? 'N/A'),
        ],
      ),
    );
  }

  static pw.Widget _buildPreviousValidationDetails(
    ValidatedDataModel validation,
    NumberFormat formatter,
  ) {
    return pw.Container(
      margin: const pw.EdgeInsets.symmetric(vertical: 10),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            'Previous Validation Details',
            style: pw.TextStyle(
              fontSize: 18,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
          pw.SizedBox(height: 10),
          _buildInfoRow('Validation Date',
              DateFormat('dd MMM yyyy').format(validation.valuationDate)),
          _buildInfoRow('Valuator', validation.valuatorName),
          _buildInfoRow('Valuation Method', validation.valuationMethod),
          _buildInfoRow('Original Cost',
              'ETB ${formatter.format(validation.totalCostBuilding)}'),
        ],
      ),
    );
  }

  static pw.Widget _buildExchangeRateTable(
    Map<String, double> previousRates,
    Map<String, double> currentRates,
    NumberFormat formatter,
  ) {
    return pw.Container(
      margin: const pw.EdgeInsets.symmetric(vertical: 10),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            'Exchange Rate Comparison',
            style: pw.TextStyle(
              fontSize: 18,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
          pw.SizedBox(height: 10),
          pw.Table(
            border: pw.TableBorder.all(),
            children: [
              pw.TableRow(
                decoration: pw.BoxDecoration(
                  color: PdfColors.grey300,
                ),
                children: [
                  _buildTableCell('Currency', isHeader: true),
                  _buildTableCell('Previous Rate', isHeader: true),
                  _buildTableCell('Current Rate', isHeader: true),
                  _buildTableCell('Change %', isHeader: true),
                ],
              ),
              ...['USD', 'EUR', 'GBP', 'AED'].map((currency) {
                if (previousRates.containsKey(currency) &&
                    currentRates.containsKey(currency)) {
                  final prevRate = previousRates[currency]!;
                  final currRate = currentRates[currency]!;
                  final change = ((currRate - prevRate) / prevRate) * 100;

                  return pw.TableRow(
                    children: [
                      _buildTableCell(currency),
                      _buildTableCell(formatter.format(prevRate)),
                      _buildTableCell(formatter.format(currRate)),
                      _buildTableCell('${formatter.format(change)}%'),
                    ],
                  );
                }
                return pw.TableRow(
                  children: List.filled(4, _buildTableCell('N/A')),
                );
              }).toList(),
            ],
          ),
        ],
      ),
    );
  }

  static pw.Widget _buildRevaluationFactors(
    double memlcFactor,
    double exchangeRateFactor,
    double totalFactor,
  ) {
    return pw.Container(
      margin: const pw.EdgeInsets.symmetric(vertical: 10),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            'Revaluation Factors',
            style: pw.TextStyle(
              fontSize: 18,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
          pw.SizedBox(height: 10),
          _buildInfoRow('MEMLC Factor', memlcFactor.toStringAsFixed(4)),
          _buildInfoRow(
              'Exchange Rate Factor', exchangeRateFactor.toStringAsFixed(4)),
          _buildInfoRow(
              'Total Revaluation Factor', totalFactor.toStringAsFixed(4)),
        ],
      ),
    );
  }

  static pw.Widget _buildCostSummary(
    ValidatedDataModel previousValidation,
    ValidatedDataModel newValidation,
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
          _buildInfoRow('Original Cost',
              'ETB ${formatter.format(previousValidation.totalCostBuilding)}'),
          _buildInfoRow('Revalued Cost',
              'ETB ${formatter.format(newValidation.totalCostAfterRevaluation)}'),
          pw.SizedBox(height: 10),
          _buildInfoRow('Net Change',
              'ETB ${formatter.format(newValidation.totalCostAfterRevaluation - (previousValidation.totalCostBuilding ?? 0))}'),
          _buildInfoRow('Percentage Change',
              '${formatter.format(((newValidation.totalCostAfterRevaluation - (previousValidation.totalCostBuilding ?? 0)) / (previousValidation.totalCostBuilding ?? 1) * 100))}%'),
        ],
      ),
    );
  }

  static pw.Widget _buildSignatureSection() {
    return pw.Container(
      margin: const pw.EdgeInsets.symmetric(vertical: 20),
      child: pw.Column(
        children: [
          pw.SizedBox(height: 40),
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceAround,
            children: [
              _buildSignatureLine('Prepared By'),
              _buildSignatureLine('Approved By'),
            ],
          ),
        ],
      ),
    );
  }

  static pw.Widget _buildSignatureLine(String title) {
    return pw.Column(
      children: [
        pw.Container(
          width: 200,
          height: 1,
          color: PdfColors.black,
        ),
        pw.SizedBox(height: 5),
        pw.Text(title),
      ],
    );
  }

  static pw.Widget _buildInfoRow(String label, String value) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 2),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(label),
          pw.Text(value),
        ],
      ),
    );
  }

  static pw.Widget _buildTableCell(String text, {bool isHeader = false}) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(6),
      alignment: pw.Alignment.center,
      child: pw.Text(
        text,
        style: pw.TextStyle(
          fontWeight: isHeader ? pw.FontWeight.bold : null,
        ),
      ),
    );
  }

  static Future<File> _saveDocument(pw.Document pdf, String assetName) async {
    final dir = await getApplicationDocumentsDirectory();
    final fileName = 'revaluation_${assetName.replaceAll(' ', '_')}_' +
        '${DateTime.now().millisecondsSinceEpoch}.pdf';
    final file = File('${dir.path}/$fileName');
    await file.writeAsBytes(await pdf.save());
    return file;
  }
}
