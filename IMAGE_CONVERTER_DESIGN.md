# Local Image Converter Desktop App Design

Date: 2026-05-14

## Product Direction

Build a fully local, cross-platform desktop app for converting popular raster image formats with a polished workflow, clear quality controls, approximate output-size comparisons, and a built-in learning section about file formats.

The app should feel like a serious utility: fast to understand, predictable under pressure, visually calm, and transparent about tradeoffs. The first version should handle one image at a time. Batch conversion is intentionally deferred but designed for.

## Platform Choice

Use Flutter for Windows, macOS, and Linux desktop. Flutter officially supports compiling native desktop apps for these platforms, and its desktop plugin ecosystem is good enough for native file selection, drag-and-drop, and local filesystem output.

## Core Principles

- Fully offline: no upload, no cloud conversion, no telemetry required.
- Single-image v1: one focused conversion path before batch workflows.
- Codec adapters: every encoder/decoder sits behind a small interface so format support can grow without rewriting UI.
- Honest estimates: predicted sizes are labeled approximate until the final encoded output exists.
- No hidden magic: controls should explain consequences through UI labels and format education, not through modal lectures.
- Lightweight first: prefer pure Dart libraries where quality is sufficient; use native codecs only where necessary.

## V1 Supported Formats

### Recommended V1 Input Formats

- JPEG / JPG
- PNG
- WebP
- GIF
- BMP
- TIFF
- ICO
- AVIF, if the native plugin proof is stable enough

### Recommended V1 Output Formats

- JPEG / JPG
- PNG
- GIF
- BMP
- TIFF
- ICO
- WebP, through a native libwebp-backed adapter
- AVIF, through a native libavif-backed adapter if packaging remains reasonable

### Important Format Notes

The Dart `image` package is a strong core dependency because it supports read/write for JPG, PNG, GIF, BMP, TIFF, TGA, PVR, and ICO, and read-only support for WebP, PSD, EXR, and PNM. Since WebP output is not covered by that package, WebP encoding needs a separate adapter.

AVIF should not be built into the core conversion path until packaging and platform behavior are verified. The `flutter_avif` package provides AVIF viewing, decoding, and encoding via libavif across desktop platforms, but it is a heavier and less battle-tested dependency than the pure Dart core.

## Explicit Non-Goals For V1

- Batch conversion
- Folder conversion
- SVG, PDF, or camera RAW support
- Cloud conversion
- Advanced photo editing
- Animated image preservation across all formats
- Color-managed professional print workflows

For animated GIF, animated WebP, or animated AVIF input, v1 should either:

- Convert the first frame only with a visible note, or
- Disable unsupported output choices with a clear reason.

The first-frame-only path is simpler, but the UI must be explicit so users do not accidentally lose animation.

## User Experience

### Main Navigation

Use a two-section layout:

- Convert
- Learn

The default screen opens directly to Convert. No marketing landing page.

### Convert Flow

1. Select source
   - Large drop zone for drag-and-drop.
   - Secondary `Choose Image` button using the native file picker.
   - Accept only supported raster extensions.

2. Inspect source
   - Show image preview.
   - Show source metadata: filename, current format, dimensions, file size, transparency, animation/static status, color depth when available.
   - Show a privacy/local indicator: "Processed locally".

3. Compare outputs
   - Present output formats as a comparison table or segmented cards.
   - Each row/card includes:
     - Format name
     - Approximate output size
     - Relative size change
     - Key traits: lossy/lossless, transparency, animation, compatibility
     - Suitability hint: web, archive, icon, sharing, editing
   - Mark estimates as approximate until conversion is complete.

4. Tune conversion
   - Selecting a format reveals format-specific controls.
   - Controls update the size estimates live.
   - Show warnings inline when conversion has consequences, such as transparency loss when exporting to JPEG.

5. Save output
   - Use native save dialog.
   - Suggested filename follows `{original-name}.{target-extension}`.
   - Conversion runs on a background isolate or native worker.
   - Show progress, cancel, and final actual file size.

6. Result
   - Show completed output path, actual size, and percent change.
   - Provide `Convert another` and `Reveal in folder` actions where platform support is available.

## Conversion Controls

### Shared Controls

- Resize: original size, width/height, percentage, maintain aspect ratio
- Metadata: strip metadata by default, preserve metadata where supported
- Transparency handling: preserve when supported, choose matte color when exporting to non-alpha formats
- Background color: enabled for JPEG/BMP or other non-alpha output
- Overwrite behavior: ask, auto-rename, or replace

### JPEG

- Quality: 1-100, default 85
- Progressive: on/off where supported
- Chroma subsampling: auto, 4:4:4, 4:2:0 if supported by the selected adapter
- Matte color when source has alpha

### PNG

