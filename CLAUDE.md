# CLAUDE.md

Flutter best-practice rules for this project. Follow these when writing or
reviewing code here.

## Project structure

Feature-first, not layer-first. Each feature owns its own view, widgets,
models, and services:

```
lib/
  features/
    <feature>/
      view/
      widgets/
      models/
      services/
```

Don't create top-level `lib/views/`, `lib/models/`, `lib/services/`
directories that span multiple features — each feature is self-contained.
Code shared across features (common widgets, utilities) lives under
`lib/common/` or `lib/shared/`, not inside a feature folder.

## State management

Use `package:provider` consistently across the app. Do not mix in Bloc,
Riverpod, GetX, or other state management approaches.

- Mutable state lives in a `ChangeNotifier` subclass.
- Expose it to the widget tree with `ChangeNotifierProvider`.
- Consume it with `Consumer`, `Selector`, or `context.watch<T>()`.
- Use `context.read<T>()` for one-off calls (e.g. inside callbacks) —
  never `watch` outside `build`.

## Widget rules

- Keep widgets small and single-purpose. If a `build` method is doing more
  than one visually distinct thing, extract a widget.
- Prefer composition over deep nesting: extract reusable widgets rather than
  inlining large widget trees.
- Prefer `StatelessWidget` combined with Provider for state over
  `StatefulWidget`. Only reach for `StatefulWidget` when the state is truly
  local and ephemeral (e.g. animation controllers, text field focus) and
  doesn't belong in a `ChangeNotifier`.

## Naming

- Classes and widgets: `PascalCase`.
- Variables and methods: `camelCase`.
- File names: `snake_case`, matching the primary class they contain
  (e.g. `UserProfileView` lives in `user_profile_view.dart`).

## Null safety

- No unnecessary `!`. If you find yourself reaching for `!`, first check
  whether the null case can be handled properly instead.
- Prefer explicit null checks (`if (value != null)`) or `??` /
  `??=` over force-unwrapping.

## Async

- Use `async`/`await`. Don't chain raw `Future`s with `.then()`.
- Wrap async work in `try/catch` and surface failures as user-facing error
  states (e.g. an error widget, a snackbar, an error field on a
  `ChangeNotifier`) — never fail silently.

## Linting

- `flutter_lints` is enabled via `analysis_options.yaml`. Do not weaken it.
- Run `flutter analyze` before committing and treat any warning as a
  blocker — fix it, don't ignore it.

## Testing

- New UI requires a widget test.
- Business logic — especially `ChangeNotifier` classes — requires a unit
  test covering its state transitions.

## Performance

- Use `const` constructors wherever a widget's inputs are compile-time
  constant.
- Scope `Consumer`/`Selector` as narrowly as possible around the subtree
  that actually needs to rebuild — don't wrap large widget trees in a
  `Consumer` when only a small part depends on the state.
- Use `ListView.builder` (or other builder-based list widgets) for lists,
  never manually map a full list into a non-lazy `Column`/`ListView`.

## Responsive design

The app ships to web (GitHub Pages), Android, and iOS, so layouts must adapt
across phone, tablet, and desktop/web viewport widths — not just the phone
size the widget was built against.

- Don't hardcode pixel widths/heights for layout. Use `MediaQuery`,
  `LayoutBuilder`, or relative sizing instead of fixed `SizedBox`/`Container`
  dimensions for anything that should adapt to the viewport.
- Prefer flexible layout widgets (`Expanded`, `Flexible`, `Wrap`,
  `FractionallySizedBox`) over fixed-size children when content should grow
  or shrink with available space.
- Use `LayoutBuilder` or `MediaQuery.sizeOf(context).width` to switch between
  a single-column (phone) and multi-column (tablet/web) layout where a
  screen's content warrants it.
- Cap content width on wide viewports (e.g. a `ConstrainedBox` with
  `maxWidth`) rather than letting text, forms, or cards stretch edge-to-edge
  on desktop/web. **A `maxWidth` cap on its own is not enough** — a
  `ConstrainedBox`/`SizedBox` with a `maxWidth` sitting directly inside a
  `SingleChildScrollView`, `Column`, or `Padding` is left-aligned by
  default, not centered. Always wrap it in `Center` (or an equivalent
  alignment) so capped content sits in the middle of the extra space on a
  wide viewport instead of being stranded against one edge — this exact
  bug shipped once already (auth screens looked fine on phone widths, then
  sat flush-left with a large dead area on a tablet/desktop viewport)
  because the cap was added without the `Center`.
- Check new screens at multiple sizes — phone, tablet, and a wide web
  viewport — before considering the UI done. Specifically look for content
  stuck to one edge with unused space elsewhere at tablet/desktop widths;
  that's the signature of a missing `Center` around capped-width content.

## White-label / branding rules

This app is sold as a customizable template to multiple customers. Keeping
branding and business logic strictly separated is what makes rebranding for
a new customer a small, safe change instead of a re-audit of the codebase.

- All customer-specific values MUST go through `lib/config/app_config.dart`
  — never hardcode app name, company name, colors, or asset paths directly
  in widget files.
- All colors, typography, spacing, and corner radius MUST come from
  `lib/theme/app_theme.dart`, which itself reads from `AppConfig`. Do not
  define colors or text styles inline in widgets.
- Any new asset (logo, icons, images) that could vary per customer goes in
  `assets/branding/`, not `assets/images/` or similar generic folders.
- Business logic (`AuthService`, `AppointmentService`, Firestore structure,
  Firebase config) is shared code and must stay separate from branding —
  never add customer-specific conditionals into service/logic files.
- Before adding any new screen, check `app_config.dart` and `app_theme.dart`
  first and reuse existing values rather than introducing new hardcoded
  ones.

## Comments

- Explain *why*, not *what*. The code should already say what it does.
- Don't leave commented-out dead code in the codebase — delete it; git
  history is where it belongs.
