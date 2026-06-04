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
│   ├── common/            # Shared usecases, widgets, models, global cubits
│   ├── database/          # Drift (SQLite) database and DAOs
│   ├── error/             # Global failures and exceptions
│   ├── router/            # Navigation routing (GoRouter)
│   └── theme/             # Styling & design system tokens
│
└── features/              # Feature modules (e.g., onboarding, auth, dashboard)
    └── [feature_name]/
        ├── data/          # Data Layer (Models, Repositories implementations, Data Sources)
        ├── domain/        # Domain Layer (Entities, Use Cases, Repository interfaces)
        └── presentation/  # Presentation Layer (Pages, Widgets, Cubits/Blocs)
```

### Layer Dependency Rules:
1. **Presentation Layer** depends on **Domain Layer** (for Use Cases or Repository interfaces).
2. **Data Layer** implements interfaces defined in the **Domain Layer**.
3. **Domain Layer** is independent of external frameworks, libraries, and UI dependencies.

---

## 3. Tech Stack & State Management Guidelines

### A. State Management (Bloc / Cubit)
* We use the `flutter_bloc` package for managing UI state.
* Logic-specific components should use `Cubit`s for simple state transformations and `Bloc`s for complex event streams.
* The UI interacts with state exclusively using `BlocBuilder` and handles one-off side-effects (e.g., navigation, dialogs, snackbars) using `BlocListener`.

### B. Database (Drift / SQLite)
* Local caching and transaction persistence are managed using `Drift`.
* Tables and relationships are defined in `lib/core/database/app_database.dart`.
* Use Drift's code-generator via `build_runner` to produce the underlying queries and typed entities.
* Default mock data should be seeded during the database initialization phase on first run (pre-populated with 57 sample transactions).

### C. Declarative Routing (GoRouter)
* All routes are defined inside `lib/core/router/app_router.dart` and `app_routes.dart`.
* Use GoRouter parameters and custom page animations (e.g., `SharedAxisTransition` from the `animations` package) to ensure a high-fidelity visual experience.

### D. Service Locator (GetIt Dependency Injection)
* All global instances, repositories, use cases, and blocs are registered via `GetIt` in `lib/app/dependency_injection.dart`.
* Direct constructors of concrete repositories or services should rarely be invoked inside widgets; use `sl<Type>()` instead.

---

## 4. Functional Error Handling (fpdart)

To ensure compile-time safety and eliminate unchecked runtime errors, repositories and use cases return the functional `Either` monad from the `fpdart` package:
* `Left(AppFailure)` represents a failed operation containing an error message.
* `Right(T)` represents a successful operation returning the typed result.

#### Example Repository Implementation:
```dart
@override
Future<Either<AppFailure, List<Category>>> getCategories({required bool isExpense}) async {
  try {
    final list = await localDataSource.getCategoriesByType(isExpense: isExpense);
    return Right(list);
  } on DatabaseException catch (e) {
    return Left(DatabaseFailure(e.message));
  } catch (e) {
    return Left(DatabaseFailure('Failed to load categories: $e'));
  }
}
```

---

## 5. Interface & Abstraction Naming Convention

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

## 6. Coding Style & Linting Guidelines

* Follow the official Dart style guide guidelines.
* Enable strict type checks in `analysis_options.yaml` (`strict-casts`, `strict-inference`, `strict-raw-types`).
* Ensure all files pass the `dart analyze` check cleanly.
* Document non-obvious helper logic and helper functions.

---

## 7. Theme & Color System

* **Do not hardcode raw hex values** in page layouts.
* Use colors from the current context theme (`Theme.of(context).colorScheme`) or the custom `AppThemeExtension` defined in `lib/core/theme/app_colors.dart`.
* Utilize context helper getters:
  - `context.theme` for retrieving the current `ThemeData`.
  - `context.colorscheme` for retrieving `AppThemeExtension` containing custom palette configurations.
* Layout margins, vertical/horizontal spacings, and border radius shapes must use constants defined in `AppDimensions`.

---

## 8. Testing Guidelines

* Tests must be placed in the `test/` directory, mirroring the structure of the `lib/` codebase (e.g., `test/features/[feature_name]/[domain/data/presentation]`).
* Mock dependencies by implementing lightweight, explicit stubs (like `FakeHomeRepository`) rather than generating heavy mock files when simple mock structures are sufficient.
* Usecase tests should use `Group` block structures and verify functional boundaries using `Either` folds (e.g., matching sorted list assertions alphabetically).
