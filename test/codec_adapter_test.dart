import 'package:imter/domain/image_format.dart';
import 'package:imter/services/codec/dart_image_adapter.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('advertises WebP and AVIF codec support', () {
    final adapter = DartImageAdapter();

    expect(adapter.readableFormats, contains(ImageFormat.webp));
    expect(adapter.readableFormats, contains(ImageFormat.avif));
    expect(adapter.writableFormats, contains(ImageFormat.webp));
    expect(adapter.writableFormats, contains(ImageFormat.avif));
  });
}
