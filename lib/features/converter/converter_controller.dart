import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:image/image.dart' as img;
import 'package:path/path.dart' as p;

import '../../domain/conversion_options.dart';
import '../../domain/formatting.dart';
import '../../domain/image_format.dart';
import '../../domain/image_metadata.dart';
import '../../domain/size_estimate.dart';
import '../../services/codec/codec_registry.dart';
import '../../services/estimate/image_analyzer.dart';
import '../../services/estimate/size_estimator.dart';
import '../../services/files/file_picker_service.dart';

class ConverterController extends ChangeNotifier {
  ConverterController({
    required CodecRegistry codecRegistry,
    required FilePickerService filePickerService,
    required ImageAnalyzer imageAnalyzer,
    required SizeEstimator sizeEstimator,
  }) : _codecRegistry = codecRegistry,
       _filePickerService = filePickerService,
       _imageAnalyzer = imageAnalyzer,
       _sizeEstimator = sizeEstimator;

  final CodecRegistry _codecRegistry;
  final FilePickerService _filePickerService;
  final ImageAnalyzer _imageAnalyzer;
  final SizeEstimator _sizeEstimator;

  SourceImage? source;
  ImageAnalysis? analysis;
  Map<ImageFormat, SizeEstimate> estimates = {};
  ConversionOptions options = const ConversionOptions(
    targetFormat: ImageFormat.jpeg,
  );
  String? errorMessage;
  String? statusMessage;
  String? resultPath;
  int? actualOutputBytes;
  bool isLoading = false;
  bool isConverting = false;
  img.Image? _decodedImage;

  Set<ImageFormat> get writableFormats => _codecRegistry.writableFormats;

  bool get hasSource => source != null;

  bool get canConvert =>
      source != null &&
      !isLoading &&
      !isConverting &&
      _codecRegistry.canWrite(options.targetFormat);

  String? get selectedFormatWarning {
    final metadata = source?.metadata;
    if (metadata == null) {
      return null;
    }
    if (!_codecRegistry.canWrite(options.targetFormat)) {
      return '${options.targetFormat.label} output is planned, but the native encoder adapter is not wired into this build yet.';
    }
    if (metadata.hasAnimation && options.targetFormat != ImageFormat.gif) {
      return 'This version converts the first frame only for animated images.';
    }
    if (metadata.hasAlpha && !options.targetFormat.supportsAlpha) {
      return '${options.targetFormat.label} does not support transparency. Transparent pixels will be composited onto the matte color.';
    }
    if (options.targetFormat == ImageFormat.bmp) {
      return 'BMP is usually much larger than compressed formats.';
    }
    if (options.targetFormat == ImageFormat.ico) {
      return 'ICO output is cropped to a square icon image in this first build.';
    }
    return null;
  }

  Future<void> chooseSource() async {
    final path = await _filePickerService.pickImagePath();
    if (path != null) {
      await loadSource(path);
    }
  }

