enum ImageFormat {
  jpeg(
    label: 'JPEG',
    extensions: ['jpg', 'jpeg'],
    mimeType: 'image/jpeg',
    supportsAlpha: false,
    supportsAnimation: false,
    lossy: true,
    bestFor: 'Photos, sharing, small files',
  ),
  png(
    label: 'PNG',
    extensions: ['png'],
    mimeType: 'image/png',
    supportsAlpha: true,
    supportsAnimation: false,
    lossy: false,
    bestFor: 'Transparency, screenshots, UI assets',
  ),
  webp(
    label: 'WebP',
    extensions: ['webp'],
    mimeType: 'image/webp',
    supportsAlpha: true,
    supportsAnimation: true,
    lossy: true,
    bestFor: 'Modern web and compact sharing',
  ),
  avif(
    label: 'AVIF',
    extensions: ['avif'],
    mimeType: 'image/avif',
    supportsAlpha: true,
    supportsAnimation: true,
    lossy: true,
    bestFor: 'Smallest modern web output',
  ),
  gif(
    label: 'GIF',
    extensions: ['gif'],
    mimeType: 'image/gif',
    supportsAlpha: true,
    supportsAnimation: true,
    lossy: false,
    bestFor: 'Simple animation, broad compatibility',
  ),
  tiff(
    label: 'TIFF',
    extensions: ['tif', 'tiff'],
    mimeType: 'image/tiff',
    supportsAlpha: true,
    supportsAnimation: false,
    lossy: false,
    bestFor: 'Archive and editing workflows',
  ),
  bmp(
    label: 'BMP',
    extensions: ['bmp'],
    mimeType: 'image/bmp',
    supportsAlpha: false,
    supportsAnimation: false,
    lossy: false,
    bestFor: 'Simple uncompressed bitmap use',
  ),
  ico(
    label: 'ICO',
    extensions: ['ico'],
    mimeType: 'image/x-icon',
    supportsAlpha: true,
    supportsAnimation: false,
    lossy: false,
    bestFor: 'App and website icons',
  );

  const ImageFormat({
    required this.label,
    required this.extensions,
    required this.mimeType,
    required this.supportsAlpha,
    required this.supportsAnimation,
    required this.lossy,
    required this.bestFor,
  });

  final String label;
  final List<String> extensions;
  final String mimeType;
  final bool supportsAlpha;
  final bool supportsAnimation;
  final bool lossy;
  final String bestFor;

  String get primaryExtension => extensions.first;

  static ImageFormat? fromExtension(String extension) {
    final normalized = extension.toLowerCase().replaceFirst('.', '');
    for (final format in ImageFormat.values) {
      if (format.extensions.contains(normalized)) {
        return format;
      }
    }
    return null;
  }
}
