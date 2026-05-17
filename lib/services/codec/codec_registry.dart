import 'dart:typed_data';

import 'package:image/image.dart' as img;

import '../../domain/conversion_options.dart';
import '../../domain/image_format.dart';
import 'image_codec_adapter.dart';

class CodecRegistry {
  CodecRegistry(this._adapters);

  final List<ImageCodecAdapter> _adapters;

  Set<ImageFormat> get readableFormats => {
    for (final adapter in _adapters) ...adapter.readableFormats,
  };

  Set<ImageFormat> get writableFormats => {
    for (final adapter in _adapters) ...adapter.writableFormats,
  };

  bool canRead(ImageFormat format) => readableFormats.contains(format);

  bool canWrite(ImageFormat format) => writableFormats.contains(format);

  Future<img.Image> decode(Uint8List bytes, ImageFormat format) {
    final adapter = _adapters
        .where((it) => it.readableFormats.contains(format))
        .firstOrNull;
    if (adapter == null) {
      throw UnsupportedError('${format.label} input is not supported yet.');
    }
    return adapter.decode(bytes, format);
  }

  Future<Uint8List> encode(
    img.Image image,
    ImageFormat targetFormat,
    ConversionOptions options,
  ) {
    final adapter = _adapters
        .where((it) => it.writableFormats.contains(targetFormat))
        .firstOrNull;
    if (adapter == null) {
      throw UnsupportedError(
        '${targetFormat.label} output needs a native codec adapter.',
      );
    }
    return adapter.encode(image, targetFormat, options);
  }
}
