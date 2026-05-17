# Imter

Imter, short for IMage convertER, is a fully local Flutter desktop image converter. The first build focuses on a single-image workflow with native file picking, drag-and-drop, approximate output-size comparison, format-specific controls, and a compact Learn section for image format tradeoffs.

## Current MVP

- Flutter desktop app for macOS, Windows, and Linux project targets.
- Local source loading for JPEG, PNG, WebP, AVIF, GIF, BMP, TIFF, and ICO.
- Conversion output for JPEG, PNG, WebP, AVIF, GIF, BMP, TIFF, and ICO.
- Approximate size estimates for JPEG, PNG, WebP, AVIF, GIF, TIFF, BMP, and ICO.
- WebP output is handled by `ironpress`; AVIF output is handled by `flutter_avif`.
- macOS file picker and drag-and-drop support through `file_selector` and `desktop_drop`.
- Product website lives in `website/` and builds to static Flutter web output.

## Development

```sh
flutter pub get
flutter analyze
flutter test
```

Run normally with:

```sh
flutter run -d macos
```

On this machine, Flutter currently asks Xcode for an `arm64` macOS destination while Xcode exposes the active destination differently. If that local toolchain mismatch appears, this direct Xcode build path works:

```sh
xcodebuild -workspace macos/Runner.xcworkspace -scheme Runner -configuration Debug -destination generic/platform=macOS build
```

The resulting debug app is created under Xcode DerivedData as `Imter.app`.

## macOS release artifact

The latest local release packages are:

```text
dist/macos/Imter-macOS-0.1.0-build1.dmg
dist/macos/Imter-macOS-0.1.0-build1.zip
```

They contain `Imter.app`, built from Flutter release mode for macOS. These local artifacts are signed to satisfy macOS local execution checks; distribution outside this machine still needs Developer ID signing and notarization.

## Design

The product and architecture plan is stored in [IMAGE_CONVERTER_DESIGN.md](IMAGE_CONVERTER_DESIGN.md).
