import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_app/core/theme/app_theme.dart';
import 'package:mobile_app/features/dashboard/repository/models/document_item.dart';
import 'package:mobile_app/features/dashboard/view/widgets/filter_chips_row.dart';
import 'package:mobile_app/features/search/view/screens/search_screen.dart';

void main() {
  group('SearchScreen Content Type Filter Tests', () {
    Widget createWidgetUnderTest({
      ValueChanged<int>? onNavigateToTab,
      ValueChanged<DocumentItem>? onOpenViewer,
      String? initialErrorMessage,
      SearchSelectionModeCallback? onSelectionModeChanged,
    }) {
      return MaterialApp(
        theme: AppTheme.lightTheme,
        home: SearchScreen(
          onNavigateToTab: onNavigateToTab,
          onOpenViewer: onOpenViewer,
          initialErrorMessage: initialErrorMessage,
          onSelectionModeChanged: onSelectionModeChanged,
        ),
      );
    }

    testWidgets('renders FilterChipsRow with content type options',
        (tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      expect(find.byType(FilterChipsRow), findsOneWidget);
      expect(find.text('All'), findsOneWidget);
      expect(find.text('Documents'), findsOneWidget);
      expect(find.text('Recordings'), findsOneWidget);
      expect(find.text('Results'), findsOneWidget);
      expect(find.text('3'), findsOneWidget);
      expect(find.text('semantic matches found'), findsNothing);
    });

    testWidgets('filtering by Documents shows only PDF report and updates match count',
        (tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      // Tap Documents filter chip
      await tester.tap(find.text('Documents'));
      await tester.pumpAndSettle();

      expect(find.text('1'), findsOneWidget);
      expect(find.text('Q3_Financial_Analysis_Report.pdf'), findsOneWidget);
      expect(find.text('Board_Meeting_Memo_Dictation.wav'), findsNothing);
      expect(find.text('Executive_Strategy_Whiteboard.png'), findsNothing);
    });

    testWidgets('filtering by Recordings shows only Audio memo',
        (tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      // Tap Recordings filter chip
      await tester.tap(find.text('Recordings'));
      await tester.pumpAndSettle();

      expect(find.text('1'), findsOneWidget);
      expect(find.text('Board_Meeting_Memo_Dictation.wav'), findsOneWidget);
      expect(find.text('Q3_Financial_Analysis_Report.pdf'), findsNothing);
      expect(find.text('Executive_Strategy_Whiteboard.png'), findsNothing);
    });

    testWidgets('filtering by Images shows only Whiteboard diagram',
        (tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      // Scroll to and tap Images filter chip
      await tester.ensureVisible(find.text('Images'));
      await tester.tap(find.text('Images'));
      await tester.pumpAndSettle();

      expect(find.text('1'), findsOneWidget);
      expect(find.text('Executive_Strategy_Whiteboard.png'), findsOneWidget);
      expect(find.text('Q3_Financial_Analysis_Report.pdf'), findsNothing);
      expect(find.text('Board_Meeting_Memo_Dictation.wav'), findsNothing);
    });

    testWidgets('switching back to All restores all 3 search results',
        (tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      // Select Documents first
      await tester.tap(find.text('Documents'));
      await tester.pumpAndSettle();
      expect(find.text('1'), findsOneWidget);

      // Select All
      await tester.tap(find.text('All'));
      await tester.pumpAndSettle();
      expect(find.text('3'), findsOneWidget);
      expect(find.text('Q3_Financial_Analysis_Report.pdf'), findsOneWidget);
      expect(find.text('Board_Meeting_Memo_Dictation.wav'), findsOneWidget);

      // Drag ListView down to verify the 3rd card
      await tester.drag(find.byType(ListView), const Offset(0, -300));
      await tester.pumpAndSettle();
      expect(find.text('Executive_Strategy_Whiteboard.png'), findsOneWidget);
    });

    testWidgets('clearing search query shows static empty state widget',
        (tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      // Tap clear query button
      await tester.tap(find.byIcon(Icons.cancel));
      await tester.pumpAndSettle();

      expect(find.text('No search query entered'), findsOneWidget);
      expect(find.text('0'), findsOneWidget);
      expect(find.byIcon(Icons.search_off), findsOneWidget);
    });

    testWidgets('renders clean header without top filter icon', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      expect(find.text('Semantic Search'), findsOneWidget);
      expect(find.byIcon(Icons.saved_search), findsOneWidget);
      expect(find.byIcon(Icons.tune), findsNothing);
    });

    testWidgets(
        'renders DocumentCard with more_vert options (Chat, Share, Delete) and navigates to chat',
        (tester) async {
      int? navigatedTab;
      await tester.pumpWidget(createWidgetUnderTest(
        onNavigateToTab: (tab) => navigatedTab = tab,
      ));
      await tester.pumpAndSettle();

      // Ensure no debug OCR prefix or redundant metadata labels exist
      expect(find.textContaining('[OCR Detected Text]'), findsNothing);
      expect(find.textContaining('Page 14'), findsNothing);
      expect(find.textContaining('Audio Segment'), findsNothing);
      expect(find.textContaining('Visual Section'), findsNothing);

      // Verify DocumentCard renders title and similarity match badge
      expect(find.text('Q3_Financial_Analysis_Report.pdf'), findsOneWidget);
      expect(find.text('94% match'), findsOneWidget);

      // Tap more options on first search card
      final moreButtons = find.byIcon(Icons.more_vert);
      expect(moreButtons, findsAtLeastNWidgets(1));
      await tester.tap(moreButtons.first);
      await tester.pumpAndSettle();

      // Verify options modal contains Chat, Share, Delete
      expect(find.text('Chat with this Document'), findsOneWidget);
      expect(find.text('Share Document'), findsOneWidget);
      expect(find.text('Delete Document'), findsOneWidget);

      // Tap Chat with this Document
      await tester.tap(find.text('Chat with this Document'));
      await tester.pumpAndSettle();

      expect(navigatedTab, equals(2));
    });

    testWidgets(
        'tapping document card triggers onOpenViewer dedicated screen hook',
        (tester) async {
      DocumentItem? openedDoc;
      await tester.pumpWidget(createWidgetUnderTest(
        onOpenViewer: (doc) => openedDoc = doc,
      ));
      await tester.pumpAndSettle();

      // Tap first card
      await tester.tap(find.text('Q3_Financial_Analysis_Report.pdf'));
      await tester.pumpAndSettle();

      expect(openedDoc, isNotNull);
      expect(openedDoc!.title, equals('Q3_Financial_Analysis_Report.pdf'));
    });

    testWidgets(
        'doc widget displays inline metadata row with match text badge',
        (tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      expect(find.text('94% match'), findsOneWidget);
      expect(find.text('2.4 MB'), findsOneWidget);
    });

    testWidgets(
        'multi-selection mode in search allows selecting multiple docs and triggers batch chat',
        (tester) async {
      int? navigatedTab;
      await tester.pumpWidget(createWidgetUnderTest(
        onNavigateToTab: (tab) => navigatedTab = tab,
      ));
      await tester.pumpAndSettle();

      // Tap Select toggle in header
      await tester.tap(find.text('Select'));
      await tester.pumpAndSettle();

      // Header should show Cancel and cards show checkboxes
      expect(find.text('Cancel'), findsOneWidget);

      // Select first document
      await tester.tap(find.text('Q3_Financial_Analysis_Report.pdf'));
      await tester.pumpAndSettle();

      // Select second document
      await tester.tap(find.text('Board_Meeting_Memo_Dictation.wav'));
      await tester.pumpAndSettle();

      // Verify BatchActionBar shows 2 selected
      expect(find.text('2 selected'), findsOneWidget);
      expect(find.text('Chat'), findsOneWidget);
      expect(find.text('Share'), findsOneWidget);
      expect(find.text('Delete'), findsOneWidget);

      // Tap Batch Chat
      await tester.tap(find.text('Chat'));
      await tester.pumpAndSettle();

      expect(navigatedTab, equals(2));
    });

    testWidgets('canceling search selection clears selected items',
        (tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      // Enter selection mode
      await tester.tap(find.text('Select'));
      await tester.pumpAndSettle();

      // Select item
      await tester.tap(find.text('Q3_Financial_Analysis_Report.pdf'));
      await tester.pumpAndSettle();
      expect(find.text('1 selected'), findsOneWidget);

      // Tap Cancel in header
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();

      expect(find.text('Select'), findsOneWidget);
      expect(find.text('1 selected'), findsNothing);
    });

    testWidgets(
        'renders dedicated error display when error occurs and recovers on Retry',
        (tester) async {
      await tester.pumpWidget(createWidgetUnderTest(
        initialErrorMessage: 'Vector embedding service connection timed out',
      ));
      await tester.pumpAndSettle();

      expect(find.text('Search Service Unavailable'), findsOneWidget);
      expect(
        find.text('Vector embedding service connection timed out'),
        findsOneWidget,
      );
      expect(find.byIcon(Icons.cloud_off_rounded), findsOneWidget);
      expect(find.text('Retry Search'), findsOneWidget);
      expect(find.text('Search error'), findsOneWidget);

      // Tap Retry Search
      await tester.tap(find.text('Retry Search'));
      await tester.pumpAndSettle();

      // Error should be dismissed and search results rendered
      expect(find.text('Search Service Unavailable'), findsNothing);
      expect(find.text('3'), findsOneWidget);
    });

    testWidgets(
        'tapping quick suggestion chip on empty query fills query and shows results',
        (tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      // Clear query to reveal quick suggestions
      await tester.tap(find.byIcon(Icons.cancel));
      await tester.pumpAndSettle();

      expect(find.text('Try quick suggestions:'), findsOneWidget);
      expect(find.text('financial analysis'), findsOneWidget);

      // Tap suggestion chip
      await tester.tap(find.text('financial analysis'));
      await tester.pumpAndSettle();

      // Verify query is updated
      expect(find.text('financial analysis'), findsAtLeastNWidgets(1));
    });

    testWidgets(
        'displays dedicated no results display and handles Clear query action',
        (tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      // Enter a query that yields no matches
      await tester.enterText(
        find.byType(TextField),
        'nonexistent query with zero matches',
      );
      await tester.pumpAndSettle();

      expect(find.text('No results found'), findsOneWidget);
      expect(find.byIcon(Icons.find_in_page_outlined), findsOneWidget);
      expect(find.text('Clear query'), findsOneWidget);

      // Tap Clear query button
      await tester.tap(find.text('Clear query'));
      await tester.pumpAndSettle();

      expect(find.text('No search query entered'), findsOneWidget);
    });
  });
}
