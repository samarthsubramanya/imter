import 'package:file_selector/file_selector.dart';
import 'package:path/path.dart' as p;

import '../../domain/image_format.dart';

class FilePickerService {
  Future<String?> pickImagePath() async {
    final file = await openFile(
      acceptedTypeGroups: [
        XTypeGroup(
          label: 'Raster images',
          extensions: ImageFormat.values
              .expand((format) => format.extensions)
              .toList(),
        ),
      ],
    );
    return file?.path;
  }

  Future<String?> pickSavePath({
    required String sourcePath,
    required ImageFormat targetFormat,
  }) async {
    final basename = p.basenameWithoutExtension(sourcePath);
    final location = await getSaveLocation(
      suggestedName: '$basename.${targetFormat.primaryExtension}',
      acceptedTypeGroups: [
        XTypeGroup(
          label: targetFormat.label,
          extensions: targetFormat.extensions,
        ),
      ],
    );
    return location?.path;
  }
}
