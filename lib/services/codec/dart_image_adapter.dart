import 'dart:math' as math;
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter_avif/flutter_avif.dart' as avif;
import 'package:image/image.dart' as img;
import 'package:ironpress/ironpress.dart' as iron;

import '../../domain/conversion_options.dart';
import '../../domain/image_format.dart';
import 'image_codec_adapter.dart';

class DartImageAdapter implements ImageCodecAdapter {
  @override
  Set<ImageFormat> get readableFormats => {
    ImageFormat.jpeg,
    ImageFormat.png,
    ImageFormat.webp,
    ImageFormat.avif,
    ImageFormat.gif,
    ImageFormat.bmp,
    ImageFormat.tiff,
    ImageFormat.ico,
  };

  @override
  Set<ImageFormat> get writableFormats => {
    ImageFormat.jpeg,
    ImageFormat.png,
    ImageFormat.webp,
    ImageFormat.avif,
    ImageFormat.gif,
    ImageFormat.bmp,
    ImageFormat.tiff,
    ImageFormat.ico,
  };

  @override
  Future<img.Image> decode(Uint8List bytes, ImageFormat format) async {
    if (format == ImageFormat.avif) {
      return _decodeAvif(bytes);
    }

    final decoded = img.decodeImage(bytes);
    if (decoded == null) {
      throw const FormatException('The image could not be decoded.');
    }
    return decoded;
  }

  @override
  Future<Uint8List> encode(
    img.Image image,
    ImageFormat targetFormat,
    ConversionOptions options,
  ) async {
    final prepared = _prepareImage(image, targetFormat, options);
    return switch (targetFormat) {
      ImageFormat.jpeg => img.encodeJpg(
        _flattenAlpha(prepared, options.matteColor),
        quality: options.quality,
        chroma: img.JpegChroma.yuv420,
      ),
      ImageFormat.png => img.encodePng(
        prepared,
        singleFrame: true,
        level: options.pngCompression,
      ),
      ImageFormat.webp => await _encodeWebp(prepared, options),
      ImageFormat.avif => await _encodeAvif(prepared, options),
      ImageFormat.gif => img.encodeGif(
        prepared,
        singleFrame: true,
        samplingFactor: _samplingFactorForPalette(options.gifPaletteSize),
        dither: options.gifDither
            ? img.DitherKernel.floydSteinberg
            : img.DitherKernel.none,
      ),
      ImageFormat.bmp => img.encodeBmp(
        _flattenAlpha(prepared, options.matteColor),
      ),
      ImageFormat.tiff => img.encodeTiff(prepared, singleFrame: true),
      ImageFormat.ico => img.encodeIco(
        _prepareIcon(prepared),
        singleFrame: true,
      ),
    };
  }

  Future<img.Image> _decodeAvif(Uint8List bytes) async {
    final frames = await avif.decodeAvif(bytes);
    if (frames.isEmpty) {
      throw const FormatException('The AVIF image could not be decoded.');
    }

    final firstFrame = frames.first.image;
    final width = firstFrame.width;
    final height = firstFrame.height;
    final imageData = await firstFrame.toByteData(
      format: ui.ImageByteFormat.rawRgba,
    );
    for (final frame in frames) {
      frame.image.dispose();
    }

    if (imageData == null) {
      throw const FormatException('The AVIF frame could not be read.');
    }

    return img.Image.fromBytes(
      width: width,
      height: height,
      bytes: imageData.buffer,
      bytesOffset: imageData.offsetInBytes,
      numChannels: 4,
      order: img.ChannelOrder.rgba,
    );
  }

  Future<Uint8List> _encodeWebp(
    img.Image image,
    ConversionOptions options,
  ) async {
    final sourceBytes = Uint8List.fromList(
      img.encodePng(image, singleFrame: true, level: 1),
    );
    final result = await iron.Ironpress.compressBytes(
      sourceBytes,
      quality: options.quality,
      format: options.webpLossless
          ? iron.CompressFormat.webpLossless
          : iron.CompressFormat.webpLossy,
      keepMetadata: !options.stripMetadata,
    );
    final data = result.data;
    if (data == null || data.isEmpty) {
      throw const FormatException('The WebP encoder did not return output.');
    }
    return data;
  }

