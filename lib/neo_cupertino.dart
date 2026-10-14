/// NeoCupertino 🍏
/// Next-Generation iOS (iOS 26) UI Kit for Flutter.
/// Featuring Liquid Glass Impeller Shaders, Apple Squircle Primitives,
/// Native UIKit Platform Controls, and Unified Neo-Cupertino components.
library;

// 1. Cupertino Icons
export 'package:flutter/cupertino.dart' show CupertinoIcons;

// 2. Cupertino Calendar & Date Pickers
export 'src/calendar/cupertino_calendar_picker.dart';

// 3. Liquid Glass Design System
export 'src/liquid_glass/liquid_glass.dart';

// 4. iOS Navigation & Bottom Bar
export 'src/navigation/neo_navigation.dart';

// 5. Context Menus
export 'src/context_menu/neo_single_tap_context_menu.dart';
export 'src/widgets/neo_hold_context_menu.dart';

// 6. Neo-Cupertino iOS 26 Dialogs & Alerts
export 'src/dialogs/neo_glass_alert.dart';
export 'src/dialogs/neo_native_alert.dart';
export 'src/dialogs/neo_alert_dialog.dart';
export 'src/feedback/neo_snackbar.dart';
export 'src/utils/platform_info.dart';

// 7. Neo-Cupertino Inputs & Widgets
export 'src/input/neo_text_field.dart';
export 'src/input/neo_text_form_field.dart';
export 'src/widgets/neo_list_tile.dart';
export 'src/widgets/neo_keyboard_floating_button.dart';

import 'src/calendar/cupertino_calendar_picker.dart';
import 'src/context_menu/neo_single_tap_context_menu.dart';
import 'src/liquid_glass/liquid_glass.dart';
import 'src/widgets/neo_hold_context_menu.dart';

// ============================================================================
// Unified Neo-Cupertino Aliases (Unified API & Developer Experience)
// ============================================================================

// Interactive Controls
typedef NeoSwitch = GlassSwitch;
typedef NeoSegmentedControl = GlassSegmentedControl;
typedef NeoSlider = GlassSlider;
typedef NeoButton = GlassButton;
typedef NeoIconButton = GlassIconButton;
typedef NeoChip = GlassChip;
typedef NeoBadge = GlassBadge;

// Containers & Surfaces
typedef NeoCard = GlassCard;
typedef NeoContainer = GlassContainer;
typedef NeoDivider = GlassDivider;
typedef NeoStepper = GlassStepper;
typedef NeoAppBar = GlassAppBar;
typedef NeoScaffold = GlassScaffold;

// Overlays & Sheets
typedef NeoModalSheet = GlassModalSheet;
typedef NeoDialog = GlassDialog;

// Context Menus
typedef NeoSingleTapContextMenu = IosSingleTapContextMenu;
typedef NeoHoldContextMenu = IosHoldContextMenu;
typedef NeoContextMenuItem = IosContextMenuItem;
typedef NeoContextMenuAction = IosContextMenuAction;
typedef NeoContextMenuSubmenu = IosContextMenuSubmenu;
typedef NeoContextMenuDivider = IosContextMenuDivider;

// Pickers
const showNeoCalendarPicker = showCupertinoCalendarPicker;
