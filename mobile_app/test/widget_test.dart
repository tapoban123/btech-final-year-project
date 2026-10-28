import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_app/features/chat/view/screens/chat_screen.dart';
import 'package:mobile_app/features/upload/view/screens/upload_screen.dart';
import 'package:mobile_app/main.dart';

void main() {
  testWidgets('Dashboard loads and displays OmniDoc header and library',
      (WidgetTester tester) async {
    await tester.pumpWidget(const OmniDocApp());
    await tester.pump(const Duration(milliseconds: 500));
    await tester.pumpAndSettle();

    // Verify OmniDoc AI brand and absence of HUB tag
    expect(find.text('OmniDoc AI'), findsOneWidget);
    expect(find.text('HUB'), findsNothing);

    // Verify All Entities section categories updated to All, Documents, Recordings, Images
    expect(find.text('All'), findsOneWidget);
    expect(find.text('Documents'), findsOneWidget);
    expect(find.text('Recordings'), findsOneWidget);
    expect(find.text('Images'), findsOneWidget);
    expect(find.text('All Entities'), findsNothing);

    // Verify metrics section (number docs and recordings hours) removed
    expect(find.text('Synthesized'), findsNothing);
    expect(find.text('Audio Notes'), findsNothing);

    // Verify My Library header
    expect(find.text('My Library'), findsOneWidget);

    // Verify Bottom Navigation: Upload tab removed, Search and Chat present
    expect(find.text('Home'), findsOneWidget);
    expect(find.text('Search'), findsOneWidget);
    expect(find.text('Chat'), findsOneWidget);
    expect(find.text('Upload'), findsNothing);
  });

  testWidgets(
      'Tapping top search bar navigates to Semantic Search view via IndexedStack',
      (WidgetTester tester) async {
    await tester.pumpWidget(const OmniDocApp());
    await tester.pump(const Duration(milliseconds: 500));
    await tester.pumpAndSettle();

    final searchBarPlaceholder =
        find.text('Search across all documents, images, and voice...');
    expect(searchBarPlaceholder, findsOneWidget);
    await tester.tap(searchBarPlaceholder);
    await tester.pumpAndSettle();

    // Verify switched to Semantic Search screen and search scope is removed
    expect(find.text('Semantic Search'), findsOneWidget);
    expect(find.text('Search Scope:'), findsNothing);
    expect(find.text('All Files'), findsNothing);
  });

  testWidgets(
      'Tapping floating upload button navigates to Upload & Voice Ingestion screen',
      (WidgetTester tester) async {
    await tester.pumpWidget(const OmniDocApp());
    await tester.pump(const Duration(milliseconds: 500));
    await tester.pumpAndSettle();

    // Tap on floating action button (+ New Upload)
    final fab = find.text('New Upload');
    expect(fab, findsOneWidget);
    await tester.tap(fab);
    await tester.pumpAndSettle();

    // Verify UploadScreen is displayed
    expect(find.byType(UploadScreen), findsOneWidget);
    expect(find.text('Upload Documents'), findsOneWidget);
    expect(find.text('Upload Files'), findsOneWidget);
    expect(find.text('Record Voice Note'), findsOneWidget);
    expect(find.text('Recent Uploads'), findsOneWidget);

    // Tap on Record Voice Note to reveal the condition-based VoiceRecordingCard
    await tester.tap(find.text('Record Voice Note'));
    await tester.pumpAndSettle();
    expect(find.text('Voice Note'), findsOneWidget);
    expect(find.text('Tap mic to speak'), findsOneWidget);
    expect(find.byKey(const Key('voice_recorder_delete_button')), findsOneWidget);
    expect(find.byKey(const Key('voice_recorder_record_button')), findsOneWidget);
    expect(find.byKey(const Key('voice_recorder_done_button')), findsOneWidget);
    expect(find.text('Save & Ingest'), findsNothing);

    // Tap back to return to Dashboard
    await tester.tap(find.byIcon(Icons.arrow_back));
    await tester.pumpAndSettle();

    expect(find.text('My Library'), findsOneWidget);
  });

  testWidgets('Tapping Chat tab navigates to OmniDoc RAG ChatScreen',
      (WidgetTester tester) async {
    await tester.pumpWidget(const OmniDocApp());
    await tester.pump(const Duration(milliseconds: 500));
    await tester.pumpAndSettle();

    // Tap on the Chat tab in bottom nav
    final chatTab = find.text('Chat');
    expect(chatTab, findsOneWidget);
    await tester.tap(chatTab);
    await tester.pumpAndSettle();

    // Verify Chat Screen Header elements
    expect(find.text('Manage'), findsOneWidget);

    // Verify Active RAG Context Strip
    expect(find.text('3 Active Contexts'), findsOneWidget);
    expect(find.byIcon(Icons.tune), findsOneWidget);

    // Verify Prompt Chips & Input
    expect(find.text('Summarize these docs'), findsOneWidget);
    expect(
      find.text('Ask questions about the selection...'),
      findsOneWidget,
    );
    expect(find.byIcon(Icons.mic), findsOneWidget);

    // Send a message using the ChatScreen input
    final chatInput = find.descendant(
      of: find.byType(ChatScreen),
      matching: find.byType(TextField),
    );
    await tester.enterText(chatInput, 'What are the main findings?');
    await tester.tap(find.descendant(
      of: find.byType(ChatScreen),
      matching: find.byIcon(Icons.arrow_upward),
    ));
    await tester.pumpAndSettle();

    // Verify AI response arrives
    expect(
      find.byWidgetPredicate(
        (w) => w is RichText && w.text.toPlainText().contains('Key Finding'),
      ),
      findsOneWidget,
    );

    // Tap Home tab on bottom nav to switch IndexedStack back
    await tester.tap(find.text('Home'));
    await tester.pumpAndSettle();

    // Verify returned to Dashboard
    expect(find.text('My Library'), findsOneWidget);
  });

  testWidgets(
      'Tapping Search tab switches to Semantic Search view via IndexedStack',
      (WidgetTester tester) async {
    await tester.pumpWidget(const OmniDocApp());
    await tester.pump(const Duration(milliseconds: 500));
    await tester.pumpAndSettle();

    // Tap on Search tab in bottom nav
    final searchTab = find.text('Search');
    expect(searchTab, findsOneWidget);
    await tester.tap(searchTab);
    await tester.pumpAndSettle();

    // Verify Semantic Search elements
    expect(find.text('Semantic Search'), findsOneWidget);
    expect(find.text('Search Scope:'), findsNothing);
    expect(find.text('Search Results'), findsOneWidget);
    expect(find.text('3 semantic matches found'), findsOneWidget);
    expect(find.text('Q3_Financial_Analysis_Report.pdf'), findsOneWidget);

    // Tap View in Chat to switch to Chat tab
    final viewInChatButtons = find.text('View in Chat');
    expect(viewInChatButtons, findsAtLeastNWidgets(1));
    await tester.tap(viewInChatButtons.first);
    await tester.pumpAndSettle();

    // Verify switched to ChatScreen
    expect(find.text('3 Active Contexts'), findsOneWidget);
  });
}
