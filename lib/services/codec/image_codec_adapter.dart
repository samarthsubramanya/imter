import 'dart:typed_data';

import 'package:image/image.dart' as img;

import '../../domain/conversion_options.dart';
import '../../domain/image_format.dart';

abstract interface class ImageCodecAdapter {
  Set<ImageFormat> get readableFormats;
  Set<ImageFormat> get writableFormats;

  Future<img.Image> decode(Uint8List bytes, ImageFormat format);

  Future<Uint8List> encode(
    img.Image image,
    ImageFormat targetFormat,
    ConversionOptions options,
  );
}
