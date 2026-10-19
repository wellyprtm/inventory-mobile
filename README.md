# Inventory Mobile App

A clean, responsive mobile application for inventory and product catalog management built with **Flutter**, implementing the **MVVM (Model-View-ViewModel)** architectural pattern and the **Repository Pattern**.

---

## 🏛️ Architecture Overview

The codebase is organized into clear, decoupled layers:

```
lib/
├─ main.dart                  # App bootstrap and dependency wiring
├─ app.dart                   # MaterialApp, central theme, and route setup
├─ core/
│  ├─ theme/app_theme.dart    # Material 3 design system configuration
│  ├─ constants/              # Categories and app-wide constants
│  └─ utils/                  # Currency (IDR) and date formatters
├─ data/
│  ├─ models/product.dart     # Product entity with JSON serialization
│  ├─ services/               # Abstract ApiService + Mock REST Simulator
│  └─ repositories/           # Abstract ProductRepository and implementation
└─ ui/
   ├─ product_list/           # Main catalog view with search and category filters
   │  ├─ product_list_view.dart
   │  ├─ product_list_view_model.dart
   │  └─ widgets/
   ├─ product_detail/         # Detailed item view with delete/edit triggers
   └─ product_form/           # Add/Edit form with full input validation
```

---

## ✨ Features

- **Full CRUD Operations**:
  - **Create**: Add new products with validation (name, category, price, stock, description).
  - **Read**: Browse products, view real-time count badges, category chips, and formatted IDR currency.
  - **Update**: Edit existing product details.
  - **Delete**: Remove products with safety confirmation dialogs.
- **Search & Filter**: Real-time keyword search and category selection (`ChoiceChip`).
- **Reactive UI**: Built-in `ListenableBuilder` and `ChangeNotifier` for targeted rebuilds without unnecessary third-party overhead.
- **Mock REST Service**: In-memory data store with realistic network latency (300ms) for reliable offline testing and demonstrations.
- **Material 3 Design**: Modern typography, custom color seeds, card borders, and stock status indicators.

---

## 🧪 Testing

The project includes unit tests covering all CRUD operations and filtering logic:

```bash
flutter test
```

---

## 🚀 Getting Started

### Prerequisites
- Flutter SDK (v3.13.0 or later)
- Dart SDK

### Installation & Run

1. Fetch dependencies:
   ```bash
   flutter pub get
   ```

2. Run the application:
   ```bash
   # Run in Chrome
   flutter run -d chrome

   # Run on connected mobile device
   flutter run
   ```
