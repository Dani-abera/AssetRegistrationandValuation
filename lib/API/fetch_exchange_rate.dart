import 'dart:convert';
import 'package:http/http.dart' as http;

class FetchExchangeRate {
  static Future<Map<String, double>?> getExchangeRates() async {
    const String apiUrl = 'https://open.er-api.com/v6/latest/USD';

    try {
      final response = await http.get(Uri.parse(apiUrl));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        Map<String, dynamic> rawRates = data['rates'];

        // Convert all values to double
        Map<String, double> convertedRates = {};
        rawRates.forEach((key, value) {
          if (value is int) {
            convertedRates[key] = value.toDouble();
          } else if (value is double) {
            convertedRates[key] = value;
          } else {
            convertedRates[key] = double.tryParse(value.toString()) ?? 0.0;
          }
        });

        return convertedRates;
      } else {
        print(
            'Failed to load exchange rates. Status code: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('Error fetching data: $e');
      return null;
    }
  }
}
