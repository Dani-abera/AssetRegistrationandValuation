import 'dart:io';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:intl/intl.dart';
import '../model/validated_data_model.dart';

class ReportService {
  Future<File> generateValidationReport(ValidatedDataModel validation) async {
    if (validation.assetType == 'Land') {
      return _generateLandReport(validation);
    } else {
      return _generateBuildingReport(validation);
    }
  }

  Future<File> _generateLandReport(ValidatedDataModel validation) async {
    final pdf = pw.Document();
    final currencyFormat = NumberFormat("#,##0.00", "en_US");

    pdf.addPage(
      pw.MultiPage(
        build: (context) => [
          _buildHeader('Land Validation Report'),
          _buildBasicInfo(validation),
          _buildLandValuationDetails(validation, currencyFormat),
          if (validation.valuationStatus == 'Revaluation')
            _buildRevaluationInfo(validation, currencyFormat),
          _buildExchangeRatesTable(validation, currencyFormat),
          _buildSignatureSection(validation),
        ],
      ),
    );

    return _saveDocument(pdf, 'land_validation_${validation.id}.pdf');
  }

  Future<File> _generateBuildingReport(ValidatedDataModel validation) async {
    final pdf = pw.Document();
    final currencyFormat = NumberFormat("#,##0.00", "en_US");

    pdf.addPage(
      pw.MultiPage(
        build: (context) => [
          _buildHeader('Building Validation Report'),
          _buildBasicInfo(validation),
          _buildConstructionCosts(validation, currencyFormat),
          _buildBuildingRelatedCosts(validation, currencyFormat),
          _buildCostSummary(validation, currencyFormat),
          if (validation.valuationStatus == 'Revaluation')
            _buildRevaluationInfo(validation, currencyFormat),
          _buildExchangeRateSection(validation, currencyFormat),
          _buildSignatureSection(validation),
        ],
      ),
    );

    return _saveDocument(pdf, 'building_validation_${validation.id}.pdf');
  }

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
              pw.TableRow(
                children: [
                  pw.Container(
                    padding: const pw.EdgeInsets.all(5),
                    child: pw.Text(
                      'Valuation Method',
                      style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                    ),
                  ),
                  pw.Container(
                    padding: const pw.EdgeInsets.all(5),
                    child: pw.Text(
                      'Area (m²)',
                      style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                    ),
                  ),
                  pw.Container(
                    padding: const pw.EdgeInsets.all(5),
                    child: pw.Text(
                      'Rate/m²',
                      style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                    ),
                  ),
                  pw.Container(
                    padding: const pw.EdgeInsets.all(5),
                    child: pw.Text(
                      'Total Value',
                      style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                    ),
                  ),
                ],
              ),
              pw.TableRow(
                children: [
                  pw.Container(
                    padding: const pw.EdgeInsets.all(5),
                    child: pw.Text(validation.selectedValuMethod ?? ''),
                  ),
                  pw.Container(
                    padding: const pw.EdgeInsets.all(5),
                    child: pw.Text(validation.landArea?.toString() ?? '0'),
                  ),
                  pw.Container(
                    padding: const pw.EdgeInsets.all(5),
                    child:
                        pw.Text(formatter.format(validation.landUnitRate ?? 0)),
                  ),
                  pw.Container(
                    padding: const pw.EdgeInsets.all(5),
                    child: pw.Text(
                      formatter.format((validation.landArea ?? 0) *
                          (validation.landUnitRate ?? 0)),
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

  pw.Widget _buildExchangeRatesTable(
      ValidatedDataModel validation, NumberFormat formatter) {
    try {
      if (validation.exchangeRates == null ||
          validation.exchangeRates!.isEmpty) {
        return pw.Container();
      }

      double totalAmount = 0.0;
      if (validation.assetType == 'Land') {
        totalAmount =
            (validation.landArea ?? 0.0) * (validation.landUnitRate ?? 0.0);
      } else {
        totalAmount = validation.totalCostBuilding ?? 0.0;
      }

      final List<String> currencies = ['USD', 'AUD', 'CAD', 'AED'];
      final List<pw.TableRow> tableRows = [];

      tableRows.add(
        pw.TableRow(
          decoration: const pw.BoxDecoration(color: PdfColors.grey300),
          children: [
            _buildTableCell('Currency', isHeader: true),
            _buildTableCell('ETB Rate', isHeader: true),
            _buildTableCell('Equivalent Value', isHeader: true),
          ],
        ),
      );

      for (String currency in currencies) {
        if (validation.exchangeRates!.containsKey(currency)) {
          try {
            final double rate =
                _parseDouble(validation.exchangeRates![currency]);
            final double etbRate =
                _parseDouble(validation.exchangeRates!['ETB']) / rate;
            final double equivalentValue = totalAmount / etbRate;

            tableRows.add(
              pw.TableRow(
                children: [
                  _buildTableCell(currency),
                  _buildTableCell(formatter.format(etbRate)),
                  _buildTableCell(formatter.format(equivalentValue)),
                ],
              ),
            );
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
    } catch (e) {
      print('Error building exchange rates table: $e');
      return pw.Container();
    }
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

  pw.Widget _buildTableCell(String text, {bool isHeader = false}) {
    return pw.Padding(
      padding: const pw.EdgeInsets.all(5),
      child: pw.Text(
        text,
        style: pw.TextStyle(
          fontWeight: isHeader ? pw.FontWeight.bold : null,
        ),
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

  pw.Widget _buildExchangeRateSection(
      ValidatedDataModel validation, NumberFormat formatter) {
    if (validation.exchangeRates == null) return pw.Container();

    // Calculate the total amount based on asset type
    double totalAmount = 0.0;
    if (validation.assetType == 'Land') {
      double landArea = double.tryParse(validation.landArea.toString()) ?? 0.0;
      double unitRate =
          double.tryParse(validation.landUnitRate.toString()) ?? 0.0;
      totalAmount = landArea * unitRate;
    } else {
      totalAmount =
          double.tryParse(validation.totalCostBuilding.toString()) ?? 0.0;
    }

    List<pw.TableRow> rows = [
      pw.TableRow(
        decoration: const pw.BoxDecoration(color: PdfColors.grey300),
        children: [
          _buildHeaderCell('Currency'),
          _buildHeaderCell('ETB Rate'),
          _buildHeaderCell('Equivalent Amount'),
        ],
      ),
    ];
    for (String currency in ['USD', 'AUD', 'CAD', 'AED']) {
      if (validation.exchangeRates!.containsKey(currency)) {
        try {
          // Safe conversion of exchange rate values
          double rate =
              double.tryParse(validation.exchangeRates![currency].toString()) ??
                  0.0;
          double etbRate =
              double.tryParse(validation.exchangeRates!['ETB'].toString()) ??
                  0.0;

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

  pw.Widget _buildHeaderCell(String text) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(5),
      child: pw.Text(
        text,
        style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
      ),
    );
  }

  pw.Widget _buildCell(String text) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(5),
      child: pw.Text(text),
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
