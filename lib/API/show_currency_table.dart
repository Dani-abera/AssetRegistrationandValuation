import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'fetch_exchange_rate.dart';

class CurrencyConverterToETB extends StatefulWidget {
  const CurrencyConverterToETB({super.key});

  @override
  CurrencyConverterToETBState createState() => CurrencyConverterToETBState();
}

class CurrencyConverterToETBState extends State<CurrencyConverterToETB> {
  Map<String, dynamic>? exchangeRates;
  bool isLoading = true;
  final TextEditingController _amountController = TextEditingController();
  double amount = 0.0;

  // List of currencies to display
  var currencyList = ['USD', 'AUD', 'CAD', 'AED'];

  @override
  void initState() {
    super.initState();
    fetchExchangeRates();
  }

  Future<void> fetchExchangeRates() async {
    exchangeRates = await FetchExchangeRate.getExchangeRates();
    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Currency Converter to ETB'),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : exchangeRates == null
              ? Center(child: Text('Failed to load data'))
    : SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Enter Amount',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              TextField(
                
                controller: _amountController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Amount',
                  border: OutlineInputBorder(),
                ),
                
                onChanged: (value) {
                  setState(() {
                    amount = double.tryParse(value) ?? 0.0;
                  });
                },
              ),
              SizedBox(height: 16.0),
              // Display the conversion table only if an amount is entered
              if (_amountController.text.isNotEmpty)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Converted Values to ETB:',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 16.0),
                    Table(
                      border: TableBorder.all(color: Colors.black),
                      children: [
                        TableRow(
                          children: [
                            TableCell(child: Align(alignment:Alignment.center, child:  Text('Currency', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17)))),
                            TableCell(child: Align(alignment:Alignment.center, child:  Text('ETB', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17)))),
                          ],
                        ),
                        // Display conversion for each currency in currencyList
                        for (String currency in currencyList)
                          TableRow(
                            children: [
                              TableCell(
                                child: Align(
                                  alignment: Alignment.center,
                                  child: Text('$amount $currency'),
                                ),
                              ),
                              TableCell(
                                child: Align(
                                  alignment: Alignment.center,
                                  child: Text(
                                    '${((amount / exchangeRates![currency]!.toDouble()) * exchangeRates!['ETB']!.toDouble()).toStringAsFixed(3)} ETB',
                                    style: TextStyle(fontSize: 16.0),
                                  ),
                                ),
                              ),
                            ],
                          ),
                      ],
                    ),
                    SizedBox(height: 10),
                    Center(child: ElevatedButton(onPressed: () {}, child: Text("Save"))),
                  ],
                ),
              
            ],
          ),
        ),
      ),
    );
  }
}
