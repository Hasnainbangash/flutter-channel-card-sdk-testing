import UIKit
import Flutter
import NICardManagementSDK

@main
@objc class AppDelegate: FlutterAppDelegate {

  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {

    let controller: FlutterViewController = window?.rootViewController as! FlutterViewController

    // Register your custom channel
    CardManagementSDKChannel.register(with: self.registrar(forPlugin: "CardManagementSDKChannel")!)

    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}