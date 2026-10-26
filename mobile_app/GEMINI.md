# GEMINI.md — Flutter Client Engineering Standards & Guidelines

This document outlines the architectural principles, UI/UX conventions, formatting rules, and strict Test-Driven Development (TDD) standards for the **OmniDoc AI Flutter Mobile Client** (`mobile_app/`). All contributions and modifications must adhere to these guidelines.

---

## 1. Architecture & Folder Structure

We follow a **Feature-First Modular Pattern** (low-boilerplate, decoupled domain feature architecture). Every domain capability is encapsulated under `lib/features/<feature_name>/` using this standardized directory layout:

```text
lib/
├── core/
│   ├── theme/               # AppColors, AppTypography, ThemeData
│   └── utils/               # Shared utilities, AppFormatters (intl)
├── features/
│   └── <feature_name>/
│       ├── view/
│       │   ├── screens/     # Screen-level Scaffold widgets
│       │   └── widgets/     # Atomic, reusable UI components for this feature
│       ├── api/             # Direct HTTP / API client service calls
│       ├── repository/      # Repository models and data aggregation logic
│       │   └── models/      # Equatable data models
│       └── blocs/           # BLoC / Cubit state management (events, states, bloc)
└── main.dart                # Application entrypoint & multi-bloc providers
```

---

## 2. Mandatory Internationalization & Formatting Rules (`intl`)

> [!IMPORTANT]
> **Strict Rule:** ALL date, time, duration, percentage, and number formattings in the client MUST use the `intl` package (or the centralized `AppFormatters` utility backed by `intl`).
> **NEVER** use raw string concatenation, manual `.toString().padLeft(...)`, or unformatted string interpolation for numerical values, timestamps, or calendar dates.

### 2.1. Formatting Standards & `AppFormatters`
All formatting logic must use `lib/core/utils/app_formatters.dart` (or direct `intl` `DateFormat` / `NumberFormat` classes):

1. **Numbers & Decimals:**
   - Use `NumberFormat.decimalPattern()` or `AppFormatters.formatNumber(num)` (e.g. `3`, `1,500`).
2. **Percentages:**
   - Use `NumberFormat.percentPattern()` or `AppFormatters.formatPercent(num)` (e.g. `0.94` $\rightarrow$ `"94%"`).
3. **Plural Nouns & Item Counts:**
   - Use `AppFormatters.formatCountWithNoun(count, singular, [plural])` (e.g. `1 file`, `2 files`, `3 matches`).
4. **Time & Durations:**
   - Use `NumberFormat('00')` or `AppFormatters.formatDuration(seconds)` for padded `mm:ss` durations (e.g. `165` $\rightarrow$ `"02:45"`).
5. **Dates & Timestamps:**
   - Use `DateFormat` or `AppFormatters.formatDate(dateTime)` for calendar dates (e.g. `"Oct 14"`).
   - Use `DateFormat.jm()` or `AppFormatters.formatTime(dateTime)` for 12-hour AM/PM times (e.g. `"10:24 AM"`).
   - Normalize narrow non-breaking spaces (`\u202f` / `\u00a0`) to standard ASCII spaces in time formatters for cross-platform test deterministic matching.
6. **File Sizes:**
   - Use `NumberFormat('0.#')` or `AppFormatters.formatFileSizeInMb(megabytes)` (e.g. `"4.2 MB"`).

---

## 3. State Management & UI Conventions

1. **State Management:**
   - Use **BLoC / Cubit** (`flutter_bloc`) with immutable `Equatable` states.
   - Separate events (`<feature>_event.dart`), states (`<feature>_state.dart`), and logic (`<feature>_bloc.dart`).
   - Use `copyWith` for state emissions to maintain state immutability.
2. **UI & Styling:**
   - Use `const` constructors wherever possible to optimize Flutter build passes and minimize widget rebuilds.
   - Strictly bind colors and fonts to `AppColors` and `AppTypography`. Avoid ad-hoc inline colors or font styles.
   - Maintain responsive layouts constrained by mobile viewports (e.g. `maxWidth: 480` on centered desktop/tablet layouts).
   - Keep root-level navigation bars and Floating Action Buttons (FABs) cleanly docked on root `Scaffold` widgets.

---

## 4. Strict Test-Driven Development (TDD)

Every feature in `features/<feature>/` must have complete, mirror test coverage under `test/features/<feature>/`:

```text
test/
├── core/
│   └── utils/               # Unit tests for formatters and helper utilities
├── features/
│   └── <feature_name>/
│       ├── unit/            # Domain models, copyWith, Equatable, repositories
│       ├── api/             # Mocked API client tests using mocktail
│       ├── blocs/           # bloc_test streams, state transitions, event handling
│       ├── view/            # Widget rendering, taps, callbacks, user interactions
│       └── edge_cases/      # Empty lists, extreme inputs, boundary conditions
└── widget_test.dart         # End-to-end integration & navigation flow tests
```

### 4.1. TDD Rules
- **Red $\rightarrow$ Green $\rightarrow$ Refactor:** Write unit and widget tests concurrent with or prior to implementation.
- **Deterministic Mocks:** All tests must be 100% deterministic using `mocktail` — no live network calls or unconstrained timers.
- **Quality Gate:** Contributions are complete only when:
  1. `flutter test` passes with **100% success rate**.
  2. `flutter analyze` reports **0 issues (zero errors, zero warnings)**.
