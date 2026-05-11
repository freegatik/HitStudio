<p align="center">
  <img src="HitStudio/Assets.xcassets/AppIcon.appiconset/180.png" width="200" alt="Hit Studio">
</p>

# Hit Studio

![Static Badge](https://img.shields.io/badge/platform-iOS-white)
![Static Badge](https://img.shields.io/badge/latest_release-v1.0.0-green)
![Static Badge](https://img.shields.io/badge/swift-v5.0-orange)

[![CI](https://github.com/freegatik/HitStudio/actions/workflows/ci.yml/badge.svg)](https://github.com/freegatik/HitStudio/actions/workflows/ci.yml)

iOS app built with **SwiftUI** (Swift **5**, iOS **16.4** minimum). **Hit Studio** is an image playground: **welcome** flow, **media gallery**, **SwiftUI + UIKit hybrid editor** (filters, resize/rotate, affine transforms, unsharp mask, retouch, face-aware helpers), **vector canvas**, **cube scene**, and **loader** animations. Shared **`AppDependencies`** and light **analytics** hooks (**`AnalyticsTracking`** / **`NoOpAnalytics`**); **`AppLogger`** for logging. Feature map and threading notes: [Documentation/ARCHITECTURE.md](Documentation/ARCHITECTURE.md).

## CI

Workflow [`.github/workflows/ci.yml`](.github/workflows/ci.yml) on [GitHub Actions](https://github.com/freegatik/HitStudio/actions) for **`push`** to **`main`** / **`master`** and for **`pull_request`** (all branches).

| Step | What it runs |
|------|----------------|
| **Xcode** | Prefers **`/Applications/Xcode_15.4.app`**, falls back to **`Xcode.app`** via `xcode-select` |
| **Build & test** | `xcodebuild … test` on **`HitStudio`** / **`HitStudio.xcodeproj`**; destination **`${CI_DESTINATION:-platform=iOS Simulator,name=iPhone 15}`**; **`CODE_SIGN_IDENTITY=""`**, **`CODE_SIGNING_REQUIRED=NO`** |
| **SwiftLint** | Runs when the **`swiftlint`** binary exists on the runner; **`github-actions-logging`** reporter (otherwise prints skip message) |

There is no separate **SwiftLint** job badge: everything runs in one workflow file. For a pinned simulator OS locally or in scripts, see [`scripts/xcode-with-simulator.sh`](scripts/xcode-with-simulator.sh) (defaults to **`iPhone 16, OS=18.6`** — avoids **name + OS:latest** mismatches).

## Requirements

- **Xcode 15.4** (matches CI selection path when that app exists on the machine)
- **iOS 16.4+** simulator or device (deployment target in the project)

## Getting started

```bash
git clone https://github.com/freegatik/HitStudio.git
cd HitStudio
open HitStudio.xcodeproj
```

Use the **HitStudio** scheme: **⌘R** to run, **⌘U** for tests. Set your **Team** for device installs.

## Project layout

| Area | Path / notes |
|------|----------------|
| App entry | `HitStudio/HitStudioApp.swift`, `HitStudio/App/AppDependencies.swift` |
| Welcome | `HitStudio/WelcomeScreen/` |
| Gallery | `HitStudio/MediaLibrary/` |
| Image editor | `HitStudio/ImageEditor/` (SwiftUI + UIKit bridge, `EditImageViewModel`, filter models) |
| Vector & 3D | `HitStudio/VectorCanvas/`, `HitStudio/CubeScene/` |
| Loader demo | `HitStudio/LoaderAnimation/` |
| Core | `HitStudio/Core/` (`Logging`, `Analytics`) |
| Assets & copy | `HitStudio/Assets.xcassets/`, `HitStudio/Resources/en.lproj/Localizable.strings` |
| Unit tests | `HitStudioTests/` |
| UI tests | `HitStudioUITests/` (`UITestBase`, navigation, gallery editor) |
| Docs | `Documentation/ARCHITECTURE.md` |

## Testing

- **`HitStudioTests`** — filter models, geometry/affine/unsharp/retouch, **`EditImageViewModel`**, face + vector helpers, extended pipelines  
- **`HitStudioUITests`** — app navigation, gallery → editor; gallery seeding via **`-UITESTSeedGallery`** (see architecture doc)

Example (adjust destination to a simulator installed on your Mac):

```bash
xcodebuild test \
  -project HitStudio.xcodeproj \
  -scheme HitStudio \
  -destination 'platform=iOS Simulator,name=iPhone 15' \
  CODE_SIGN_IDENTITY="" \
  CODE_SIGNING_REQUIRED=NO
```

Or wrap **`scripts/xcode-with-simulator.sh`**:

```bash
chmod +x scripts/xcode-with-simulator.sh
./scripts/xcode-with-simulator.sh test CODE_SIGN_IDENTITY="" CODE_SIGNING_REQUIRED=NO
```

Lint (config is not **`--strict`** in CI, but you can run stricter locally):

```bash
swiftlint lint --config .swiftlint.yml
```

See [`.swiftlint.yml`](.swiftlint.yml) for included paths and rule tweaks.
