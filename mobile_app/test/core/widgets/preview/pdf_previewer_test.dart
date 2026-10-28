import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_app/core/widgets/preview/pdf_previewer.dart';

void main() {
  group('PdfPreviewer Widget Tests', () {
    testWidgets('renders fallback when filePath is null', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: PdfPreviewer(
              filePath: null,
              title: 'Doc.pdf',
            ),
          ),
        ),
      );
      await tester.pump();

      expect(find.text('Doc.pdf'), findsOneWidget);
      expect(find.text('PDF file path not found'), findsOneWidget);
      expect(find.byIcon(Icons.picture_as_pdf_outlined), findsOneWidget);
    });

    testWidgets('renders fallback when file does not exist', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: PdfPreviewer(
              filePath: '/invalid/file/path.pdf',
              title: 'Quarterly_Report.pdf',
            ),
          ),
        ),
      );
      await tester.pump();

      expect(find.text('Quarterly_Report.pdf'), findsOneWidget);
      expect(find.text('PDF file path not found'), findsOneWidget);
    });
  });
}
