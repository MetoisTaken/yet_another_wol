import Cocoa
import FlutterMacOS

class MainFlutterWindow: NSWindow {
  override func awakeFromNib() {
    let flutterViewController = FlutterViewController()
    let windowFrame = self.frame
    self.contentViewController = flutterViewController
    self.setFrame(windowFrame, display: false)

    RegisterGeneratedPlugins(registry: flutterViewController)

    let channel = FlutterMethodChannel(
      name: "com.yawol.macos/accent",
      binaryMessenger: flutterViewController.engine.binaryMessenger
    )

    channel.setMethodCallHandler { (call, result) in
      if call.method == "getAccentColor" {
        if #available(macOS 10.14, *) {
          // Convert to sRGB to ensure components are valid
          guard let color = NSColor.controlAccentColor.usingColorSpace(.sRGB) else {
             result(nil)
             return
          }
          
          let r = Int(color.redComponent * 255)
          let g = Int(color.greenComponent * 255)
          let b = Int(color.blueComponent * 255)
          let a = Int(color.alphaComponent * 255)
          
          // Construct 0xAARRGGBB
          let colorInt = (a << 24) | (r << 16) | (g << 8) | b
          result(colorInt)
        } else {
          result(nil)
        }
      } else {
        result(FlutterMethodNotImplemented)
      }
    }

    super.awakeFromNib()
  }
}
