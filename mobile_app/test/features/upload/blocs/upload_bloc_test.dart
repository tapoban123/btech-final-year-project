import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:mobile_app/features/dashboard/repository/models/document_item.dart';
import 'package:mobile_app/features/upload/blocs/upload_bloc.dart';
import 'package:mobile_app/features/upload/blocs/upload_event.dart';
import 'package:mobile_app/features/upload/blocs/upload_state.dart';
import 'package:mobile_app/features/upload/repository/models/upload_item.dart';
import 'package:mobile_app/features/upload/repository/upload_repository.dart';

class MockUploadRepository extends Mock implements IUploadRepository {}

void main() {
  setUpAll(() {
    registerFallbackValue(DocumentType.pdf);
  });

  late MockUploadRepository mockRepository;

  final sampleUploads = [
    const UploadItem(
      id: 'up_1',
      title: 'Contract.pdf',
      type: DocumentType.pdf,
      stageDescription: 'Processing',
      status: UploadProcessingStatus.processing,
    ),
  ];

  setUp(() {
    mockRepository = MockUploadRepository();
  });

  group('UploadBloc Tests', () {
    test('initial state defaults', () {
      final bloc = UploadBloc(repository: mockRepository);
      expect(bloc.state.status, UploadScreenStatus.initial);
      expect(bloc.state.recentUploads, isEmpty);
      expect(bloc.state.isRecording, isFalse);
      expect(bloc.state.recordingDurationSeconds, 0);
      expect(bloc.state.formattedDuration, '00:00');
    });

    blocTest<UploadBloc, UploadState>(
      'emits [loading, success] when LoadUploadData succeeds',
      build: () {
        when(() => mockRepository.getRecentUploads())
            .thenAnswer((_) async => sampleUploads);
        return UploadBloc(repository: mockRepository);
      },
      act: (bloc) => bloc.add(const LoadUploadData()),
      expect: () => [
        const UploadState(status: UploadScreenStatus.loading),
        UploadState(
          status: UploadScreenStatus.success,
          recentUploads: sampleUploads,
        ),
      ],
    );

    blocTest<UploadBloc, UploadState>(
      'emits [loading, failure] when LoadUploadData throws',
      build: () {
        when(() => mockRepository.getRecentUploads())
            .thenThrow(Exception('Failed to load uploads'));
        return UploadBloc(repository: mockRepository);
      },
      act: (bloc) => bloc.add(const LoadUploadData()),
      expect: () => [
        const UploadState(status: UploadScreenStatus.loading),
        predicate<UploadState>((s) =>
            s.status == UploadScreenStatus.failure && s.errorMessage != null),
      ],
    );

    blocTest<UploadBloc, UploadState>(
      'inserts new item when TriggerFileUpload succeeds',
      build: () {
        when(() => mockRepository.uploadFile(
              'New.pdf',
              DocumentType.pdf,
              filePath: any(named: 'filePath'),
              fileSize: any(named: 'fileSize'),
            )).thenAnswer(
          (_) async => const UploadItem(
            id: 'up_new',
            title: 'New.pdf',
            type: DocumentType.pdf,
            stageDescription: 'Queued',
          ),
        );
        return UploadBloc(repository: mockRepository);
      },
      seed: () => UploadState(recentUploads: sampleUploads),
      act: (bloc) => bloc.add(
        const TriggerFileUpload(filename: 'New.pdf', type: DocumentType.pdf),
      ),
      expect: () => [
        predicate<UploadState>((s) =>
            s.recentUploads.length == 2 && s.recentUploads.first.id == 'up_new'),
      ],
    );

    blocTest<UploadBloc, UploadState>(
      'inserts all items when TriggerMultipleFilesUpload succeeds with multi-select files',
      build: () {
        when(() => mockRepository.uploadFile(
              any(),
              any(),
              filePath: any(named: 'filePath'),
              fileSize: any(named: 'fileSize'),
            )).thenAnswer(
          (inv) async => UploadItem(
            id: 'up_${inv.positionalArguments[0]}',
            title: inv.positionalArguments[0] as String,
            type: inv.positionalArguments[1] as DocumentType,
            stageDescription: 'Queued',
          ),
        );
        return UploadBloc(repository: mockRepository);
      },
      seed: () => const UploadState(recentUploads: []),
      act: (bloc) => bloc.add(
        const TriggerMultipleFilesUpload([
          SelectedFileInfo(filename: 'photo1.png', type: DocumentType.image),
          SelectedFileInfo(filename: 'photo2.jpg', type: DocumentType.image),
          SelectedFileInfo(filename: 'doc.pdf', type: DocumentType.pdf),
        ]),
      ),
      expect: () => [
        predicate<UploadState>((s) =>
            s.recentUploads.length == 3 &&
            s.recentUploads.any((u) => u.title == 'photo1.png') &&
            s.recentUploads.any((u) => u.title == 'photo2.jpg') &&
            s.recentUploads.any((u) => u.title == 'doc.pdf') &&
            s.status == UploadScreenStatus.success),
      ],
    );

    blocTest<UploadBloc, UploadState>(
      'cancels voice recording and resets duration',
      build: () => UploadBloc(repository: mockRepository),
      seed: () =>
          const UploadState(isRecording: true, recordingDurationSeconds: 45),
      act: (bloc) => bloc.add(const CancelVoiceRecording()),
      expect: () => [
        const UploadState(isRecording: false, recordingDurationSeconds: 0),
      ],
    );

    blocTest<UploadBloc, UploadState>(
      'stops recording and saves voice memo on StopAndSaveVoiceRecording',
      build: () {
        when(() => mockRepository.saveVoiceMemo(any())).thenAnswer(
          (_) async => const UploadItem(
            id: 'memo_saved',
            title: 'Voice_Memo.m4a',
            type: DocumentType.audio,
            stageDescription: 'Saved',
          ),
        );
        return UploadBloc(repository: mockRepository);
      },
      seed: () => const UploadState(isRecording: true, recordingDurationSeconds: 60),
      act: (bloc) => bloc.add(const StopAndSaveVoiceRecording()),
      expect: () => [
        const UploadState(isRecording: false, recordingDurationSeconds: 60),
        predicate<UploadState>((s) =>
            !s.isRecording &&
            s.recentUploads.any((u) => u.id == 'memo_saved') &&
            s.status == UploadScreenStatus.success),
      ],
    );

    blocTest<UploadBloc, UploadState>(
      'updates recording duration on UpdateRecordingDuration event',
      build: () => UploadBloc(repository: mockRepository),
      act: (bloc) => bloc.add(const UpdateRecordingDuration(180)),
      expect: () => [
        const UploadState(recordingDurationSeconds: 180),
      ],
    );
  });
}
