import 'package:intl/intl.dart';

class DateHelpers {
  static final DateFormat _dayMonthYearFormat = DateFormat('MMM d, yyyy');
  static final DateFormat _monthYearFormat = DateFormat('MMMM yyyy');
  static final DateFormat _shortDateFormat = DateFormat('MMM d');
  static final DateFormat _timeFormat = DateFormat('h:mm a');

  static String formatFull(DateTime date) {
    return _dayMonthYearFormat.format(date);
  }

  static String formatMonthYear(DateTime date) {
    return _monthYearFormat.format(date);
  }

  static String formatShort(DateTime date) {
    return _shortDateFormat.format(date);
  }

  static String formatTime(DateTime date) {
    return _timeFormat.format(date);
  }

  static String formatRelative(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final checkDate = DateTime(date.year, date.month, date.day);

    if (checkDate == today) {
      return 'Today';
    } else if (checkDate == yesterday) {
      return 'Yesterday';
    } else if (now.difference(date).inDays < 7 && now.weekday > date.weekday) {
      return DateFormat('EEEE').format(date); // e.g. "Monday"
    } else {
      return _dayMonthYearFormat.format(date);
    }
  }

  static bool isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  static bool isSameMonth(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month;
  }

  static bool isThisWeek(DateTime date) {
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    final start = DateTime(startOfWeek.year, startOfWeek.month, startOfWeek.day);
    final end = start.add(const Duration(days: 7));
    return date.isAfter(start.subtract(const Duration(seconds: 1))) && date.isBefore(end);
  }

  static bool isThisMonth(DateTime date) {
    final now = DateTime.now();
    return isSameMonth(now, date);
  }

  static bool isThisYear(DateTime date) {
    final now = DateTime.now();
    return now.year == date.year;
  }
}
