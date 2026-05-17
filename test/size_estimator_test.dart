import 'package:flutter_test/flutter_test.dart';
import 'package:imter/domain/conversion_options.dart';
import 'package:imter/domain/image_format.dart';
import 'package:imter/domain/image_metadata.dart';
import 'package:imter/domain/size_estimate.dart';
import 'package:imter/services/estimate/size_estimator.dart';

void main() {
  test('estimates every advertised output format', () {
    const metadata = ImageMetadata(
      name: 'sample.png',
      path: '/tmp/sample.png',
      format: ImageFormat.png,
      width: 1200,
      height: 800,
      fileSizeBytes: 600000,
      hasAlpha: true,
      hasAnimation: false,
      frameCount: 1,
      bitsPerChannel: 8,
    );
    const analysis = ImageAnalysis(
      complexity: 0.42,
      alphaCoverage: 0.2,
      colorVariety: 0.35,
    );

    final estimates = SizeEstimator().estimateAll(
      metadata,
      analysis,
      const ConversionOptions(targetFormat: ImageFormat.jpeg),
    );

    expect(estimates.keys, containsAll(ImageFormat.values));
    expect(estimates[ImageFormat.jpeg]!.bytes, greaterThan(0));
    expect(estimates[ImageFormat.webp]!.note, contains('Approximate'));
    expect(estimates[ImageFormat.avif]!.note, contains('Approximate'));
  });
}
