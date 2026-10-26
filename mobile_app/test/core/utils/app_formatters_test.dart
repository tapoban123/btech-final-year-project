import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_app/core/utils/app_formatters.dart';

void main() {
  group('AppFormatters Unit Tests', () {
    test('formatNumber formats integers and decimals with locale separators', () {
      expect(AppFormatters.formatNumber(0), '0');
      expect(AppFormatters.formatNumber(3), '3');
      expect(AppFormatters.formatNumber(1500), '1,500');
      expect(AppFormatters.formatNumber(1000000), '1,000,000');
    });

    test('formatPercent formats ratio and direct values with % suffix', () {
      expect(AppFormatters.formatPercent(0.94), '94%');
      expect(AppFormatters.formatPercent(0.89), '89%');
      expect(AppFormatters.formatPercent(0.82), '82%');
      expect(AppFormatters.formatPercent(94, isRatio: false), '94%');
    });

    test('formatDuration formats seconds into mm:ss using NumberFormat padding', () {
      expect(AppFormatters.formatDuration(0), '00:00');
      expect(AppFormatters.formatDuration(65), '01:05');
      expect(AppFormatters.formatDuration(165), '02:45');
      expect(AppFormatters.formatDuration(222), '03:42');
      expect(AppFormatters.formatDuration(738), '12:18');
      expect(AppFormatters.formatDuration(-10), '00:00');
    });

    test('formatDate formats DateTime into desired pattern using DateFormat', () {
      final date = DateTime(2026, 10, 14);
      expect(AppFormatters.formatDate(date), 'Oct 14');
      expect(AppFormatters.formatDate(date, pattern: 'yyyy-MM-dd'), '2026-10-14');
    });

    test('formatTime formats DateTime into 12-hour AM/PM format', () {
      final timeAm = DateTime(2026, 1, 1, 10, 24);
      expect(AppFormatters.formatTime(timeAm), '10:24 AM');

      final timePm = DateTime(2026, 1, 1, 14, 5);
      expect(AppFormatters.formatTime(timePm), '2:05 PM');
    });

    test('formatHeaderTimestamp formats header display string', () {
      final customTime = DateTime(2026, 1, 1, 10, 24);
      expect(
        AppFormatters.formatHeaderTimestamp(dateTime: customTime),
        'TODAY, 10:24 AM',
      );
      expect(
        AppFormatters.formatHeaderTimestamp(fallbackTime: '11:30 PM'),
        'TODAY, 11:30 PM',
      );
    });

    test('formatCountWithNoun handles singular, plural, and custom nouns', () {
      expect(AppFormatters.formatCountWithNoun(0, 'file'), '0 files');
      expect(AppFormatters.formatCountWithNoun(1, 'file'), '1 file');
      expect(AppFormatters.formatCountWithNoun(2, 'file'), '2 files');
      expect(AppFormatters.formatCountWithNoun(1500, 'file'), '1,500 files');
      expect(AppFormatters.formatCountWithNoun(1, 'match', 'matches'), '1 match');
      expect(AppFormatters.formatCountWithNoun(3, 'match', 'matches'), '3 matches');
    });

    test('formatFileSizeInMb formats megabytes to single decimal digit', () {
      expect(AppFormatters.formatFileSizeInMb(4.2), '4.2 MB');
      expect(AppFormatters.formatFileSizeInMb(1.8), '1.8 MB');
      expect(AppFormatters.formatFileSizeInMb(8.0), '8 MB');
    });
  });
}
