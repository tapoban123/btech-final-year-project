import 'package:file_picker/file_picker.dart';

abstract class IFilePickerService {
  Future<List<PlatformFile>?> pickFiles({
    FileType type = FileType.any,
    List<String>? allowedExtensions,
  });
}

class FilePickerService implements IFilePickerService {
  const FilePickerService();

  @override
  Future<List<PlatformFile>?> pickFiles({
    FileType type = FileType.any,
    List<String>? allowedExtensions,
  }) async {
    try {
      final result = await FilePicker.pickFiles(
        type: type,
        allowedExtensions:
            type == FileType.custom ? allowedExtensions : null,
      );
      return result;
    } catch (e, stack) {
      // ignore: avoid_print
      print('FilePicker error: $e\n$stack');
      if (type == FileType.custom) {
        try {
          return await FilePicker.pickFiles(type: FileType.any);
        } catch (_) {}
      }
      return null;
    }
  }
}
