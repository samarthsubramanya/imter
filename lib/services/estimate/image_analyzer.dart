import 'dart:math' as math;

import 'package:image/image.dart' as img;

import '../../domain/size_estimate.dart';

class ImageAnalyzer {
  ImageAnalysis analyze(img.Image image) {
    final sampleWidth = math.min(128, math.max(1, image.width));
    final sampleHeight = math.min(128, math.max(1, image.height));
    final stepX = image.width / sampleWidth;
    final stepY = image.height / sampleHeight;
    final colors = <int>{};

    var alphaPixels = 0;
    var totalPixels = 0;
    var edgeTotal = 0.0;
    var luminanceTotal = 0.0;
    var luminanceSquaredTotal = 0.0;
    double? previousLuminance;

    for (var y = 0; y < sampleHeight; y++) {
      previousLuminance = null;
      for (var x = 0; x < sampleWidth; x++) {
        final pixel = image.getPixel(
          math.min(image.width - 1, (x * stepX).floor()),
          math.min(image.height - 1, (y * stepY).floor()),
        );
        final r = pixel.rNormalized.toDouble();
        final g = pixel.gNormalized.toDouble();
        final b = pixel.bNormalized.toDouble();
        final a = pixel.aNormalized.toDouble();
        final luminance = r * 0.2126 + g * 0.7152 + b * 0.0722;
        luminanceTotal += luminance;
        luminanceSquaredTotal += luminance * luminance;
        if (previousLuminance != null) {
          edgeTotal += (luminance - previousLuminance).abs();
        }
        previousLuminance = luminance;
        if (a < 0.98) {
          alphaPixels++;
        }
        colors.add(
          ((r * 15).round() << 8) | ((g * 15).round() << 4) | (b * 15).round(),
        );
        totalPixels++;
      }
    }

    if (totalPixels == 0) {
      return const ImageAnalysis(
        complexity: 0,
        alphaCoverage: 0,
        colorVariety: 0,
      );
    }

    final mean = luminanceTotal / totalPixels;
    final variance = (luminanceSquaredTotal / totalPixels) - mean * mean;
    final edgeDensity = (edgeTotal / totalPixels).clamp(0.0, 1.0);
    final colorVariety = (colors.length / 4096).clamp(0.0, 1.0);
    final complexity = (variance * 2.2 + edgeDensity * 1.4 + colorVariety * 0.9)
        .clamp(0.0, 1.0);

    return ImageAnalysis(
      complexity: complexity,
      alphaCoverage: alphaPixels / totalPixels,
      colorVariety: colorVariety,
    );
  }
}
