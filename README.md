# SpendSum

A personal Flutter app for tracking expenses and viewing monthly spend summaries — built with Clean Architecture, Drift (SQLite), and Flutter BLoC.

---

## 🤖 AI Development Workflow

This application was created through a collaborative human-AI development process.

### 🎨 Design & Inspiration (Dribbble References)
The visual aesthetics, glassmorphic card stylings, and transitions were inspired by high-fidelity design concepts from Dribbble:

| Reference 3 | Reference 2 | Reference 1 |
|---|---|---|
| ![img3](assets/inspiration/img3.png) | ![img2](assets/inspiration/img2.png) | ![img1](assets/inspiration/img1.png) |

- **STICH**: Used to generate initial style guidelines defined in [DESIGN_LIGHT.md](DESIGN_LIGHT.md) and [DESIGN_DARK.md](DESIGN_DARK.md).
- **gemini.md**: A dedicated constraints file specifying engineering rules, architecture patterns, coding style guidelines, and UI principles.
- **Antigravity (Google DeepMind)**: The core AI coding agent used to implement, refactor, and finalize the application logic and layouts.
- **skills.sh**: Assisted with Dart & Flutter development capabilities (mock generation, dependency injection, automated static analysis) to accelerate coding speed.

---

## 🔐 Login

**Use existing test account:**
| Phone | OTP |
|---|---|
| `+91 98765 43210` | Any 6-digit code except `111111` |

**Create a new account:** Tap *Get Started* → enter your phone number → enter any valid 6-digit OTP → complete setup.

---

## ✅ Features

- [x] Monthly Spend Header Card with % change vs last month
- [x] Horizontal Category Scroll (Food, Travel, Shopping, Groceries, Bills, etc.)
- [x] Recent Transactions List with swipe-to-delete & undo toast
- [x] Floating Action Button (bottom-right, above BottomNavigationBar)
- [x] 57 pre-seeded mock transactions on first run
- [x] Full Light & Dark theme support

### 🛠️ Tech Stack

| Layer | Technology |
|---|---|
| State Management | Flutter BLoC / Cubit |
| Database | Drift (SQLite) |
| Routing | GoRouter |
| Error Handling | fpdart `Either` |
| Fonts | Google Fonts (Outfit, Inter) |

---

## 🚀 Run Locally

```bash
git clone <repo_url> && cd spend_sum
flutter pub get
flutter pub run build_runner build --delete-conflicting-outputs
flutter run
```

---

## 📥 Download APK

👉 **[Google Drive — Release APK](https://drive.google.com/drive/folders/1WixPnjVGL1q4yiB0pUpNz9QLtPEZ8B0P?usp=sharing)**
