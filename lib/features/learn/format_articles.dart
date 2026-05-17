import '../../domain/image_format.dart';

class FormatArticle {
  const FormatArticle({
    required this.format,
    required this.summary,
    required this.bestFor,
    required this.watchOutFor,
    required this.recommendedSettings,
  });

  final ImageFormat format;
  final String summary;
  final String bestFor;
  final String watchOutFor;
  final String recommendedSettings;
}

const formatArticles = [
  FormatArticle(
    format: ImageFormat.jpeg,
    summary:
        'A lossy photo format focused on small files and broad compatibility.',
    bestFor:
        'Photos, web uploads, email attachments, and sharing where transparency is not needed.',
    watchOutFor:
        'Repeated saves reduce quality. JPEG cannot preserve transparent pixels.',
    recommendedSettings:
        'Use quality 80-90 for everyday photos, lower only when file size matters more.',
  ),
  FormatArticle(
    format: ImageFormat.png,
    summary: 'A lossless format with strong transparency support.',
    bestFor:
        'Screenshots, UI assets, diagrams, logos, and images that need crisp edges or alpha.',
    watchOutFor:
        'PNG can be much larger than JPEG or WebP for photographic images.',
    recommendedSettings:
        'Use balanced or max compression. Keep PNG when transparency matters.',
  ),
  FormatArticle(
    format: ImageFormat.webp,
    summary:
        'A modern web format with lossy, lossless, transparency, and animation support.',
    bestFor: 'Web publishing and compact sharing when target apps support it.',
    watchOutFor: 'Some older workflows still expect JPEG or PNG.',
    recommendedSettings:
        'Use lossy quality 75-85 for photos, lossless for transparent UI assets.',
  ),
  FormatArticle(
    format: ImageFormat.avif,
    summary: 'A high-compression modern format based on AV1 image coding.',
    bestFor: 'Very small web images where slower encoding is acceptable.',
    watchOutFor:
        'Encoding can be slow and compatibility is still less universal than JPEG or PNG.',
    recommendedSettings:
        'Start around quality 65-80. Increase effort when you can wait for smaller output.',
  ),
  FormatArticle(
    format: ImageFormat.gif,
    summary: 'A palette-based format best known for simple animations.',
    bestFor: 'Small animations, simple graphics, and legacy compatibility.',
    watchOutFor:
        'GIF is limited to 256 colors per frame and is poor for detailed photos.',
    recommendedSettings:
        'Use smaller palettes for flat graphics and dithering for smoother gradients.',
  ),
  FormatArticle(
    format: ImageFormat.tiff,
    summary:
        'A flexible container often used in archival and editing workflows.',
    bestFor: 'Scanning, intermediate editing, and preservation workflows.',
    watchOutFor:
        'TIFF files can be very large and are not ideal for casual sharing.',
    recommendedSettings:
        'Use TIFF when editability matters more than file size.',
  ),
  FormatArticle(
    format: ImageFormat.bmp,
    summary: 'A simple bitmap format that is usually uncompressed.',
    bestFor: 'Legacy Windows workflows or simple pixel interchange.',
    watchOutFor:
        'BMP files are commonly much larger than equivalent PNG files.',
    recommendedSettings:
        'Only choose BMP when another tool specifically requires it.',
  ),
  FormatArticle(
    format: ImageFormat.ico,
    summary: 'An icon container that can hold multiple square sizes.',
    bestFor: 'Application icons, shortcuts, and website favicon workflows.',
    watchOutFor:
        'Source artwork should be square and readable at very small sizes.',
    recommendedSettings:
        'Prepare a square source and include common sizes like 16, 32, 48, 128, and 256.',
  ),
];
