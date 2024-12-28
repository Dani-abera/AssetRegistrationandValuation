import 'dart:convert';
import 'package:http/http.dart' as http;

class FetchExchangeRate {
  static Future<Map<String, dynamic>?> getExchangeRates() async {
    const String apiUrl = 'https://open.er-api.com/v6/latest/USD';

    try {
      final response = await http.get(Uri.parse(apiUrl));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['rates'];
      } else {
        print('Failed to load exchange rates. Status code: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('Error fetching data: $e');
      return null;
    }
  }
}
