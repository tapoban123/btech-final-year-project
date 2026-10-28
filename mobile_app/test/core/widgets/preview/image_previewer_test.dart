import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_app/core/widgets/preview/image_previewer.dart';

void main() {
  group('ImagePreviewer Widget Tests', () {
    testWidgets('renders fallback when filePath is null', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ImagePreviewer(
              filePath: null,
              title: 'Diagram.png',
            ),
          ),
        ),
      );

      expect(find.text('Diagram.png'), findsOneWidget);
      expect(
        find.text('Image preview is unavailable (file path not found)'),
        findsOneWidget,
      );
      expect(find.byIcon(Icons.image_outlined), findsOneWidget);
    });

    testWidgets('renders fallback when file does not exist on disk',
        (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ImagePreviewer(
              filePath: '/non/existent/path/diagram.png',
              title: 'Diagram.png',
            ),
          ),
        ),
      );

      expect(find.text('Diagram.png'), findsOneWidget);
      expect(
        find.text('Image preview is unavailable (file path not found)'),
        findsOneWidget,
      );
    });

    testWidgets('renders InteractiveViewer when file exists', (tester) async {
      // Create a temporary file
      final tempDir = Directory.systemTemp.createTempSync('img_test');
      final tempFile = File('${tempDir.path}/test_image.png');
      // Minimal valid 1x1 png bytes
      tempFile.writeAsBytesSync([
        0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A, 0x00, 0x00, 0x00, 0x0D,
        0x49, 0x48, 0x44, 0x52, 0x00, 0x00, 0x00, 0x01, 0x00, 0x00, 0x00, 0x01,
        0x08, 0x06, 0x00, 0x00, 0x00, 0x1F, 0x15, 0xC4, 0x89, 0x00, 0x00, 0x00,
        0x0A, 0x49, 0x44, 0x41, 0x54, 0x78, 0x9C, 0x63, 0x00, 0x01, 0x00, 0x00,
        0x05, 0x00, 0x01, 0x0D, 0x0A, 0x2D, 0xB4, 0x00, 0x00, 0x00, 0x00, 0x49,
        0x45, 0x4E, 0x44, 0xAE, 0x42, 0x60, 0x82,
      ]);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ImagePreviewer(
              filePath: tempFile.path,
              title: 'test_image.png',
            ),
          ),
        ),
      );
      await tester.pump();

      expect(find.byType(InteractiveViewer), findsOneWidget);
      expect(find.byType(Image), findsOneWidget);

      tempDir.deleteSync(recursive: true);
    });
  });
}