  Future<Uint8List> _encodeAvif(
    img.Image image,
    ConversionOptions options,
  ) async {
    final sourceBytes = Uint8List.fromList(
      img.encodePng(image, singleFrame: true, level: 1),
    );
    final quantizer = _avifQuantizer(options);
    return avif.encodeAvif(
      sourceBytes,
      maxThreads: 4,
      speed: 10 - options.effort.clamp(0, 10).toInt(),
      minQuantizer: quantizer.$1,
      maxQuantizer: quantizer.$2,
      minQuantizerAlpha: quantizer.$1,
      maxQuantizerAlpha: quantizer.$2,
      keepExif: !options.stripMetadata,
    );
  }

  img.Image _prepareImage(
    img.Image source,
    ImageFormat targetFormat,
    ConversionOptions options,
  ) {
    var output = img.Image.from(source, noAnimation: true);

    if (options.resizeWidth != null || options.resizeHeight != null) {
      final size = _targetSize(output.width, output.height, options);
      output = img.copyResize(
        output,
        width: size.$1,
        height: size.$2,
        interpolation: img.Interpolation.cubic,
      );
    }

    if (!targetFormat.supportsAlpha && output.hasAlpha) {
      output = _flattenAlpha(output, options.matteColor);
    }

    return output;
  }

  (int width, int height) _targetSize(
    int sourceWidth,
    int sourceHeight,
    ConversionOptions options,
  ) {
    final requestedWidth = options.resizeWidth;
    final requestedHeight = options.resizeHeight;

    if (!options.maintainAspectRatio) {
      return (
        math.max(1, requestedWidth ?? sourceWidth),
        math.max(1, requestedHeight ?? sourceHeight),
      );
    }

    if (requestedWidth != null && requestedHeight == null) {
      return (
        math.max(1, requestedWidth),
        math.max(1, (requestedWidth * sourceHeight / sourceWidth).round()),
      );
    }

    if (requestedHeight != null && requestedWidth == null) {
      return (
        math.max(1, (requestedHeight * sourceWidth / sourceHeight).round()),
        math.max(1, requestedHeight),
      );
    }

    if (requestedWidth != null && requestedHeight != null) {
      final scale = math.min(
        requestedWidth / sourceWidth,
        requestedHeight / sourceHeight,
      );
      return (
        math.max(1, (sourceWidth * scale).round()),
        math.max(1, (sourceHeight * scale).round()),
      );
    }

    return (sourceWidth, sourceHeight);
  }

  img.Image _flattenAlpha(img.Image image, int matteColor) {
    if (!image.hasAlpha) {
      return image.convert(numChannels: 3);
    }

    final matteR = (matteColor >> 16) & 0xff;
    final matteG = (matteColor >> 8) & 0xff;
    final matteB = matteColor & 0xff;
    final flattened = img.Image(
      width: image.width,
      height: image.height,
      numChannels: 3,
    );

    for (final pixel in image) {
      final alpha = pixel.aNormalized.clamp(0, 1).toDouble();
      final r = (pixel.r * alpha + matteR * (1 - alpha)).round();
      final g = (pixel.g * alpha + matteG * (1 - alpha)).round();
      final b = (pixel.b * alpha + matteB * (1 - alpha)).round();
      flattened.setPixelRgb(pixel.x, pixel.y, r, g, b);
    }

    return flattened;
  }

  img.Image _prepareIcon(img.Image image) {
    final size = math.min(
      256,
      math.max(16, math.min(image.width, image.height)),
    );
    return img.copyResizeCropSquare(
      image,
      size: size,
      interpolation: img.Interpolation.cubic,
    );
  }

  int _samplingFactorForPalette(int paletteSize) {
    if (paletteSize >= 256) {
      return 10;
    }
    if (paletteSize >= 128) {
      return 16;
    }
    if (paletteSize >= 64) {
      return 24;
    }
    return 32;
  }

  (int min, int max) _avifQuantizer(ConversionOptions options) {
    if (options.avifLossless) {
      return (0, 0);
    }

    final quality = options.quality.clamp(1, 100);
    final maxQuantizer = ((100 - quality) * 63 / 99)
        .round()
        .clamp(0, 63)
        .toInt();
    final minQuantizer = math.max(0, maxQuantizer - 10);
    return (minQuantizer, maxQuantizer);
  }
}
