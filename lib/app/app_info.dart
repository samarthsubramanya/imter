class AppInfo {
  const AppInfo._();

  static const name = 'Imter';
  static const version = '0.1.0';
  static const logoAsset = 'assets/branding/imter_logo.png';
  static const description = 'Local cross-platform desktop image conversion.';
}

class LibraryNotice {
  const LibraryNotice({
    required this.name,
    required this.version,
    required this.license,
    required this.role,
  });

  final String name;
  final String version;
  final String license;
  final String role;
}

const runtimeLibraries = [
  LibraryNotice(
    name: 'Flutter SDK',
    version: '3.38.6',
    license: 'BSD-3-Clause',
    role: 'Cross-platform desktop UI framework',
  ),
  LibraryNotice(
    name: 'Dart SDK',
    version: '3.10.7',
    license: 'BSD-3-Clause',
    role: 'Application language and runtime',
  ),
  LibraryNotice(
    name: 'image',
    version: '4.8.0',
    license: 'MIT',
    role: 'Local raster image decode, encode, and pixel analysis',
  ),
  LibraryNotice(
    name: 'ironpress',
    version: '0.2.0',
    license: 'MIT',
    role: 'Native WebP encoding through libwebp',
  ),
  LibraryNotice(
    name: 'flutter_avif',
    version: '3.1.0',
    license: 'MIT',
    role: 'Native AVIF decode and encode through libavif',
  ),
  LibraryNotice(
    name: 'file_selector',
    version: '1.1.0',
    license: 'BSD-3-Clause',
    role: 'Native open and save dialogs',
  ),
  LibraryNotice(
    name: 'desktop_drop',
    version: '0.7.1',
    license: 'Apache-2.0',
    role: 'Desktop drag-and-drop file intake',
  ),
  LibraryNotice(
    name: 'path',
    version: '1.9.1',
    license: 'BSD-3-Clause',
    role: 'Cross-platform path and filename handling',
  ),
];

const developmentLibraries = [
  LibraryNotice(
    name: 'flutter_lints',
    version: '6.0.0',
    license: 'BSD-3-Clause',
    role: 'Development lint rules',
  ),
];

const techStack = [
  'Flutter desktop for macOS, Windows, and Linux',
  'Dart and Material 3',
  'Local-only image processing with codec adapters',
  'Native desktop file dialogs and drag-and-drop plugins',
  'Flutter test and analyzer for verification',
];
