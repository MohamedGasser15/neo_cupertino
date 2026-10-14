import Flutter
import UIKit

public final class NeoCupertinoPlugin: NSObject, FlutterPlugin {
  public static func register(with registrar: FlutterPluginRegistrar) {
    NeoContextMenuPlugin.register(with: registrar)
    LiquidGlassContainerPlugin.register(with: registrar)
    registrar.register(
      NeoNativeAlertViewFactory(messenger: registrar.messenger()),
      withId: "neo_cupertino/neo_native_alert"
    )
  }
}
