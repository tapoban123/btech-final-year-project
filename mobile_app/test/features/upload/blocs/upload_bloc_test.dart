import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:mobile_app/features/dashboard/repository/models/document_item.dart';
import 'package:mobile_app/features/upload/blocs/upload_bloc.dart';
import 'package:mobile_app/features/upload/blocs/upload_event.dart';
import 'package:mobile_app/features/upload/blocs/upload_state.dart';
import 'package:mobile_app/features/upload/repository/models/upload_item.dart';
import 'package:mobile_app/features/upload/repository/upload_repository.dart';

import 'package:mobile_app/features/upload/services/audio_recording_service.dart';

class MockUploadRepository extends Mock implements IUploadRepository {}

class MockAudioRecordingService extends Mock implements IAudioRecordingService {}

void main() {
  setUpAll(() {
    TestWidgetsFlutterBinding.ensureInitialized();
    registerFallbackValue(DocumentType.pdf);
  });

  late MockUploadRepository mockRepository;
  late MockAudioRecordingService mockAudioService;

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
    mockAudioService = MockAudioRecordingService();
    when(() => mockAudioService.hasPermission()).thenAnswer((_) async => true);
    when(() => mockAudioService.start(path: any(named: 'path')))
        .thenAnswer((_) async {});
    when(() => mockAudioService.stop())
        .thenAnswer((_) async => '/tmp/voice.m4a');
    when(() => mockAudioService.cancel()).thenAnswer((_) async {});
    when(() => mockAudioService.onAmplitudeChanged)
        .thenAnswer((_) => const Stream.empty());
    when(() => mockAudioService.isRecording()).thenAnswer((_) async => false);
  });

  group('UploadBloc Tests', () {
    test('initial state defaults', () {
      final bloc = UploadBloc(
        repository: mockRepository,
        audioRecordingService: mockAudioService,
      );
      expect(bloc.state.status, UploadScreenStatus.initial);
      expect(bloc.state.recentUploads, isEmpty);
      expect(bloc.state.isRecordingCardVisible, isFalse);
      expect(bloc.state.isRecording, isFalse);
      expect(bloc.state.recordingDurationSeconds, 0);
      expect(bloc.state.formattedDuration, '00:00');
    });

    blocTest<UploadBloc, UploadState>(
      'emits [loading, success] when LoadUploadData succeeds',
      build: () {
        when(() => mockRepository.getRecentUploads())
            .thenAnswer((_) async => sampleUploads);
        return UploadBloc(
          repository: mockRepository,
          audioRecordingService: mockAudioService,
        );
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
        return UploadBloc(
          repository: mockRepository,
          audioRecordingService: mockAudioService,
        );
      },
      act: (bloc) => bloc.add(const LoadUploadData()),
      expect: () => [
        const UploadState(status: UploadScreenStatus.loading),
        predicate<UploadState>((s) =>
            s.status == UploadScreenStatus.failure && s.errorMessage != null),
      ],
    );

    blocTest<UploadBloc, UploadState>(
      'stages new item as queued when TriggerFileUpload is dispatched',
      build: () => UploadBloc(
        repository: mockRepository,
        audioRecordingService: mockAudioService,
      ),
      seed: () => UploadState(recentUploads: sampleUploads),
      act: (bloc) => bloc.add(
        const TriggerFileUpload(filename: 'New.pdf', type: DocumentType.pdf),
      ),
      expect: () => [
        predicate<UploadState>((s) =>
            s.recentUploads.length == 2 &&
            s.recentUploads.first.title == 'New.pdf' &&
            s.recentUploads.first.status == UploadProcessingStatus.queued &&
            s.status == UploadScreenStatus.success),
      ],
    );

    blocTest<UploadBloc, UploadState>(
      'stages all items as queued when TriggerMultipleFilesUpload is dispatched',
      build: () => UploadBloc(
        repository: mockRepository,
        audioRecordingService: mockAudioService,
      ),
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
            s.recentUploads.any((u) => u.title == 'photo1.png' && u.status == UploadProcessingStatus.queued) &&
            s.recentUploads.any((u) => u.title == 'photo2.jpg' && u.status == UploadProcessingStatus.queued) &&
            s.recentUploads.any((u) => u.title == 'doc.pdf' && u.status == UploadProcessingStatus.queued) &&
            s.status == UploadScreenStatus.success),
      ],
    );

    blocTest<UploadBloc, UploadState>(
      'removes item from list on RemoveUploadItem',
      build: () => UploadBloc(
        repository: mockRepository,
        audioRecordingService: mockAudioService,
      ),
      seed: () => UploadState(recentUploads: sampleUploads),
      act: (bloc) => bloc.add(const RemoveUploadItem('up_1')),
      expect: () => [
        const UploadState(recentUploads: []),
      ],
    );

    blocTest<UploadBloc, UploadState>(
      'uploads queued items in parallel on ConfirmAndUploadAll',
      build: () {
        when(() => mockRepository.uploadFile(
              any(),
              any(),
              filePath: any(named: 'filePath'),
              fileSize: any(named: 'fileSize'),
            )).thenAnswer(
          (inv) async => UploadItem(
            id: 'confirmed_${inv.positionalArguments[0]}',
            title: inv.positionalArguments[0] as String,
            type: inv.positionalArguments[1] as DocumentType,
            stageDescription: 'Indexed & ready',
            status: UploadProcessingStatus.completed,
          ),
        );
        return UploadBloc(
          repository: mockRepository,
          audioRecordingService: mockAudioService,
        );
      },
      seed: () => const UploadState(
        recentUploads: [
          UploadItem(
            id: 'q_1',
            title: 'doc1.pdf',
            type: DocumentType.pdf,
            stageDescription: 'Ready to upload',
            status: UploadProcessingStatus.queued,
          ),
          UploadItem(
            id: 'q_2',
            title: 'doc2.pdf',
            type: DocumentType.pdf,
            stageDescription: 'Ready to upload',
            status: UploadProcessingStatus.queued,
          ),
        ],
      ),
      act: (bloc) => bloc.add(const ConfirmAndUploadAll()),
      expect: () => [
        predicate<UploadState>((s) =>
            s.isUploading &&
            s.status == UploadScreenStatus.loading &&
            s.recentUploads.every((u) => u.status == UploadProcessingStatus.processing)),
        predicate<UploadState>((s) =>
            !s.isUploading &&
            s.status == UploadScreenStatus.success &&
            s.recentUploads.every((u) => u.status == UploadProcessingStatus.completed)),
      ],
      verify: (_) {
        verify(() => mockRepository.uploadFile('doc1.pdf', DocumentType.pdf)).called(1);
        verify(() => mockRepository.uploadFile('doc2.pdf', DocumentType.pdf)).called(1);
      },
    );

    blocTest<UploadBloc, UploadState>(
      'handles upload failure on ConfirmAndUploadAll',
      build: () {
        when(() => mockRepository.uploadFile(
              any(),
              any(),
              filePath: any(named: 'filePath'),
              fileSize: any(named: 'fileSize'),
            )).thenThrow(Exception('Network error during upload'));
        return UploadBloc(
          repository: mockRepository,
          audioRecordingService: mockAudioService,
        );
      },
      seed: () => const UploadState(
        recentUploads: [
          UploadItem(
            id: 'q_1',
            title: 'doc1.pdf',
            type: DocumentType.pdf,
            stageDescription: 'Ready to upload',
            status: UploadProcessingStatus.queued,
          ),
        ],
      ),
      act: (bloc) => bloc.add(const ConfirmAndUploadAll()),
      expect: () => [
        predicate<UploadState>((s) =>
            s.isUploading &&
            s.status == UploadScreenStatus.loading &&
            s.recentUploads.first.status == UploadProcessingStatus.processing),
        predicate<UploadState>((s) =>
            !s.isUploading &&
            s.status == UploadScreenStatus.failure &&
            s.errorMessage != null),
      ],
    );

    blocTest<UploadBloc, UploadState>(
      'opens voice recorder card on OpenVoiceRecorder',
      build: () => UploadBloc(
        repository: mockRepository,
        audioRecordingService: mockAudioService,
      ),
      act: (bloc) => bloc.add(const OpenVoiceRecorder()),
      expect: () => [
        predicate<UploadState>((s) =>
            s.isRecordingCardVisible &&
            !s.isRecording &&
            s.recordingDurationSeconds == 0),
      ],
    );

    blocTest<UploadBloc, UploadState>(
      'starts voice recording when permission is granted',
      build: () {
        when(() => mockAudioService.hasPermission()).thenAnswer((_) async => true);
        return UploadBloc(
          repository: mockRepository,
          audioRecordingService: mockAudioService,
        );
      },
      act: (bloc) => bloc.add(const StartVoiceRecording()),
      expect: () => [
        predicate<UploadState>((s) =>
            s.isRecordingCardVisible &&
            s.isRecording &&
            s.recordingDurationSeconds == 0 &&
            s.currentAmplitude > 0),
      ],
      verify: (_) {
        verify(() => mockAudioService.hasPermission()).called(1);
        verify(() => mockAudioService.start(path: any(named: 'path'))).called(1);
      },
    );

    blocTest<UploadBloc, UploadState>(
      'emits failure when microphone permission is denied',
      build: () {
        when(() => mockAudioService.hasPermission()).thenAnswer((_) async => false);
        return UploadBloc(
          repository: mockRepository,
          audioRecordingService: mockAudioService,
        );
      },
      act: (bloc) => bloc.add(const StartVoiceRecording()),
      expect: () => [
        predicate<UploadState>((s) =>
            !s.isRecording &&
            s.status == UploadScreenStatus.failure &&
            s.errorMessage!.contains('Microphone permission')),
      ],
      verify: (_) {
        verifyNever(() => mockAudioService.start(path: any(named: 'path')));
      },
    );

    blocTest<UploadBloc, UploadState>(
      'updates voice amplitude when actively recording',
      build: () => UploadBloc(
        repository: mockRepository,
        audioRecordingService: mockAudioService,
      ),
      seed: () => const UploadState(isRecording: true),
      act: (bloc) => bloc.add(const UpdateVoiceAmplitude(0.85)),
      expect: () => [
        const UploadState(isRecording: true, currentAmplitude: 0.85),
      ],
    );

    blocTest<UploadBloc, UploadState>(
      'cancels voice recording and resets state',
      build: () => UploadBloc(
        repository: mockRepository,
        audioRecordingService: mockAudioService,
      ),
      seed: () => const UploadState(
        isRecordingCardVisible: true,
        isRecording: true,
        recordingDurationSeconds: 45,
        currentAmplitude: 0.7,
      ),
      act: (bloc) => bloc.add(const CancelVoiceRecording()),
      expect: () => [
        const UploadState(
          isRecording: false,
          isRecordingCardVisible: false,
          recordingDurationSeconds: 0,
          currentAmplitude: 0.0,
        ),
      ],
      verify: (_) {
        verify(() => mockAudioService.cancel()).called(1);
      },
    );

    blocTest<UploadBloc, UploadState>(
      'stops recording, saves voice memo, and stages it into recentUploads',
      build: () {
        when(() => mockAudioService.stop()).thenAnswer((_) async => '/tmp/memo.m4a');
        when(() => mockRepository.saveVoiceMemo(any())).thenAnswer(
          (_) async => const UploadItem(
            id: 'memo_saved',
            title: 'Voice_Memo.m4a',
            type: DocumentType.audio,
            stageDescription: '01:00',
            status: UploadProcessingStatus.completed,
          ),
        );
        return UploadBloc(
          repository: mockRepository,
          audioRecordingService: mockAudioService,
        );
      },
      seed: () => const UploadState(
        isRecordingCardVisible: true,
        isRecording: true,
        recordingDurationSeconds: 60,
      ),
      act: (bloc) => bloc.add(const StopAndSaveVoiceRecording()),
      expect: () => [
        const UploadState(
          isRecordingCardVisible: true,
          isRecording: false,
          recordingDurationSeconds: 60,
        ),
        predicate<UploadState>((s) =>
            !s.isRecording &&
            !s.isRecordingCardVisible &&
            s.recordingDurationSeconds == 0 &&
            s.recentUploads.any((u) => u.id == 'memo_saved') &&
            s.recentUploads.first.status == UploadProcessingStatus.queued &&
            s.status == UploadScreenStatus.success),
      ],
      verify: (_) {
        verify(() => mockAudioService.stop()).called(1);
        verify(() => mockRepository.saveVoiceMemo(60)).called(1);
      },
    );

    blocTest<UploadBloc, UploadState>(
      'updates recording duration on UpdateRecordingDuration event',
      build: () => UploadBloc(
        repository: mockRepository,
        audioRecordingService: mockAudioService,
      ),
      act: (bloc) => bloc.add(const UpdateRecordingDuration(180)),
      expect: () => [
        const UploadState(recordingDurationSeconds: 180),
      ],
    );
  });
}
