# SpendSum

A personal Flutter app for tracking expenses and viewing monthly spend summaries — built with Clean Architecture, Drift (SQLite), and Flutter BLoC.

---

## 🔐 Login

**Use existing test account:**
| Phone | OTP |
|---|---|
| `+91 98765 43210` | Any 6-digit code except `111111` |

**Create a new account:** Tap *Get Started* → enter your phone number → enter any valid 6-digit OTP → complete setup.

---

## 📥 Download APK

👉 **[Google Drive — Release APK](https://drive.google.com/drive/folders/1WixPnjVGL1q4yiB0pUpNz9QLtPEZ8B0P?usp=sharing)**

---

## ✅ Features

- [x] Monthly Spend Header Card with % change vs last month
- [x] Horizontal Category Scroll (Food, Travel, Shopping, Groceries, Bills, etc.)
- [x] Recent Transactions List with swipe-to-delete & undo toast
- [x] Floating Action Button (bottom-right, above BottomNavigationBar)
- [x] 57 pre-seeded mock transactions on first run
- [x] Full Light & Dark theme support

---

## 🎨 Design Inspiration

| Reference 3 | Reference 2 | Reference 1 |
|---|---|---|
| ![img3](assets/inspiration/img3.png) | ![img2](assets/inspiration/img2.png) | ![img1](assets/inspiration/img1.png) |

---

## 🛠️ Tech Stack

| Layer | Technology |
|---|---|
| State Management | Flutter BLoC / Cubit |
| Database | Drift (SQLite) |
| Routing | GoRouter |
| Error Handling | fpdart `Either` |
| Fonts | Google Fonts (Outfit, Inter) |

---

## 🤖 AI Tools & Development Workflow

This application was created through a collaborative human-AI development process using specialized tools:

1. **Design & Inspiration**:
   - **Dribbble**: Used as the primary source for visual inspiration to create a modern, premium fintech interface with frosted glass effects and deep gradient overlays.
   - **STICH**: An AI design tool used to generate the initial style tokens and design guidelines defined in [DESIGN_LIGHT.md](DESIGN_LIGHT.md) and [DESIGN_DARK.md](DESIGN_DARK.md). Color changes made mid-project were updated back into these specification files to maintain design integrity.

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

## 🚀 Run Locally

```bash
git clone <repo_url> && cd spend_sum
flutter pub get
flutter pub run build_runner build --delete-conflicting-outputs
flutter run
```
