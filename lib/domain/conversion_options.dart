import 'image_format.dart';

class ConversionOptions {
  const ConversionOptions({
    required this.targetFormat,
    this.quality = 85,
    this.pngCompression = 6,
    this.webpLossless = false,
    this.avifLossless = false,
    this.effort = 5,
    this.resizeWidth,
    this.resizeHeight,
    this.maintainAspectRatio = true,
    this.stripMetadata = true,
    this.matteColor = 0xffffffff,
    this.gifPaletteSize = 256,
    this.gifDither = true,
    this.icoSizes = const [16, 32, 48, 64, 128, 256],
  });

  final ImageFormat targetFormat;
  final int quality;
  final int pngCompression;
  final bool webpLossless;
  final bool avifLossless;
  final int effort;
  final int? resizeWidth;
  final int? resizeHeight;
  final bool maintainAspectRatio;
  final bool stripMetadata;
  final int matteColor;
  final int gifPaletteSize;
  final bool gifDither;
  final List<int> icoSizes;

  ConversionOptions copyWith({
    ImageFormat? targetFormat,
    int? quality,
    int? pngCompression,
    bool? webpLossless,
    bool? avifLossless,
    int? effort,
    int? resizeWidth,
    int? resizeHeight,
    bool clearResize = false,
    bool? maintainAspectRatio,
    bool? stripMetadata,
    int? matteColor,
    int? gifPaletteSize,
    bool? gifDither,
    List<int>? icoSizes,
  }) {
    return ConversionOptions(
      targetFormat: targetFormat ?? this.targetFormat,
      quality: quality ?? this.quality,
      pngCompression: pngCompression ?? this.pngCompression,
      webpLossless: webpLossless ?? this.webpLossless,
      avifLossless: avifLossless ?? this.avifLossless,
      effort: effort ?? this.effort,
      resizeWidth: clearResize ? null : resizeWidth ?? this.resizeWidth,
      resizeHeight: clearResize ? null : resizeHeight ?? this.resizeHeight,
      maintainAspectRatio: maintainAspectRatio ?? this.maintainAspectRatio,
      stripMetadata: stripMetadata ?? this.stripMetadata,
      matteColor: matteColor ?? this.matteColor,
      gifPaletteSize: gifPaletteSize ?? this.gifPaletteSize,
      gifDither: gifDither ?? this.gifDither,
      icoSizes: icoSizes ?? this.icoSizes,
    );
  }
}
