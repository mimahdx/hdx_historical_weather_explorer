import 'package:intl/intl.dart';

class DateFormatUtils {
  static String formatDate(DateTime date) {
    return DateFormat('MMMM d, y').format(date);
  }
}
