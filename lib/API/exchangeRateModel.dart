class ExchangeRateModel {
  final DateTime date;
  final Map<String, double> rates;

  ExchangeRateModel({
    required this.date,
    required this.rates,
  });

  Map<String, dynamic> toMap() {
    return {
      'date': date,
      'rates': rates,
    };
  }

  factory ExchangeRateModel.fromMap(Map<String, dynamic> map) {
    return ExchangeRateModel(
      date: map['date']?.toDate() ?? DateTime.now(),
      rates: Map<String, double>.from(map['rates'] ?? {}),
    );
  }
}
