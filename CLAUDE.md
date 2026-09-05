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

## Comments

- Explain *why*, not *what*. The code should already say what it does.
- Don't leave commented-out dead code in the codebase — delete it; git
  history is where it belongs.
