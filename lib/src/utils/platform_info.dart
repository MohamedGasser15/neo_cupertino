import 'dart:io';
import 'package:flutter/foundation.dart';

/// Provides platform detection and iOS version information for [neo_cupertino].
class PlatformInfo {
  static bool get isIOS => !kIsWeb && Platform.isIOS;
  static bool get isAndroid => !kIsWeb && Platform.isAndroid;
  static bool get isMacOS => !kIsWeb && Platform.isMacOS;
  static bool get isWindows => !kIsWeb && Platform.isWindows;
  static bool get isLinux => !kIsWeb && Platform.isLinux;
  static bool get isWeb => kIsWeb;

  /// Override iOS version for testing and previewing
  static int? _overrideIOSVersion;
  static bool? _forceIOS26;

  /// Sets an override iOS version for testing (e.g. 18 or 26)
  static void setOverrideIOSVersion(int? version) {
    _overrideIOSVersion = version;
  }

  /// Forces iOS 26 mode on (true) or off (false)
  static void setForceIOS26(bool? force) {
    _forceIOS26 = force;
  }

  /// Returns the iOS major version number (e.g. 18, 26).
  static int get iOSVersion {
    if (_overrideIOSVersion != null) return _overrideIOSVersion!;
    if (!isIOS) return 0;
    try {
      final version = Platform.operatingSystemVersion;
      final match = RegExp(r'Version (\d+)').firstMatch(version);
      if (match != null) {
        return int.parse(match.group(1)!);
      }
      final fallbackMatch = RegExp(r'(\d+)').firstMatch(version);
      if (fallbackMatch != null) {
        return int.parse(fallbackMatch.group(1)!);
      }
    } catch (_) {}
    return 0;
  }

  /// Returns true if iOS version is 26 or higher
  static bool isIOS26OrHigher() {
    if (_forceIOS26 != null) return _forceIOS26!;
    return isIOS && iOSVersion >= 26;
  }

  /// Returns true if iOS version is 18 or lower (pre-iOS 26)
  static bool isIOS18OrLower() {
    if (_forceIOS26 != null) return !_forceIOS26!;
    return isIOS && iOSVersion > 0 && iOSVersion < 26;
  }

  /// Returns true if iOS version is in a specific range
  static bool isIOSVersionInRange(int min, int max) {
    return isIOS && iOSVersion >= min && iOSVersion <= max;
  }

  /// Returns a human-readable platform description
  static String get platformDescription {
    if (isIOS) return 'iOS $iOSVersion';
    if (isAndroid) return 'Android';
    if (isMacOS) return 'macOS';
    if (isWindows) return 'Windows';
    if (isLinux) return 'Linux';
    if (isWeb) return 'Web';
    return 'Unknown';
  }
}

// Neo-Cupertino alias
typedef NeoPlatformInfo = PlatformInfo;
