import 'package:intl/intl.dart';

/// Centralized internationalization formatting utility for dates, times, and numbers.
/// Backed strictly by the `intl` package to ensure consistent formatting across OmniDoc AI.
class AppFormatters {
  AppFormatters._();

  /// Formats an integer or double into a localized decimal string (e.g. 1000 -> "1,000", 3 -> "3").
  static String formatNumber(num number) {
    return NumberFormat.decimalPattern().format(number);
  }

  /// Formats a number as a percentage string (e.g. 0.94 -> "94%" when [isRatio] is true, or 94 -> "94%").
  static String formatPercent(num value, {bool isRatio = true}) {
    if (isRatio) {
      return NumberFormat.percentPattern().format(value);
    } else {
      return '${NumberFormat.decimalPattern().format(value)}%';
    }
  }

  /// Formats seconds into a padded "mm:ss" duration string using [NumberFormat] (e.g. 165 -> "02:45").
  static String formatDuration(int totalSeconds) {
    if (totalSeconds < 0) totalSeconds = 0;
    final minutes = totalSeconds ~/ 60;
    final seconds = totalSeconds % 60;
    final formatter = NumberFormat('00');
    return '${formatter.format(minutes)}:${formatter.format(seconds)}';
  }

  /// Formats a [DateTime] to a standard short date (e.g. "Oct 14").
  static String formatDate(DateTime date, {String pattern = 'MMM dd'}) {
    return DateFormat(pattern).format(date);
  }

  /// Formats a [DateTime] to 12-hour format with AM/PM (e.g. "10:24 AM").
  static String formatTime(DateTime time) {
    return DateFormat.jm()
        .format(time)
        .replaceAll('\u202f', ' ')
        .replaceAll('\u00a0', ' ');
  }

  /// Formats a header timestamp for conversation views (e.g. "TODAY, 10:24 AM").
  static String formatHeaderTimestamp({DateTime? dateTime, String? fallbackTime}) {
    final dt = dateTime ?? DateTime.now();
    final time = fallbackTime ?? formatTime(dt);
    return 'TODAY, ${time.toUpperCase()}';
  }

  /// Formats a count with its singular or plural noun using [NumberFormat.decimalPattern]
  /// (e.g. 1, 'file' -> "1 file"; 2, 'file' -> "2 files"; 1000, 'file' -> "1,000 files").
  static String formatCountWithNoun(int count, String singular, [String? plural]) {
    final formattedNumber = NumberFormat.decimalPattern().format(count);
    final noun = count == 1 ? singular : (plural ?? '${singular}s');
    return '$formattedNumber $noun';
  }

  /// Formats file size in MB or KB using [NumberFormat].
  static String formatFileSizeInMb(double megabytes) {
    return '${NumberFormat('0.#').format(megabytes)} MB';
  }
}
