import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_app/features/dashboard/repository/models/document_item.dart';
import 'package:mobile_app/features/dashboard/view/widgets/batch_action_bar.dart';
import 'package:mobile_app/features/dashboard/view/widgets/dashboard_fab.dart';
import 'package:mobile_app/features/dashboard/view/widgets/dashboard_top_bar.dart';
import 'package:mobile_app/features/dashboard/view/widgets/document_card.dart';
import 'package:mobile_app/features/dashboard/view/widgets/filter_chips_row.dart';
import 'package:mobile_app/features/dashboard/view/widgets/metrics_bento_strip.dart';
import 'package:mobile_app/features/dashboard/view/widgets/multimodal_search_bar.dart';

void main() {
  group('Dashboard Component Widget Tests', () {
    testWidgets('DashboardTopBar renders branding, HUB badge, and avatar',
        (tester) async {
      bool profileTapped = false;
      bool optionsTapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            appBar: DashboardTopBar(
              onProfileTap: () => profileTapped = true,
              onOptionsTap: () => optionsTapped = true,
            ),
          ),
        ),
      );

      expect(find.text('OmniDoc AI'), findsOneWidget);
      expect(find.text('HUB'), findsNothing);
      expect(find.text('ED'), findsOneWidget);
      expect(find.byIcon(Icons.more_vert), findsOneWidget);

      await tester.tap(find.text('ED'));
      expect(profileTapped, isTrue);

      await tester.tap(find.byIcon(Icons.more_vert));
      expect(optionsTapped, isTrue);
    });

    testWidgets('MultimodalSearchBar renders as clickable button and triggers tap',
        (tester) async {
      bool tapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MultimodalSearchBar(onTap: () => tapped = true),
          ),
        ),
      );

      expect(
        find.text('Search across all documents, images, and voice...'),
        findsOneWidget,
      );
      expect(find.byIcon(Icons.search), findsOneWidget);

      await tester.tap(
        find.text('Search across all documents, images, and voice...'),
      );
      expect(tapped, isTrue);
    });

    testWidgets('MetricsBentoStrip displays metrics correctly', (tester) async {
      const testMetrics = DashboardMetrics(
        synthesizedDocsCount: 30,
        audioNotesHours: 5.5,
        confidencePercentage: 99.5,
      );

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: MetricsBentoStrip(metrics: testMetrics),
          ),
        ),
      );

      expect(find.text('Synthesized'), findsOneWidget);
      expect(find.text('30 Docs'), findsOneWidget);
      expect(find.text('Audio Notes'), findsOneWidget);
      expect(find.text('5.5 Hrs'), findsOneWidget);
      expect(find.text('Confidence'), findsOneWidget);
      expect(find.text('99.5%'), findsOneWidget);
    });

    testWidgets('FilterChipsRow highlights active chip and triggers callback',
        (tester) async {
      DocumentFilterCategory selected = DocumentFilterCategory.all;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FilterChipsRow(
              selectedCategory: selected,
              onSelected: (cat) => selected = cat,
            ),
          ),
        ),
      );

      expect(find.text('All'), findsOneWidget);
      expect(find.text('Documents'), findsOneWidget);
      expect(find.text('Recordings'), findsOneWidget);
      expect(find.text('Images'), findsOneWidget);

      await tester.tap(find.text('Documents'));
      expect(selected, DocumentFilterCategory.reports);
    });

    testWidgets('DocumentCard renders unselected and selected states',
        (tester) async {
      bool toggled = false;

      const unselectedDoc = DocumentItem(
        id: '1',
        title: 'Quarterly_Plan.pdf',
        type: DocumentType.pdf,
        fileSize: '3.4 MB',
        date: 'Oct 19',
        statusTag: 'Parsed',
        isSelected: false,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DocumentCard(
              item: unselectedDoc,
              onToggleSelect: () => toggled = true,
            ),
          ),
        ),
      );

      expect(find.text('Quarterly_Plan.pdf'), findsOneWidget);
      expect(find.text('Parsed'), findsOneWidget);
      expect(find.byIcon(Icons.picture_as_pdf_outlined), findsOneWidget);

      await tester.tap(find.text('Quarterly_Plan.pdf'));
      expect(toggled, isTrue);
    });

    testWidgets('BatchActionBar shows count and triggers action callbacks',
        (tester) async {
      bool queryTapped = false;
      bool exportTapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: BatchActionBar(
              selectedCount: 2,
              onQueryTap: () => queryTapped = true,
              onExportTap: () => exportTapped = true,
            ),
          ),
        ),
      );

      expect(find.text('2 files selected'), findsOneWidget);

      await tester.tap(find.text('Query'));
      expect(queryTapped, isTrue);

      await tester.tap(find.text('Export'));
      expect(exportTapped, isTrue);
    });

    testWidgets('DashboardFab renders and responds to tap', (tester) async {
      bool pressed = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DashboardFab(onPressed: () => pressed = true),
          ),
        ),
      );

      expect(find.text('New Upload'), findsOneWidget);
      expect(find.byIcon(Icons.add), findsOneWidget);

      await tester.tap(find.text('New Upload'));
      expect(pressed, isTrue);
    });
  });
}
