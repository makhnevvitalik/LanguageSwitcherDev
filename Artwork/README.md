<!-- SPDX-FileCopyrightText: 2026 Vitalik Makhnev -->
<!-- SPDX-License-Identifier: MIT AND LicenseRef-Commons-Clause-1.0 -->

# Language Switcher artwork

The app and menu bar icons are original Language Switcher artwork. Edit the SVG source files in this directory, then regenerate the app icon PNGs with `rsvg-convert`:

```sh
for size in 16 32 64 128 256 512 1024; do
  rsvg-convert -w "$size" -h "$size" \
    -o "App/Assets.xcassets/AppIcon.appiconset/${size}-mac.png" \
    Artwork/LanguageSwitcherIcon.svg
done
```

`MenuBarIcon.svg` is also stored in `MenuBarIcon.imageset` as a monochrome template image so macOS can adapt it to the current menu bar appearance.
