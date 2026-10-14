# NeoCupertino 🍏

A production-grade, next-generation **iOS (iOS 26) UI Kit for Flutter**. Built to deliver authentic Apple Human Interface Guidelines (HIG) aesthetics, fluid physics, Impeller fragment shaders, and native UIKit performance.

Developed and maintained by **Mohamed Gasser**.

---

## ✨ Features

- 💧 **Liquid Glass Design System**
  - Hardware-accelerated GLSL Fragment Shaders powered by Flutter's **Impeller** engine.
  - Authentic light refraction, chromatic dispersion, edge caustics, and frosted blur.
  - Includes `GlassButton`, `GlassSheet`, `GlassSwitch`, `GlassContainer`, and `LiquidGlassSettings`.

- 🛡️ **Neo-Cupertino iOS 26 Dialogs & Alerts**
  - `NeoAlertDialog`, `NeoGlassAlert`, and `NeoNativeAlert` featuring wide squircle cards, capsule action pill buttons, and `NeoDialogAction` with SwiftUI-style `NeoDialogActionRole`.
  - Native iOS UIKit platform views with dynamic light/dark contrast adjustments.

- 🔔 **NeoSnackBar**
  - Apple-styled top banner notification floating natively under the Notch & Dynamic Island.

- 📝 **Neo-Cupertino Form Inputs**
  - `NeoTextField` & `NeoTextFormField`: Squircle curvature, SF Pro typography, and continuous Cupertino validation.

- 📋 **NeoListTile**
  - Grouped native iOS list row with SF typography, indented separators, press opacity, and haptic feedback.

- ⚡ **Native iOS Context Menu**
  - Powered by native UIKit (`UIContextMenuInteraction` & `UIButton`) for zero-latency, zero-jank interaction.
  - Native iOS Taptic Engine haptic feedback on touch.
  - Supports destructive items, SF symbols, custom icons, and instant dismiss.

- 🧭 **iOS Liquid Navigation Bar**
  - Floating bottom navigation bar (`LiquidGlassBottomBar`) with an animated morphing liquid capsule.
  - Seamless SF Symbols integration and system appearance adaptation.

- 📅 **NeoCalendarPicker**
  - Full-featured, native-styled iOS calendar and date picker.
  - Supports single date, multi-date, and date range selections with custom palettes.

- ⌨️ **Keyboard Floating Action Button**
  - `NeoKeyboardFloatingButton`: Floating liquid glass pill button attached above iOS numeric/phone keyboards for smooth navigation.

---

## 🚀 Getting Started

Add `neo_cupertino` to your `pubspec.yaml`:

```yaml
dependencies:
  neo_cupertino:
    git:
      url: https://github.com/MohamedGasser15/neo_cupertino.git
      ref: main
```

Initialize shaders in your `main()`:

```dart
import 'package:flutter/material.dart';
import 'package:neo_cupertino/neo_cupertino.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await LiquidGlassWidgets.initialize();

  runApp(
    LiquidGlassWidgets.wrap(
      child: const MyApp(),
    ),
  );
}
```

---

## 🛠 Usage Examples

### 1. Native iOS Context Menu
Open authentic iOS context menus on tap or long press:

```dart
IosHoldContextMenu(
  actions: [
    IosContextMenuAction(
      title: 'Edit',
      icon: Icons.edit_rounded,
      onPressed: () => editItem(),
    ),
    IosContextMenuAction(
      title: 'Delete',
      icon: Icons.delete_rounded,
      isDestructive: true,
      onPressed: () => deleteItem(),
    ),
  ],
  child: ItemCard(),
)
```

### 2. Liquid Glass Button
Create refractive glass buttons with custom thickness, blur, and light intensity:

```dart
GlassButton.custom(
  settings: const LiquidGlassSettings(
    thickness: 18,
    blur: 24,
    glassColor: Color(0x661E1E26),
  ),
  onTap: () {},
  child: const Text('Confirm Transfer'),
)
```

### 3. Liquid Glass Modal Bottom Sheet
Multi-detent iOS 18 style bottom sheets:

```dart
GlassModalSheet.show(
  context: context,
  initialState: GlassSheetState.half,
  detents: const {GlassSheetDetent.medium, GlassSheetDetent.large},
  builder: (context) => const FilterView(),
);
```

### 4. Liquid Glass Floating Bottom Bar

```dart
LiquidGlassBottomBar(
  height: 85,
  tint: Theme.of(context).primaryColor,
  style: LiquidGlassStyle.regular,
  currentIndex: selectedIndex,
  onTap: (index) => setState(() => selectedIndex = index),
  items: [
    LiquidGlassBarItem(
      icon: CupertinoIcons.creditcard,
      sfSymbol: 'wallet.pass',
      label: 'Wallet',
    ),
    LiquidGlassBarItem(
      icon: CupertinoIcons.chart_pie,
      sfSymbol: 'chart.pie',
      label: 'Analytics',
    ),
  ],
)
```

---

## 📄 License

MIT License © 2026 Mohamed Gasser. All rights reserved.
