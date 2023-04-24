# Hit Studio

- **App:** `HitStudioApp` → `AppDependencies` (`environmentObject`).
- **Features:** `WelcomeScreen`, `MediaLibrary`, `ImageEditor`, `VectorCanvas`, `CubeScene`, `LoaderAnimation`.
- **Core:** `AppLogger`, `AnalyticsTracking` / `NoOpAnalytics`.
- **Navigation:** one `NavigationView` in `WelcomeView`; gallery / vector / editor use `dismiss()` instead of nested stacks.
- **Threading:** `EditImageViewModel` runs image work off the main queue, updates `@Published` on main.
- **Strings:** `Resources/en.lproj/Localizable.strings` (welcome + gallery).
- **Tests:** `HitStudioTests` (filters, resize/rotate, affine/unsharp/retouch, VM geometry, face, vector helpers, pipelines); `HitStudioUITests` (navigation, gallery→editor). UI seed: `-UITESTSeedGallery`.
