`# Repository Guidelines

## Project Structure & Module Organization
- `lib/` holds application code; group features by domain (`lib/features/rides/`, `lib/features/auth/`) and keep shared widgets under `lib/shared/`.
- `test/` stores unit and widget tests mirroring the `lib/` tree with matching filenames (`ride_summary_test.dart` for `ride_summary.dart`).
- Platform wrappers live in `android/`, `ios/`, and `web/`; update them only when platform-specific configuration changes.
- Design assets and static files should sit under `web/assets/` or a dedicated `assets/` folder declared in `pubspec.yaml`.

## Build, Test, and Development Commands
- `flutter pub get` installs or updates dependencies; run after editing `pubspec.yaml`.
- `flutter analyze` enforces the analyzer rules from `analysis_options.yaml` before pushing.
- `flutter test` runs all unit and widget tests in `test/` and should stay green before you open a PR.
- `flutter run -d chrome` or `flutter run -d android` launches the app locally; prefer hot reload for iterative UI work.
- `flutter build apk --release` (or `flutter build ios --release`) produces distributable binaries; reserve for release branches.
- note all minor and major changes to `plan_breakdown.md`

## Coding Style & Naming Conventions
- Follow the `flutter_lints` ruleset; the analyzer already reports violations for you.
- Use two-space indentation, `PascalCase` for types, `camelCase` for variables/functions, and `SCREAMING_SNAKE_CASE` for compile-time constants.
- Keep files focused: one public class or widget per file, and suffix widgets with `Widget` (e.g., `RideSummaryWidget`).
- Format code via `dart format lib test` before committing; avoid committing analyzer ignores without justification.

## Testing Guidelines
- Add a `*_test.dart` alongside each new Dart module; prefer widget tests for UI and pure unit tests for services/utilities.
- Target at least 80% coverage for new features; document intentional gaps in the PR description.
- Use descriptive `group`/`test` names (`'RideSummaryWidget renders pickup info'`) and arrange tests with Given/When/Then comments.
- For integration scenarios, scaffold `integration_test/` using Flutter's integration tooling and gate it behind optional CI jobs.

## Commit & Pull Request Guidelines
- Write commits in Conventional Commits style (`feat: add ride summary widget`, `fix: correct fare rounding`) with clear, present-tense bodies when necessary.
- Squash WIP commits before opening a PR; ensure each commit passes `flutter analyze` and `flutter test`.
- PR descriptions should outline the change, list verification steps, and link to tracking issues; include screenshots or screen recordings for UI updates.
- Assign at least one reviewer, request platform review for changes under `android/` or `ios/`, and wait for green CI before merging.
