# Flatpak

Offline manifest generated with [flatpak-flutter](https://github.com/TheAppgineer/flatpak-flutter).

## Files

| File | |
| --- | --- |
| `flatpak-flutter.yml` | input template (edit this) |
| `dev.fredol.fred-tv-next.yml` | generated manifest (build this) |
| `generated/` | vendored pub/cargo sources, Flutter SDK, rustup (generated) |
| `modules/mpv.yml` | libmpv + deps from source, media_kit needs `pkg-config mpv` |
| `foreign.json` | points flatpak-flutter at Cargo.lock |
| `*.desktop`, `*.metainfo.xml` | shipped as local file sources |

## 1. Generate the manifest

Rerun when `pubspec.lock`, `Cargo.lock` or the Flutter tag change.

```sh
FLATPAK_FLUTTER_ROOT=~/git/flatpak-flutter \
  uv run --with packaging --with pyyaml --with tomlkit \
  python ~/git/flatpak-flutter/flatpak-flutter.py \
  --app-pubspec flutter --app-module open_tv flatpak-flutter.yml
```

## 2. Build

```sh
flatpak run org.flatpak.Builder \
  --force-clean --sandbox --user --install-deps-from=flathub \
  --repo=repo build-dir dev.fredol.fred-tv-next.yml
```

## 3. Generate the .flatpak

```sh
flatpak build-bundle repo fred-tv-next.flatpak dev.fredol.fred-tv-next \
  --runtime-repo=https://flathub.org/repo/flathub.flatpakrepo
```

## 4. Install the flatpak

```sh
flatpak install --user ./fred-tv-next.flatpak
```

CI (`.github/workflows/flatpak.yml`) does 2 and 3 and uploads the bundle as an artifact.