  Future<void> loadSource(String path) async {
    _setBusy(loading: true, status: 'Reading image');
    errorMessage = null;
    resultPath = null;
    actualOutputBytes = null;
    notifyListeners();

    try {
      final file = File(path);
      if (!await file.exists()) {
        throw const FileSystemException('The selected file does not exist.');
      }

      final format = ImageFormat.fromExtension(p.extension(path));
      if (format == null) {
        throw const FormatException('Unsupported file extension.');
      }
      if (!_codecRegistry.canRead(format)) {
        throw UnsupportedError(
          '${format.label} input is not available in this build.',
        );
      }

      final bytes = await file.readAsBytes();
      statusMessage = 'Decoding image';
      notifyListeners();

      final decoded = await _codecRegistry.decode(bytes, format);
      final firstFrame = img.Image.from(decoded, noAnimation: true);
      final preview = img.encodePng(firstFrame, singleFrame: true, level: 3);
      final currentAnalysis = _imageAnalyzer.analyze(firstFrame);
      final metadata = ImageMetadata(
        name: p.basename(path),
        path: path,
        format: format,
        width: firstFrame.width,
        height: firstFrame.height,
        fileSizeBytes: bytes.length,
        hasAlpha: firstFrame.hasAlpha,
        hasAnimation: decoded.hasAnimation,
        frameCount: decoded.numFrames,
        bitsPerChannel: firstFrame.bitsPerChannel,
      );

      _decodedImage = decoded;
      source = SourceImage(
        metadata: metadata,
        originalBytes: bytes,
        previewPngBytes: Uint8List.fromList(preview),
      );
      analysis = currentAnalysis;
      options = options.copyWith(
        targetFormat: _defaultTargetFor(metadata),
        clearResize: true,
      );
      _refreshEstimates();
      statusMessage = null;
    } catch (error) {
      _decodedImage = null;
      source = null;
      analysis = null;
      estimates = {};
      errorMessage = _friendlyError(error);
      statusMessage = null;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  void selectTarget(ImageFormat format) {
    options = options.copyWith(targetFormat: format);
    actualOutputBytes = null;
    resultPath = null;
    _refreshEstimates();
    notifyListeners();
  }

  void setQuality(double value) {
    options = options.copyWith(quality: value.round().clamp(1, 100));
    _afterOptionChange();
  }

  void setPngCompression(double value) {
    options = options.copyWith(pngCompression: value.round().clamp(0, 9));
    _afterOptionChange();
  }

  void setEffort(double value) {
    options = options.copyWith(effort: value.round().clamp(0, 10));
    _afterOptionChange();
  }

  void setWebpLossless(bool value) {
    options = options.copyWith(webpLossless: value);
    _afterOptionChange();
  }

  void setAvifLossless(bool value) {
    options = options.copyWith(avifLossless: value);
    _afterOptionChange();
  }

  void setGifPalette(double value) {
    options = options.copyWith(gifPaletteSize: value.round().clamp(2, 256));
    _afterOptionChange();
  }

  void setGifDither(bool value) {
    options = options.copyWith(gifDither: value);
    _afterOptionChange();
  }

  void setStripMetadata(bool value) {
    options = options.copyWith(stripMetadata: value);
    _afterOptionChange();
  }

  void setMaintainAspectRatio(bool value) {
    options = options.copyWith(maintainAspectRatio: value);
    _afterOptionChange();
  }

  void setMatteColor(int value) {
    options = options.copyWith(matteColor: value);
    _afterOptionChange();
  }

  void setResizeWidth(String value) {
    final parsed = int.tryParse(value);
    options = options.copyWith(
      resizeWidth: parsed != null && parsed > 0 ? parsed : null,
    );
    _afterOptionChange();
  }

  void setResizeHeight(String value) {
    final parsed = int.tryParse(value);
    options = options.copyWith(
      resizeHeight: parsed != null && parsed > 0 ? parsed : null,
    );
    _afterOptionChange();
  }

  void clearResize() {
    options = options.copyWith(clearResize: true);
    _afterOptionChange();
  }

  Future<void> convertSelected() async {
    final metadata = source?.metadata;
    final decoded = _decodedImage;
    if (metadata == null || decoded == null) {
      return;
    }

    if (!_codecRegistry.canWrite(options.targetFormat)) {
      errorMessage =
          '${options.targetFormat.label} output needs a native encoder adapter.';
      notifyListeners();
      return;
    }

    final savePath = await _filePickerService.pickSavePath(
      sourcePath: metadata.path,
      targetFormat: options.targetFormat,
    );
    if (savePath == null) {
      return;
    }

    _setBusy(
      converting: true,
      status: 'Encoding ${options.targetFormat.label}',
    );
    errorMessage = null;
    notifyListeners();

    try {
      final output = await _codecRegistry.encode(
        decoded,
        options.targetFormat,
        options,
      );
      statusMessage = 'Writing file';
      notifyListeners();
      final outputFile = File(savePath);
      await outputFile.writeAsBytes(output, flush: true);
      final actualBytes = await outputFile.length();
      actualOutputBytes = actualBytes;
      resultPath = savePath;
      estimates = {
        ...estimates,
        options.targetFormat: SizeEstimate(
          format: options.targetFormat,
          bytes: actualBytes,
          actual: true,
        ),
      };
      statusMessage = 'Saved ${formatBytes(actualBytes)}';
    } catch (error) {
      errorMessage = _friendlyError(error);
      statusMessage = null;
    } finally {
      isConverting = false;
      notifyListeners();
    }
  }

  void _afterOptionChange() {
    actualOutputBytes = null;
    resultPath = null;
    _refreshEstimates();
    notifyListeners();
  }

  void _refreshEstimates() {
    final metadata = source?.metadata;
    final currentAnalysis = analysis;
    if (metadata == null || currentAnalysis == null) {
      estimates = {};
      return;
    }
    estimates = _sizeEstimator.estimateAll(metadata, currentAnalysis, options);
  }

  ImageFormat _defaultTargetFor(ImageMetadata metadata) {
    if (metadata.hasAlpha && metadata.format != ImageFormat.png) {
      return ImageFormat.png;
    }
    if (metadata.format == ImageFormat.jpeg) {
      return ImageFormat.png;
    }
    return ImageFormat.jpeg;
  }

  void _setBusy({
    bool loading = false,
    bool converting = false,
    String? status,
  }) {
    isLoading = loading;
    isConverting = converting;
    statusMessage = status;
  }

  String _friendlyError(Object error) {
    if (error is UnsupportedError) {
      return error.message ?? 'That format is not supported yet.';
    }
    if (error is FormatException) {
      return error.message;
    }
    if (error is FileSystemException) {
      return error.message;
    }
    return 'Something went wrong while processing this image.';
  }
}
