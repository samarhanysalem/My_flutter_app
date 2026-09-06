# Branding assets

Per-customer, swappable assets live in this folder. Nothing in `lib/` should
reference a customer's logo by any path other than
`AppConfig.logoAssetPath` (see `lib/config/app_config.dart`), so a rebrand
never means touching widget code.

## Files a new customer's build needs here

- `logo.png` — the app mark shown on auth screens and (later) splash/about
  screens, referenced via `AppConfig.logoAssetPath`. If this file is ever
  removed, `AppLogoMark` (`lib/common/widgets/app_logo_mark.dart`) falls
  back to a neutral icon, so the app still runs without it.
- `app_icon.png` — a square, min-1024x1024 source image for the native
  Android/iOS launcher icon. After replacing it, run
  `dart run flutter_launcher_icons` (config already in `pubspec.yaml`) to
  regenerate the native icon files — this is a one-time codegen step, not
  something read at runtime.

This folder is already declared under `flutter: assets:` in `pubspec.yaml`,
so swapping either file in place (same filename) is all a new customer's
build needs — no `pubspec.yaml` change required.

## Full white-label checklist for a new customer

Cross-reference against `docs/customer_brand_requirements_template.md` —
each field on that intake form maps to one of these steps.

1. **`lib/config/app_config.dart`** — `appName`, `displayName`,
   `companyName`, `primaryColor`, `accentColor`, `secondaryColor`/
   `tertiaryColor` (optional, if the customer's style guide has them),
   `fontFamily` (a Google Fonts family name — leave as-is unless the
   customer specifies one), `supportEmail`, `supportPhone`, and any
   `multipleClinicLocationsEnabled`-style feature toggle their engagement
   needs. This is the single file that drives branding/theme throughout the
   app (via `lib/theme/app_theme.dart`).
2. **`assets/branding/`** — drop in this customer's `logo.png` and
   `app_icon.png` (same filenames — already declared in `pubspec.yaml`),
   then run `flutter_launcher_icons` as described above.
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

A customer's store listing description, screenshots, and developer account
access (the intake form's "Store listing" section) are store-console/asset
work, not code changes — nothing in this repo needs to change for those.
Free-form "other customization" requests are inherently bespoke and get
scoped per engagement rather than pre-provisioned here.

Business logic (`AuthRepository`, Firestore document structure) is the same
for every customer and does not change as part of this checklist.
