import 'dart:math' as math;

import '../../domain/conversion_options.dart';
import '../../domain/image_format.dart';
import '../../domain/image_metadata.dart';
import '../../domain/size_estimate.dart';

class SizeEstimator {
  Map<ImageFormat, SizeEstimate> estimateAll(
    ImageMetadata metadata,
    ImageAnalysis analysis,
    ConversionOptions options,
  ) {
    return {
      for (final format in ImageFormat.values)
        format: estimate(
          metadata,
          analysis,
          options.copyWith(targetFormat: format),
        ),
    };
  }

  SizeEstimate estimate(
    ImageMetadata metadata,
    ImageAnalysis analysis,
    ConversionOptions options,
  ) {
    final width = options.resizeWidth ?? metadata.width;
    final height = options.resizeHeight ?? metadata.height;
    final pixels = math.max(1, width * height);
    final complexity = analysis.complexity.clamp(0.08, 1.0);
    final colorVariety = analysis.colorVariety.clamp(0.05, 1.0);
    final alphaBoost = metadata.hasAlpha
        ? 1 + analysis.alphaCoverage * 0.28
        : 1.0;

    final bytes = switch (options.targetFormat) {
      ImageFormat.jpeg => _jpeg(pixels, options.quality, complexity),
      ImageFormat.png => _png(
        pixels,
        options.pngCompression,
        complexity,
        colorVariety,
        alphaBoost,
      ),
      ImageFormat.webp =>
        options.webpLossless
            ? _png(pixels, 7, complexity, colorVariety, alphaBoost) * 0.72
            : _webp(pixels, options.quality, complexity, alphaBoost),
      ImageFormat.avif =>
        options.avifLossless
            ? _png(pixels, 8, complexity, colorVariety, alphaBoost) * 0.62
            : _avif(pixels, options.quality, complexity, alphaBoost),
      ImageFormat.gif => _gif(pixels, options.gifPaletteSize, colorVariety),
      ImageFormat.tiff => _tiff(
        pixels,
        metadata.hasAlpha,
        options.pngCompression,
      ),
      ImageFormat.bmp => _bmp(pixels, metadata.hasAlpha),
      ImageFormat.ico => _ico(options.icoSizes, complexity, colorVariety),
    };

    return SizeEstimate(
      format: options.targetFormat,
      bytes: math.max(512, bytes.round()),
      note: _noteFor(options.targetFormat),
    );
  }

  double _jpeg(int pixels, int quality, double complexity) {
    final q = quality.clamp(1, 100) / 100;
    return pixels * (0.08 + q * q * 0.88) * (0.42 + complexity);
  }

  double _webp(int pixels, int quality, double complexity, double alphaBoost) {
    return _jpeg(pixels, quality, complexity) * 0.68 * alphaBoost;
  }

  double _avif(int pixels, int quality, double complexity, double alphaBoost) {
    return _jpeg(pixels, quality, complexity) * 0.48 * alphaBoost;
  }

  double _png(
    int pixels,
    int compression,
    double complexity,
    double colorVariety,
    double alphaBoost,
  ) {
    final compressionFactor = 1.12 - compression.clamp(0, 9) * 0.055;
    return pixels *
        4 *
        (0.12 + complexity * 0.46 + colorVariety * 0.42) *
        compressionFactor *
        alphaBoost;
  }

  double _gif(int pixels, int paletteSize, double colorVariety) {
    final paletteFactor = paletteSize.clamp(2, 256) / 256;
    return pixels * (0.42 + paletteFactor * 0.52 + colorVariety * 0.8) +
        paletteSize * 3;
  }

  double _tiff(int pixels, bool hasAlpha, int compression) {
    final raw = pixels * (hasAlpha ? 4 : 3);
    final compressionFactor = compression >= 6 ? 0.78 : 0.92;
    return raw * compressionFactor + 4096;
  }

  double _bmp(int pixels, bool hasAlpha) {
    return pixels * (hasAlpha ? 4 : 3) + 54;
  }

  double _ico(List<int> sizes, double complexity, double colorVariety) {
    final selected = sizes.isEmpty ? const [256] : sizes;
    var total = 128.0;
    for (final size in selected) {
      final pixels = size * size;
      total += _png(pixels, 6, complexity, colorVariety, 1.12);
    }
    return total;
  }

  String? _noteFor(ImageFormat format) {
    return switch (format) {
      ImageFormat.webp => 'Approximate until conversion is run.',
      ImageFormat.avif => 'Approximate until conversion is run.',
      _ => null,
    };
  }
}
