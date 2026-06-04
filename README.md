# SpendSum — Elegant Expense Tracking & Spend Summary

SpendSum is a premium, high-fidelity Flutter application designed to give users a beautiful, intuitive, and fluid interface for tracking expenses, managing categories, and viewing monthly spend summaries.

Tested and designed with meticulous attention to detail, the app implements standard software engineering practices (DRY, Clean Architecture, SOLID, and low coupling) to deliver a polished experience.

---

## 🎨 Design Inspiration & UI Screenshots

### UI Design Inspiration (Dribbble References)
The visual aesthetics, typography layout, glassmorphic card stylings, and transitions were inspired by high-fidelity design concepts from Dribbble. The reference assets used during planning are:

| Dribbble Reference 1 | Dribbble Reference 2 | Dribbble Reference 3 |
|---|---|---|
| ![Inspiration 1](assets/inspiration/img1.png) | ![Inspiration 2](assets/inspiration/img2.png) | ![Inspiration 3](assets/inspiration/img3.png) |

---

### Developed App Screenshots (Tested on Emulator)
*Replace the placeholders below with screenshots of your running app on the emulator:*

| Light Theme — Spend Summary | Dark Theme — Spend Summary |
|---|---|
| *[Add Light Theme Screenshot]* | *[Add Dark Theme Screenshot]* |

---

## 📋 Take-Home Assignment Checklist

Here is the status of the required features outlined in the assignment email:

- [x] **Monthly Spend Header Card**: A full-width, gradient-accented card showing the total monthly spend and an interactive comparison pill showing the percentage change against last month's spend (e.g. `12% less than last month`).
- [x] **Horizontal Category Scroll**: A horizontal carousel displaying spending categories (Food, Travel, Shopping, Groceries, Bills, etc.) along with their corresponding icons, customized background colors, and aggregated spend amounts for the current month.
- [x] **Recent Transactions List**: A list of recent transactions (6 items shown directly on the dashboard, satisfying the 5-7 items requirement) with swipe-to-delete functionality and an undo toast indicator.
- [x] **Floating Action Button (FAB)**: Relocated to the bottom right of the page floating cleanly above the BottomNavigationBar, facilitating single-handed reach.
- [x] **Mock/Hardcoded Data (57 Items)**: The local SQLite database is pre-seeded on first run with exactly 57 sample transactions distributed across categories, incomes, and expenses to show a realistic dashboard.
- [x] **AI Tools Usage Note**: Documented below in this README.

---

## 🛠️ Architecture & Technology Stack

The project follows a modular **Clean Architecture** structure:

```
lib/
├── core/                  # Shared utilities, router, database, and theme
│   ├── common/            # Shared widgets and global cubits
│   ├── database/          # SQLite database via Drift
│   ├── router/            # Page navigation configuration using GoRouter
│   └── theme/             # Styling & design system tokens (light/dark colors, spacing, dimensions)
│
└── features/              # Feature modules (e.g., onboarding, auth, dashboard)
    └── dashboard/
        ├── data/          # Models, Repositories implementations, Data Sources
        ├── domain/        # Entities, Repository interfaces, and Use Cases
        └── presentation/  # Views, widgets, and Cubit state management
```

### Key Technical Choices:
* **State Management**: `Flutter BLoC` / `Cubit` for unidirectional data flow and clean separation of UI and business logic.
* **Local Database**: `Drift` (SQLite wrapper for Dart) providing reactive streams, transactions, and type-safe query generation.
* **Routing**: `GoRouter` for declarative, URL-friendly navigation with animations.
* **Typography & Styling**: `Google Fonts` (Outfit for displays, Inter for copy) with custom theme extensions supporting seamless Light and Dark modes.

---

## 🤖 AI Tools & Development Workflow

This application was created through a collaborative human-AI development process using specialized tools:

1. **Design & Inspiration**:
   - **Dribbble**: Used as the primary source for visual inspiration to create a modern, premium fintech interface with frosted glass effects and deep gradient overlays.
   - **STICH**: An AI design tool used to generate the initial style tokens and design guidelines defined in [DESIGN_LIGHT.md](file:///C:/Users/Admin/AndroidStudioProjects/spend_sum/DESIGN_LIGHT.md) and [DESIGN_DARK.md](file:///C:/Users/Admin/AndroidStudioProjects/spend_sum/DESIGN_DARK.md). Color changes made mid-project were updated back into these specification files to maintain design integrity.

2. **Agent Rules & Guidance**:
   - **gemini.md**: A dedicated constraints file specifying engineering rules, clean architecture patterns, coding style guidelines, and UI principles. This aligned the AI agent's coding behaviors directly with the project goals.

3. **Coding & Acceleration**:
   - **Antigravity (Google DeepMind)**: The core AI coding agent used to implement, refactor, and finalize the application logic and layouts.
   - **skills.sh**: Equipped the agent with Dart & Flutter development capabilities (e.g., mock generation, dependency injection setup, and automated static analysis) to accelerate coding speed.

4. **Implementation & Refactoring steps**:
   - **Core Logic**: Adjusted `HomeRepository` to expand recent transactions to 6 items (satisfying the 5-7 requirement) and dynamically computed current month expenses grouped by category.
   - **UI Polish**: Created the gradient Spend Card, dynamic category list scroll, and cleanly repositioned the FAB to the bottom-right corner while aligning the bottom navigation bar.
   - **Verification**: Verified using automated static analysis commands via the agent toolchain (`dart analyze`) to confirm zero compilation errors or lint warnings.

---

## 🚀 How to Run the Project

### Prerequisites:
* Flutter SDK (3.22.0 or higher recommended)
* Android Studio / Xcode / VS Code
* An emulator running (or a physical test device connected)

### Execution Steps:
1. Clone the repository:
   ```bash
   git clone <repository_link>
   cd spend_sum
   ```
2. Fetch dependencies:
   ```bash
   flutter pub get
   ```
3. Generate database and serialization files:
   ```bash
   flutter pub run build_runner build --delete-conflicting-outputs
   ```
4. Run the application:
   ```bash
   flutter run
   ```
