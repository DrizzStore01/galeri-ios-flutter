import 'package:intl/intl.dart';

class DateFormatter {
  static String formatGroupDate(DateTime date, {String locale = 'id_ID'}) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final dateToCheck = DateTime(date.year, date.month, date.day);

    if (dateToCheck == today) {
      return locale == 'id_ID' ? 'Hari Ini' : 'Today';
    } else if (dateToCheck == yesterday) {
      return locale == 'id_ID' ? 'Kemarin' : 'Yesterday';
    } else if (now.difference(dateToCheck).inDays < 7) {
      return locale == 'id_ID' ? 'Minggu Ini' : 'This Week';
    } else if (now.year == date.year && now.month == date.month) {
      return locale == 'id_ID' ? 'Bulan Ini' : 'This Month';
    } else {
      return DateFormat('MMMM yyyy', locale).format(date);
    }
  }

  static String formatDetailedDate(DateTime date, {String locale = 'id_ID'}) {
    return DateFormat('dd MMMM yyyy, HH:mm', locale).format(date);
  }
}