- Compression level: low, balanced, max
- Preserve alpha
- Optional palette reduction later

### WebP

- Mode: lossy or lossless
- Quality: 1-100 for lossy
- Effort/speed if supported by adapter
- Preserve alpha

### AVIF

- Quality: 1-100
- Speed/effort: faster to smaller
- Lossless toggle if adapter supports it
- Preserve alpha

### GIF

- Palette size: 2-256
- Dithering: off, light, strong
- Static image output for v1 unless animation support is explicitly added later

### TIFF

- Compression: none, LZW/deflate where supported
- Preserve alpha when supported
- Intended-use hint: archive/editing, not smallest web output

### BMP

- Bit depth: 24-bit or 32-bit if supported
- Warn that output is usually large

### ICO

- Icon sizes: 16, 32, 48, 64, 128, 256
- Multi-size ICO output if supported
- Square crop/fit mode: contain, cover, center

## Size Estimation Design

The estimate engine should be fast and deterministic. It does not need to encode every candidate format in the background for v1.

### Inputs

- Width and height
- Source file size
- Source format
- Alpha channel presence and alpha coverage
- Estimated visual complexity from downsampled pixels
- Approximate unique color count from a sampled image
- Selected quality/compression settings

### Complexity Sampling

Decode the image, downsample to a small grid such as 128x128, then compute:

- Luminance variance
- Edge density from adjacent pixel differences
- Alpha coverage ratio
- Approximate color variety using a coarse histogram

These features produce a complexity score from 0.0 to 1.0.

### Format Estimate Rules

- BMP: mostly deterministic from dimensions and bit depth plus header overhead.
- PNG: estimate from raw bytes, color variety, alpha coverage, and compression level.
- JPEG: estimate from megapixels, quality, and complexity; alpha requires matte compositing first.
- WebP: similar to JPEG for lossy mode, lower multiplier at the same visual quality; lossless behaves closer to PNG.
- AVIF: similar to WebP but with stronger compression and slower encoding; estimate should be conservative.
- GIF: estimate from dimensions and palette size; warn when source has many colors.
- TIFF: estimate by compression mode; uncompressed is close to raw pixel size.
- ICO: estimate as the sum of encoded icon images for selected sizes.

### UI Language

Always label predicted sizes as `Approx.`. After conversion, replace the selected output estimate with `Actual`.

## Architecture

Use a feature-oriented Flutter structure:

```text
lib/
  main.dart
  app/
    app.dart
    theme.dart
    routes.dart
  features/
    converter/
      converter_screen.dart
      converter_controller.dart
      widgets/
        source_drop_zone.dart
        source_inspector.dart
        format_comparison.dart
        conversion_controls.dart
        conversion_result.dart
    learn/
      learn_screen.dart
      format_articles.dart
  domain/
    image_format.dart
    image_metadata.dart
    conversion_options.dart
    size_estimate.dart
  services/
    codec/
      codec_registry.dart
      image_codec_adapter.dart
      dart_image_adapter.dart
      webp_adapter.dart
      avif_adapter.dart
    files/
      file_picker_service.dart
      output_path_service.dart
    estimate/
      image_analyzer.dart
      size_estimator.dart
```

### Core Interfaces

```dart
abstract interface class ImageCodecAdapter {
  Set<ImageFormat> get readableFormats;
  Set<ImageFormat> get writableFormats;

  Future<DecodedImage> decode(Uint8List bytes, ImageFormat format);
  Future<Uint8List> encode(
    DecodedImage image,
    ImageFormat targetFormat,
    ConversionOptions options,
  );
}
```

The UI should never call a concrete codec directly. It asks `CodecRegistry` whether a source and target format pair is supported, then runs the selected adapter.

### Threading Model

- UI stays on the main isolate.
- Decode, analyze, estimate, and encode run off the main isolate when using pure Dart.
- Native FFI encoders must expose cancellable or at least safely isolated work where possible.
- Large images should stream status updates: reading, decoding, analyzing, encoding, writing.

### State Management

Keep v1 simple:

- `ChangeNotifier` or `ValueNotifier` is enough for the first build.
- Move to Riverpod only if conversion state becomes meaningfully more complex.

## Dependency Plan

Recommended starting dependencies:

- `image`: core pure Dart decode/encode for many raster formats.
- `file_selector`: native file open/save dialogs.
- `desktop_drop`: drag-and-drop input on desktop.
- `path`: output filename and extension handling.

Conditional or proof-of-concept dependencies:

- WebP encoder adapter using libwebp through a maintained package or small native FFI wrapper.
- AVIF adapter using `flutter_avif` only after a platform packaging test.

Avoid pulling in ImageMagick/GraphicsMagick for v1. Those are powerful, but they make distribution heavier and can turn the app into a wrapper around a large external toolchain.

