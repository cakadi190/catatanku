import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';

Future<String> dateFormatter({
  DateTime? date,
  required String format,
  String locale = 'id_ID',
}) async {
  try {
    await initializeDateFormatting(locale);

    final selectedDate = date ?? DateTime.now();

    return DateFormat(format, locale).format(selectedDate);
  } catch (e) {
    throw Exception('Error formatting date: $e');
  }
}

String formatDate(DateTime date, {String format = 'EEEE, dd MMMM yyyy'}) {
  return DateFormat(format, 'id_ID').format(date);
}