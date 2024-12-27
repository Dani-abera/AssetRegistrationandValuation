import 'dart:io';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:intl/intl.dart';
import '../model/validated_data_model.dart';

class ReportService {
  Future<File> generateValidationReport(ValidatedDataModel validation) async {
    final pdf = pw.Document();
    final currencyFormat = NumberFormat("#,##0.00", "en_US");

    pdf.addPage(
      pw.MultiPage(
        build: (context) => [
          _buildHeader(validation),
          _buildBasicInfo(validation),
          _buildConstructionCosts(validation, currencyFormat),
          _buildBuildingRelatedCosts(validation, currencyFormat),
          _buildCostSummary(validation, currencyFormat),
          if (validation.valuationStatus == 'Revaluation')
            _buildRevaluationInfo(validation, currencyFormat),
        ],
      ),
    );

    return _saveDocument(pdf, 'validation_${validation.id}.pdf');
  }

  pw.Widget _buildHeader(ValidatedDataModel validation) {
    return pw.Header(
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            'Asset Validation Report',
            style: pw.TextStyle(
              fontSize: 24,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
          pw.SizedBox(height: 8),
          pw.Text(
            'Generated on: ${DateFormat('dd MMM yyyy, HH:mm').format(DateTime.now())}',
            style: const pw.TextStyle(
              fontSize: 14,
            ),
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
        ],
      ),
    );
  }

  pw.Widget _buildConstructionCosts(
    ValidatedDataModel validation,
    NumberFormat formatter,
  ) {
    final headers = [
      'Description',
      'Area (m²)',
      'Buildings',
      'Unit Rate',
      'Amount'
    ];

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
              pw.TableRow(
                children: headers
                    .map((header) => pw.Container(
                          padding: const pw.EdgeInsets.all(5),
                          child: pw.Text(
                            header,
                            style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                          ),
                        ))
                    .toList(),
              ),
              ...validation.constructionCosts.map(
                (cost) => pw.TableRow(
                  children: [
                    pw.Container(
                      padding: const pw.EdgeInsets.all(5),
                      child: pw.Text(cost.description),
                    ),
                    pw.Container(
                      padding: const pw.EdgeInsets.all(5),
                      child: pw.Text(cost.areaInM2.toString()),
                    ),
                    pw.Container(
                      padding: const pw.EdgeInsets.all(5),
                      child: pw.Text(cost.numberOfTypicalBuildings.toString()),
                    ),
                    pw.Container(
                      padding: const pw.EdgeInsets.all(5),
                      child: pw.Text(formatter.format(cost.unitRate)),
                    ),
                    pw.Container(
                      padding: const pw.EdgeInsets.all(5),
                      child: pw.Text(formatter.format(cost.amount)),
                    ),
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
              pw.TableRow(
                children: [
                  pw.Container(
                    padding: const pw.EdgeInsets.all(5),
                    child: pw.Text(
                      'Description',
                      style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                    ),
                  ),
                  pw.Container(
                    padding: const pw.EdgeInsets.all(5),
                    child: pw.Text(
                      'Amount',
                      style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                    ),
                  ),
                ],
              ),
              ...validation.buildingRelatedCosts.map(
                (cost) => pw.TableRow(
                  children: [
                    pw.Container(
                      padding: const pw.EdgeInsets.all(5),
                      child: pw.Text(cost.description),
                    ),
                    pw.Container(
                      padding: const pw.EdgeInsets.all(5),
                      child: pw.Text(formatter.format(cost.amount)),
                    ),
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
            formatter.format(validation.totalCostBuildingConstruction),
          ),
          _buildInfoRow(
            'Total Building Related Cost',
            formatter.format(validation.totalBuildingRelatedCost),
          ),
          pw.Divider(),
          _buildInfoRow(
            'Total Cost',
            formatter.format(validation.totalCostBuilding),
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

  Future<File> _saveDocument(pw.Document pdf, String filename) async {
    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/$filename');
    await file.writeAsBytes(await pdf.save());
    return file;
  }
}
