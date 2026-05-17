import 'image_format.dart';

class ImageAnalysis {
  const ImageAnalysis({
    required this.complexity,
    required this.alphaCoverage,
    required this.colorVariety,
  });

  final double complexity;
  final double alphaCoverage;
  final double colorVariety;
}

class SizeEstimate {
  const SizeEstimate({
    required this.format,
    required this.bytes,
    this.actual = false,
    this.note,
  });

  final ImageFormat format;
  final int bytes;
  final bool actual;
  final String? note;
}
