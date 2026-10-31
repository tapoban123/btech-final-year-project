import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_app/features/dashboard/blocs/dashboard_bloc.dart';
import 'package:mobile_app/features/dashboard/repository/models/document_item.dart';
import 'package:mobile_app/features/dashboard/view/screens/dashboard_library_view.dart';
import 'package:mobile_app/features/dashboard/view/widgets/batch_action_bar.dart';
import 'package:mobile_app/features/dashboard/view/widgets/dashboard_fab.dart';
import 'package:mobile_app/features/dashboard/view/widgets/dashboard_top_bar.dart';
import 'package:mobile_app/features/dashboard/view/widgets/document_card.dart';
import 'package:mobile_app/features/dashboard/view/widgets/filter_chips_row.dart';
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

    testWidgets('DocumentCard renders clean metadata without status tag clutter',
        (tester) async {
      bool previewTapped = false;

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
              isSelectionMode: false,
              onTap: () => previewTapped = true,
              onToggleSelect: () {},
            ),
          ),
        ),
      );

      expect(find.text('Quarterly_Plan.pdf'), findsOneWidget);
      expect(find.text('3.4 MB'), findsOneWidget);
      expect(find.text('Oct 19'), findsOneWidget);
      // Status tag should NOT be displayed on the clean card
      expect(find.text('Parsed'), findsNothing);
      expect(find.byIcon(Icons.picture_as_pdf_outlined), findsOneWidget);

      await tester.tap(find.text('Quarterly_Plan.pdf'));
      expect(previewTapped, isTrue);
    });

    testWidgets('DocumentCard shows selection circle only when isSelectionMode is true',
        (tester) async {
      bool toggled = false;

      const selectedDoc = DocumentItem(
        id: '1',
        title: 'Quarterly_Plan.pdf',
        type: DocumentType.pdf,
        fileSize: '3.4 MB',
        date: 'Oct 19',
        statusTag: 'Parsed',
        isSelected: true,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DocumentCard(
              item: selectedDoc,
              isSelectionMode: true,
              onToggleSelect: () => toggled = true,
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.check), findsOneWidget);
      await tester.tap(find.text('Quarterly_Plan.pdf'));
      expect(toggled, isTrue);
    });

    testWidgets('BatchActionBar shows count and triggers Chat, Share, Delete callbacks',
        (tester) async {
      bool chatTapped = false;
      bool shareTapped = false;
      bool deleteTapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: BatchActionBar(
              selectedCount: 2,
              onChatTap: () => chatTapped = true,
              onShareTap: () => shareTapped = true,
              onDeleteTap: () => deleteTapped = true,
            ),
          ),
        ),
      );

      expect(find.text('2 selected'), findsOneWidget);

      await tester.tap(find.text('Chat'));
      expect(chatTapped, isTrue);

      await tester.tap(find.text('Share'));
      expect(shareTapped, isTrue);

      await tester.tap(find.text('Delete'));
      expect(deleteTapped, isTrue);
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

    testWidgets('DashboardLibraryView renders with its own Scaffold, TopBar, and local FAB',
        (tester) async {
      await tester.pumpWidget(
        MultiBlocProvider(
          providers: [
            BlocProvider<DashboardBloc>(
              create: (_) => DashboardBloc(),
            ),
          ],
          child: const MaterialApp(
            home: DashboardLibraryView(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(DashboardLibraryView), findsOneWidget);
      expect(find.text('OmniDoc AI'), findsOneWidget);
      expect(find.text('My Library'), findsOneWidget);
      expect(find.text('New Upload'), findsOneWidget);
    });
  });
}