## Learn Section

The Learn section should be a compact reference library, not a tutorial wall.

Each format article should include:

- What it is best for
- Compression type: lossy, lossless, or both
- Transparency support
- Animation support
- Typical file-size behavior
- Compatibility notes
- Recommended settings
- Common mistakes

Initial articles:

- JPEG: best for photos; no transparency; quality tradeoff.
- PNG: best for transparency, screenshots, UI assets; often larger for photos.
- WebP: modern web sharing; lossy/lossless; transparency; good size savings.
- AVIF: strong compression; slower encoding; compatibility still worth checking.
- GIF: simple animation and broad compatibility; poor for rich photos.
- TIFF: archival/editing workflows; can be very large.
- BMP: simple uncompressed bitmap; usually large.
- ICO: application and website icons with multiple embedded sizes.

The Learn section should also integrate with Convert: selecting a format can show a short "Why choose this?" panel beside controls.

## Visual Design Direction

- Desktop-first layout with responsive behavior for small windows.
- Left rail or top tabs for Convert/Learn.
- Convert screen uses a practical three-panel flow:
  - Source and preview
  - Output comparison
  - Controls and result
- Prefer crisp controls, clear spacing, and quiet color.
- Use format badges sparingly.
- No marketing hero, no decorative gradients, no oversized cards.
- The drop zone should be obvious but not cartoonish.

## Error Handling

Common errors need friendly, precise messages:

- Unsupported input format
- Corrupt image
- Animated image unsupported for selected output
- Transparency would be lost
- File write permission denied
- Output path already exists
- Native codec unavailable
- Image too large for available memory

Errors should explain what happened and offer a next action when possible.

## Testing Plan

### Unit Tests

- Format detection from extension and magic bytes
- Codec registry support matrix
- Size estimation sanity ranges
- Conversion option validation
- Output filename generation

### Golden/UI Tests

- Empty state
- Loaded source
- Format comparison table
- Format-specific controls
- Conversion success
- Conversion failure
- Learn section format article

### Integration Fixtures

Keep small sample images in test fixtures:

- Photo JPEG
- Transparent PNG
- Screenshot PNG
- Static GIF
- BMP
- TIFF
- ICO
- WebP
- AVIF if enabled

### Manual QA

- macOS, Windows, and Linux launch
- Drag-and-drop
- Native file picker
- Save dialog
- Large image responsiveness
- Offline behavior with network disabled

## Implementation Roadmap

### Milestone 1: Flutter Shell

- Create Flutter desktop app.
- Add app theme and navigation.
- Build Convert and Learn screens with static data.

### Milestone 2: Source Intake

- Add file picker.
- Add drag-and-drop.
- Detect source format.
- Decode source metadata.
- Render preview.

### Milestone 3: Size Estimates

- Implement image analyzer.
- Implement estimator.
- Display approximate size matrix for all target formats.

### Milestone 4: Core Conversion

- Add `image`-based adapter.
- Support JPEG, PNG, GIF, BMP, TIFF, and ICO output where practical.
- Add save flow and actual-size result.

### Milestone 5: WebP and AVIF Proofs

- Prototype WebP native adapter.
- Prototype AVIF adapter.
- Verify packaging on macOS, Windows, and Linux before making either default.

### Milestone 6: Polish

- Add conversion cancellation.
- Improve warnings.
- Add Learn articles.
- Add tests and fixtures.

## Saved V2 Backlog

Batch conversion should be implemented after the single-file flow is stable.

Planned batch features:

- Multi-file picker
- Folder input
- Drag multiple files
- Shared output preset
- Per-file support warnings
- Batch progress queue
- Pause/cancel
- Auto-rename rules
- Output folder selector
- Summary report with successes, failures, and total size saved

Future advanced features:

- Preset profiles: web, email, archive, app icon, transparent asset
- Target file size mode
- Before/after visual comparison
- Metadata viewer/editor
- Color profile handling
- Animated image preservation
- Optional command-line interface

## Open Decisions Before Implementation

- Final app name.
- Whether AVIF is mandatory in v1 or allowed as an experimental adapter.
- Whether WebP encoding should rely on a packaged native library or a user-installed system library.
- Whether v1 should preserve EXIF metadata when possible or strip by default.
- Whether app distribution should target unsigned local builds first or packaged installers.

## References Checked

- Flutter desktop support: https://docs.flutter.dev/platform-integration/desktop
- Dart `image` package support matrix: https://pub.dev/packages/image
- `file_selector` package: https://pub.dev/packages/file_selector
- `desktop_drop` package: https://pub.dev/packages/desktop_drop
- `flutter_avif` package: https://pub.dev/packages/flutter_avif
