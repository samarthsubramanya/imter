import 'dart:typed_data';

import 'image_format.dart';

class ImageMetadata {
  const ImageMetadata({
    required this.name,
    required this.path,
    required this.format,
    required this.width,
    required this.height,
    required this.fileSizeBytes,
    required this.hasAlpha,
    required this.hasAnimation,
    required this.frameCount,
    required this.bitsPerChannel,
  });

  final String name;
  final String path;
  final ImageFormat format;
  final int width;
  final int height;
  final int fileSizeBytes;
  final bool hasAlpha;
  final bool hasAnimation;
  final int frameCount;
  final int bitsPerChannel;
}

class SourceImage {
  const SourceImage({
    required this.metadata,
    required this.originalBytes,
    required this.previewPngBytes,
  });

  final ImageMetadata metadata;
  final Uint8List originalBytes;
  final Uint8List previewPngBytes;
}
