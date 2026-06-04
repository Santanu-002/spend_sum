# SpendSum — Elegant Expense Tracking & Spend Summary

SpendSum is a premium, high-fidelity Flutter application I built as a personal project to deliver a beautiful, intuitive, and fluid interface for tracking expenses, managing categories, and viewing monthly spend summaries.

Designed with meticulous attention to detail, the app implements standard software engineering best practices (DRY, Clean Architecture, SOLID, and low coupling) to deliver a polished fintech-grade experience.

---

## 🔐 Login & Account Setup

### Using an Existing Account
A pre-seeded test account is included for immediate access:

| Field | Value |
|---|---|
| **Phone Number** | `+91 98765 43210` |
| **OTP / Verification Code** | Any 6-digit code **except** `111111` (e.g. `123456`, `000000`) |

> The OTP verification is simulated — any valid 6-digit code (except `111111`) will authenticate you successfully.

### Creating a New Account
1. Open the app and tap **"Get Started"** on the onboarding screen.
2. Enter your phone number in international format (e.g. `+91XXXXXXXXXX`).
3. Tap **Send OTP** and enter any 6-digit code when prompted.
4. Complete the profile setup (name, currency preference) and you're in.

---

## 🎨 Design Inspiration & UI Screenshots

### UI Design Inspiration (Dribbble References)
The visual aesthetics, typography layout, glassmorphic card stylings, and transitions were inspired by high-fidelity design concepts from Dribbble. The reference assets used during planning are:

| Dribbble Reference 3 | Dribbble Reference 2 | Dribbble Reference 1 |
|---|---|---|
| ![Inspiration 3](assets/inspiration/img3.png) | ![Inspiration 2](assets/inspiration/img2.png) | ![Inspiration 1](assets/inspiration/img1.png) |

---

### Developed App Screenshots (Tested on Emulator)

| Light Theme — Spend Summary | Dark Theme — Spend Summary |
|---|---|
| *[Add Light Theme Screenshot]* | *[Add Dark Theme Screenshot]* |

---

### 📥 Direct APK Installation
To run the app directly on an Android device without building from source, download the pre-compiled APK from:
👉 **[Download APK (Google Drive)](https://drive.google.com/drive/folders/1WixPnjVGL1q4yiB0pUpNz9QLtPEZ8B0P?usp=sharing)**

---

## ✨ Features

- **Monthly Spend Header Card**: Full-width gradient card showing total monthly spend with an interactive comparison pill (e.g. `12% less than last month`).
- **Horizontal Category Scroll**: A horizontal carousel of spending categories (Food, Travel, Shopping, Groceries, Bills, etc.) with icons and aggregated spend per category.
- **Recent Transactions List**: A list of recent transactions with swipe-to-delete functionality and an undo toast indicator.
- **Floating Action Button (FAB)**: Positioned bottom-right for single-handed reach, floating cleanly above the BottomNavigationBar.
- **Pre-seeded Data (57 Items)**: The local SQLite database is pre-seeded on first run with 57 sample transactions across multiple categories to showcase a realistic dashboard.
- **Light & Dark Mode**: Full theme support with smooth transitions between modes.

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
└── features/              # Feature modules (onboarding, auth, dashboard)
    └── [feature]/
        ├── data/          # Models, Repository implementations, Data Sources
        ├── domain/        # Entities, Repository interfaces, and Use Cases
        └── presentation/  # Views, widgets, and Cubit/Bloc state management
```

### Key Technical Choices:
* **State Management**: `Flutter BLoC` / `Cubit` for unidirectional data flow and clean separation of UI and business logic.
* **Local Database**: `Drift` (SQLite wrapper for Dart) providing reactive streams, transactions, and type-safe query generation.
* **Routing**: `GoRouter` for declarative, URL-friendly navigation with shared-axis animations.
* **Typography & Styling**: `Google Fonts` (Outfit for displays, Inter for body) with custom theme extensions for seamless Light and Dark modes.
* **Error Handling**: `fpdart` `Either` monad for compile-time safe error propagation across all layers.

---

## 🤖 AI Tools & Development Workflow

This project was built through a collaborative human-AI workflow:

1. **Design & Inspiration**:
   - **Dribbble**: Primary source for visual inspiration — modern fintech interfaces with frosted glass effects and gradient overlays.
   - **STICH**: Used to generate initial style tokens and design guidelines defined in [DESIGN_LIGHT.md](DESIGN_LIGHT.md) and [DESIGN_DARK.md](DESIGN_DARK.md).

2. **Agent Rules & Guidance**:
   - **gemini.md**: A constraints file defining engineering rules, clean architecture patterns, and coding style guidelines to align the AI agent with project goals.

3. **Coding & Acceleration**:
   - **Antigravity (Google DeepMind)**: The core AI coding agent used to implement, refactor, and finalize application logic and layouts.
   - **skills.sh**: Equipped the agent with Dart & Flutter development capabilities (mock generation, DI setup, static analysis) to accelerate coding speed.

---

## 🚀 How to Run the Project

### Prerequisites:
* Flutter SDK (3.22.0 or higher recommended)
* Android Studio / VS Code
* An emulator running, or a physical Android device connected

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
