# Imter Website

Flutter web product site for Imter.

## Run locally

```sh
flutter pub get
flutter run -d chrome
```

## Build for Vercel or a root static host

```sh
flutter build web --release
```

Deploy `build/web`.

## Build for GitHub Pages

Use the repository name as the base href:

```sh
flutter build web --release --base-href /imter/
```

Deploy `build/web` to GitHub Pages.
