# SpendSum Development Guidelines & Architecture Reference

This document outlines the architectural guidelines, coding styles, design patterns, and engineering principles followed in the **SpendSum** project.

---

## 1. Core Engineering Principles

We adhere strictly to standard software engineering best practices:

* **DRY (Don't Repeat Yourself)**: Eliminate duplicated logic by extracting shared utilities, constants, and widgets.
* **Separation of Concerns**: Each module must handle one distinct, well-defined responsibility.
* **Single Responsibility Principle (SRP)**: Every class, function, file, or module should have exactly one reason to change.
* **Clear Abstractions & Contracts**: Expose intent through small, stable interfaces and hide implementation details.
* **Low Coupling, High Cohesion**: Keep features and modules self-contained, minimizing direct cross-dependencies.
* **Scalability & Statelessness**: Design services to be stateless when possible and structure files to scale horizontally.
* **Observability & Testability**: Write testable components, use structured logging or diagnostics where necessary, and verify functionality via unit/widget tests.
* **KISS (Keep It Simple, Sir)**: Focus on clean, readable code and keep solutions as simple as possible.
* **YAGNI (You're Not Gonna Need It)**: Avoid speculative complexity or over-engineering features before they are required.

---

## 2. Architecture: Clean Architecture

SpendSum is organized using **Clean Architecture** patterns split by feature:

```
lib/
├── core/                  # Cross-cutting concerns
│   ├── common/            # Shared usecases, widgets, models
│   ├── routes/            # Navigation routing (GoRouter)
│   └── theme/             # Styling & design system tokens
│
└── features/              # Feature modules (e.g., onboarding, auth, dashboard)
    └── [feature_name]/
        ├── data/          # Data Layer (Models, Repositories implementations, Data Sources)
        ├── domain/        # Domain Layer (Entities, Use Cases, Repository interfaces)
        └── presentation/  # Presentation Layer (Widgets, Pages, Blocs)
```

### Dependency Rules:
1. **Presentation Layer** depends on **Domain Layer** (for Use Cases or Repository interfaces).
2. **Data Layer** implements interfaces defined in the **Domain Layer**.
3. **Domain Layer** is independent of external frameworks, libraries, and the UI.

---

## 3. Interface & Abstraction Naming Convention

To decouple implementations and facilitate unit testing (via mocking):
* Every repository and data source must define an **interface contract**.
* Interfaces must use the `I` prefix prefixing the ClassName (e.g., `IOnboardingRepository`).
* Concrete implementations should implement this interface directly (e.g., `class OnboardingRepository implements IOnboardingRepository`).

#### Example:
```dart
// Domain Layer Contract
abstract interface class IOnboardingRepository {
  bool get isOnboardingCompleted;
  Future<void> completeOnboarding();
}

// Data Layer Implementation
class OnboardingRepository implements IOnboardingRepository {
  final SharedPreferences sharedPreferences;
  OnboardingRepository(this.sharedPreferences);
  
  @override
  bool get isOnboardingCompleted => ...
}
```

---

## 4. Coding Style & Linting Guidelines

* Follow the official Dart style guide guidelines.
* Enable strict type checks in `analysis_options.yaml` (`strict-casts`, `strict-inference`, `strict-raw-types`).
* Ensure all files pass the `dart analyze` check cleanly.
* Document non-obvious helper logic and respect the standard codebase rules.

---

## 5. Theme & Color System

* **Do not hardcode raw hex values** in page layouts.
* Use colors from the current context theme (`Theme.of(context).colorScheme`) or the custom `AppThemeExtension` defined in `lib/core/theme/app_colors.dart`.
* Layout margins, vertical/horizontal spacings, and border radius shapes must use constants defined in `AppDimensions`.
