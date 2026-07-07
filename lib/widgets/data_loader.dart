import 'package:flutter/services.dart' show rootBundle;
import 'package:csv/csv.dart';

Future<List<List<dynamic>>> loadCsvData() async {
  try {
    final rawData = await rootBundle.loadString(
      'assets/data/respuestas_guardadas.csv',
    );
    List<List<dynamic>> listData = const CsvToListConverter().convert(rawData);
    return listData;
  } catch (e) {
    print("❌ Error al leer el CSV: $e");
    return [];
  }
}
