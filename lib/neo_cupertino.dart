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
export 'src/liquid_glass/widgets/feedback/glass_content_unavailable_view.dart';
export 'src/liquid_glass/widgets/overlays/glass_modal_sheet.dart'
    show showGlassModalSheet;

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

// 8. Neo-Cupertino Unified Theming
export 'src/theme/neo_theme.dart';
export 'src/theme/neo_theme_data.dart';

// 9. iOS 26 Liquid Pull to Refresh
export 'src/refresh/neo_pull_to_refresh.dart';

// 10. iOS 26 Liquid Glass Wheel Picker
export 'src/picker/neo_wheel_picker.dart';

// 11. iOS 26 Liquid Glass Action Sheet
export 'src/overlays/neo_action_sheet.dart';

// 12. iOS 26 Liquid Glass Tooltip & Popover
export 'src/overlays/neo_tooltip.dart';

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
typedef NeoPageControl = GlassPageControl;

// Containers & Surfaces
typedef NeoCard = GlassCard;
typedef NeoContainer = GlassContainer;
typedef NeoDivider = GlassDivider;
typedef NeoStepper = GlassStepper;
typedef NeoAppBar = GlassAppBar;
typedef NeoScaffold = GlassScaffold;
typedef NeoTabBar = GlassTabBar;
typedef NeoToolbar = GlassToolbar;
typedef NeoPinnedBarChrome = GlassPinnedBarChrome;
typedef NeoGroupedSection = GlassGroupedSection;
typedef NeoGlassListTile = GlassListTile;
typedef NeoPage = GlassPage;
typedef NeoStatusBarStyle = GlassStatusBarStyle;

// Overlays & Sheets
typedef NeoModalSheet = GlassModalSheet;
const showNeoModalSheet = showGlassModalSheet;
typedef NeoSheet = GlassSheet;
typedef NeoDialog = GlassDialog;
typedef NeoToast = GlassToast;

// Feedback & Empty States
typedef NeoContentUnavailableView = GlassContentUnavailableView;
typedef NeoProgressIndicator = GlassProgressIndicator;

// Inputs & Search
typedef NeoSearchBar = GlassSearchBar;
typedef NeoGlassTextField = GlassTextField;
typedef NeoPasswordField = GlassPasswordField;
typedef NeoTextArea = GlassTextArea;
typedef NeoPicker = GlassPicker;

// Context Menus
typedef NeoMenu = GlassMenu;
typedef NeoMenuItem = GlassMenuItem;
typedef NeoSingleTapContextMenu = IosSingleTapContextMenu;
typedef NeoNativeMenu = IosSingleTapContextMenu;
typedef NeoHoldContextMenu = IosHoldContextMenu;
typedef NeoContextMenuItem = IosContextMenuItem;
typedef NeoContextMenuAction = IosContextMenuAction;
typedef NeoContextMenuSubmenu = IosContextMenuSubmenu;
typedef NeoContextMenuDivider = IosContextMenuDivider;

// Pickers
const showNeoCalendarPicker = showCupertinoCalendarPicker;
