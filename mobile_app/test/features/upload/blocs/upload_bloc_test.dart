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
      expect(bloc.state.isRecording, isTrue);
      expect(bloc.state.recordingDurationSeconds, 165);
      expect(bloc.state.formattedDuration, '02:45');
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
        when(() => mockRepository.uploadFile('New.pdf', DocumentType.pdf))
            .thenAnswer(
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
