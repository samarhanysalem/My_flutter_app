# Branding assets

Per-customer, swappable assets live in this folder. Nothing in `lib/` should
reference a customer's logo by any path other than
`AppConfig.logoAssetPath` (see `lib/config/app_config.dart`), so a rebrand
never means touching widget code.

## Files a new customer's build needs here

- `logo.png` — the app mark shown on auth screens and (later) splash/about
  screens, referenced via `AppConfig.logoAssetPath`. Until this file exists,
  `AppLogoMark` (`lib/common/widgets/app_logo_mark.dart`) falls back to a
  neutral icon, so the app still runs without it.
- A launcher/splash icon, once app-icon generation is wired up (not yet part
  of this refactor).

`logo.png` isn't declared under `flutter: assets:` in `pubspec.yaml` yet
because the file doesn't exist in this template. When a customer's logo is
added here, also add this folder to `pubspec.yaml`'s `assets:` list:

```yaml
flutter:
  assets:
    - assets/branding/
```

## Full white-label checklist for a new customer

1. **`lib/config/app_config.dart`** — `appName`, `displayName`,
   `companyName`, `primaryColor`, `accentColor`, `supportEmail`,
   `supportPhone`. This is the single file that drives branding/theme
   throughout the app (via `lib/theme/app_theme.dart`).
2. **`assets/branding/`** — drop in this customer's `logo.png` (and add the
   `pubspec.yaml` entry above).
3. **`lib/firebase_options.dart`** — regenerate with `flutterfire configure`
   against this customer's own Firebase project. Every customer gets a
   separate Firebase project; auth/Firestore data must never share a
   project across customers.
4. **Package name / bundle ID** — for store listings, update:
   - Android: `applicationId` in `android/app/build.gradle`.
   - iOS: the bundle identifier in `ios/Runner.xcodeproj` (or via Xcode).
   - Also update the native app display name (Android
     `AndroidManifest.xml`'s `android:label`, iOS `Info.plist`'s
     `CFBundleDisplayName`, `web/manifest.json`, `web/index.html`) to match
     `AppConfig.displayName` — these are compiled into the native shell and
     can't be read from Dart config at runtime.

Business logic (`AuthRepository`, Firestore document structure) is the same
for every customer and does not change as part of this checklist.
