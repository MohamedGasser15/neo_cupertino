import 'package:neo_cupertino/src/calendar/src/src.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:neo_cupertino/src/utils/platform_info.dart';

/// Shows a cupertino calendar picker as an overlay above or below the widget.
///
/// Returns a [DateTime] if a date was selected. Returns `null` if calendar was dismissed without a selected date.
///
/// It will display a grid of days for the [initialDate]'s month. The day
/// indicated by [initialDate] will be selected.
///
/// The optional [onDisplayedMonthChanged] callback can be used to track
/// the currently displayed month.
///
/// [maximumDate] must be after or equal to [minimumDate].
///
/// [initialDate] must be between [minimumDate] and [maximumDate] or equal to
/// one of them.
///
/// [currentDate] represents the current day (i.e. today). This
/// date will be highlighted in the day grid. If null, the date of
/// `DateTime.now()` will be used.
///
/// [dismissBehaviour] represents how the calendar can be closed.
/// Android back button always close the calendar.
Future<DateTime?> showCupertinoCalendarPicker(
  BuildContext context, {
  /// The widget's render box around which the calendar will be displayed.
  required RenderBox? widgetRenderBox,

  /// The minimum selectable [DateTime].
  required DateTime minimumDate,

  /// The maximum selectable [DateTime].
  required DateTime maximumDate,

  /// Called on date changes in the picker.
  ValueChanged<DateTime>? onDateChanged,

  /// Called when the user selects a date in the picker.
  ValueChanged<DateTime>? onDateSelected,

  /// The initially selected [DateTime] that the calendar should display.
  DateTime? initialDate,

  /// The [DateTime] representing today. It will be highlighted in the day grid.
  DateTime? currentDate,

  /// Called when the user navigates to a new month in the picker.
  ValueChanged<DateTime>? onDisplayedMonthChanged,

  /// The spacing from left and right side of the screen.
  double horizontalSpacing = 15.0,

  /// The spacing from top and bottom side of the screen.
  double verticalSpacing = 15.0,

  /// The offset from top/bottom of the [widgetRenderBox] location.
  Offset offset = const Offset(0.0, 10.0),
  Color barrierColor = Colors.transparent,
  Color mainColor = CupertinoColors.systemRed,
  CalendarDismissBehavior dismissBehaviour =
      CalendarDismissBehavior.onOutsideTap,
  CalendarContainerDecoration? containerDecoration,
  CalendarWeekdayDecoration? weekdayDecoration,
  CalendarMonthPickerDecoration? monthPickerDecoration,
  CalendarHeaderDecoration? headerDecoration,
}) {
  if (!PlatformInfo.isIOS26OrHigher()) {
    return _showCupertino18DatePicker(
      context: context,
      initialDate: initialDate ?? currentDate ?? DateTime.now(),
      minimumDate: minimumDate,
      maximumDate: maximumDate,
      onDateChanged: onDateChanged,
      onDateSelected: onDateSelected,
    );
  }

  return showGeneralDialog<DateTime?>(
    context: context,
    barrierLabel: calendarPickerBarrierLabel,
    barrierColor: barrierColor,
    transitionDuration: Duration.zero,
    routeSettings: const RouteSettings(name: calendarPickerRouteName),
    transitionBuilder: (
      BuildContext _,
      Animation<double> __,
      Animation<double> ___,
      Widget child,
    ) {
      return child;
    },
    pageBuilder: (
      BuildContext _,
      Animation<double> __,
      Animation<double> ___,
    ) {
      return CupertinoCalendarOverlay(
        mainColor: mainColor,
        horizontalSpacing: horizontalSpacing,
        verticalSpacing: verticalSpacing,
        offset: offset,
        widgetRenderBox: widgetRenderBox,
        initialDate: initialDate,
        minimumDate: minimumDate,
        maximumDate: maximumDate,
        currentDate: currentDate,
        onDateChanged: onDateChanged,
        onDateSelected: onDateSelected,
        onDisplayedMonthChanged: onDisplayedMonthChanged,
        containerDecoration: containerDecoration,
        weekdayDecoration: weekdayDecoration,
        monthPickerDecoration: monthPickerDecoration,
        headerDecoration: headerDecoration,
        dismissBehaviour: dismissBehaviour,
      );
    },
  );
}

Future<DateTime?> _showCupertino18DatePicker({
  required BuildContext context,
  required DateTime initialDate,
  required DateTime minimumDate,
  required DateTime maximumDate,
  ValueChanged<DateTime>? onDateChanged,
  ValueChanged<DateTime>? onDateSelected,
}) async {
  DateTime selectedDate = initialDate.isBefore(minimumDate)
      ? minimumDate
      : (initialDate.isAfter(maximumDate) ? maximumDate : initialDate);

  return showCupertinoModalPopup<DateTime>(
    context: context,
    builder: (BuildContext ctx) {
      final backgroundColor = CupertinoTheme.of(ctx).scaffoldBackgroundColor;
      final separatorColor = CupertinoDynamicColor.resolve(
        CupertinoColors.separator,
        ctx,
      );

      return Container(
        height: 280,
        color: backgroundColor,
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(color: separatorColor, width: 0.5),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  CupertinoButton(
                    padding: EdgeInsets.zero,
                    onPressed: () => Navigator.of(ctx).pop(),
                    child: Text(
                      CupertinoLocalizations.of(ctx).cancelButtonLabel,
                    ),
                  ),
                  CupertinoButton(
                    padding: EdgeInsets.zero,
                    onPressed: () {
                      onDateSelected?.call(selectedDate);
                      Navigator.of(ctx).pop(selectedDate);
                    },
                    child: Builder(
                      builder: (bCtx) {
                        String label = 'Done';
                        try {
                          label = MaterialLocalizations.of(bCtx).okButtonLabel;
                        } catch (_) {}
                        return Text(
                          label,
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: CupertinoDatePicker(
                mode: CupertinoDatePickerMode.date,
                initialDateTime: selectedDate,
                minimumDate: minimumDate,
                maximumDate: maximumDate,
                onDateTimeChanged: (DateTime newDate) {
                  selectedDate = newDate;
                  onDateChanged?.call(newDate);
                },
              ),
            ),
          ],
        ),
      );
    },
  );
}
