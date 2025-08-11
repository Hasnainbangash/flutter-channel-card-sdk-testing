import UIKit
import Flutter
import NICardManagementSDK

class CardManagementSDKChannel {
    private static var sdk: NICardManagementAPI?

    static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: "com.example.card_sdk", binaryMessenger: registrar.messenger())

        // Initialize the SDK
        initializeSDK()

        channel.setMethodCallHandler { (call: FlutterMethodCall, result: @escaping FlutterResult) in
            switch call.method {
            case "printMessage":
                self.printMessage(call, result)
            case "addTwoNumbers":
                self.addTwoNumbers(call, result)
            case "getVersion":
                self.getVersion(result)
            case "setPin":
                self.setPin(call, result)
            case "setPinForm":
                self.setPinForm(call, result, registrar: registrar)
            case "changePin":
                self.changePin(call, result)
            case "changePinForm":
                self.changePinForm(call, result, registrar: registrar)
            default:
                result(FlutterMethodNotImplemented)
            }
        }
    }

    private static func initializeSDK() {
        // Use configuration values
        let rootUrl = SDKConfiguration.rootUrl
        let cardIdentifierId = SDKConfiguration.cardIdentifierId
        let cardIdentifierType = SDKConfiguration.cardIdentifierType
        let bankCode = SDKConfiguration.bankCode

        // Create a simple token fetchable implementation
        let tokenFetchable = SimpleTokenFetchable()

        // Initialize the SDK
        sdk = NICardManagementAPI(
            rootUrl: rootUrl,
            cardIdentifierId: cardIdentifierId,
            cardIdentifierType: cardIdentifierType,
            bankCode: bankCode,
            tokenFetchable: tokenFetchable,
            extraHeadersProvider: nil,
            logger: nil
        )
    }

    private static func printMessage(_ call: FlutterMethodCall, _ result: @escaping FlutterResult) {
        if let args = call.arguments as? [String: Any],
           let message = args["message"] as? String {
            print("iOS received message: \(message)")
            result("Printed successfully")
        } else {
            result(FlutterError(code: "INVALID_ARGUMENTS", message: "Expected a message string", details: nil))
        }
    }

    private static func addTwoNumbers(_ call: FlutterMethodCall, _ result: @escaping FlutterResult) {
        if let args = call.arguments as? [String: Any],
           let a = args["a"] as? Int,
           let b = args["b"] as? Int {
            result(a + b)
        } else {
            result(FlutterError(code: "INVALID_ARGUMENTS", message: "Expected integers 'a' and 'b'", details: nil))
        }
    }

    private static func getVersion(_ result: @escaping FlutterResult) {
        let version = "iOS " + UIDevice.current.systemVersion
        result(version)
    }

    // Programmatic setPin method (like in CardViewController)
    private static func setPin(_ call: FlutterMethodCall, _ result: @escaping FlutterResult) {
        guard let sdk = sdk else {
            result(FlutterError(code: "SDK_NOT_INITIALIZED", message: "Card Management SDK not initialized", details: nil))
            return
        }

        if let args = call.arguments as? [String: Any],
           let pin = args["pin"] as? String {

            print("Setting PIN programmatically on iOS: \(pin)")

            // Use the SDK's programmatic setPin method
            sdk.setPin(pin: pin) { successResponse, errorResponse, callback in
                DispatchQueue.main.async {
                    if let error = errorResponse {
                        result(FlutterError(
                            code: error.errorCode ?? "SET_PIN_ERROR",
                            message: error.errorMessage,
                            details: nil
                        ))
                    } else if let success = successResponse {
                        result([
                            "success": true,
                            "message": success.message
                        ])
                    } else {
                        result(FlutterError(
                            code: "UNKNOWN_ERROR",
                            message: "Unknown error occurred while setting PIN",
                            details: nil
                        ))
                    }
                    callback() // Call the callback as required by the SDK
                }
            }
        } else {
            result(FlutterError(code: "INVALID_ARGUMENTS", message: "Expected 'pin' string", details: nil))
        }
    }

    // setPinForm method (shows the UI form like in CardViewController)
    private static func setPinForm(_ call: FlutterMethodCall, _ result: @escaping FlutterResult, registrar: FlutterPluginRegistrar) {
        guard let sdk = sdk else {
            result(FlutterError(code: "SDK_NOT_INITIALIZED", message: "Card Management SDK not initialized", details: nil))
            return
        }

        DispatchQueue.main.async {
            // Get the root view controller (Flutter view controller)
            guard let rootViewController = UIApplication.shared.windows.first?.rootViewController else {
                result(FlutterError(code: "NO_ROOT_CONTROLLER", message: "Cannot find root view controller", details: nil))
                return
            }

            // Use default PIN type and config
            let pinType = NIPinFormType.dynamic // or .static based on your needs
            let config = SetPinViewModel.Config.default

            // Create a dummy view controller and navigation controller (as done in CardViewController)
            let dummyVC = UIViewController()
            let navVC = UINavigationController(rootViewController: dummyVC)
            navVC.isNavigationBarHidden = true

            // Print pinType and config details
            print("--- PinType: \(pinType) ---")
            print("--- Config: \(config) ---")

            // Present the PIN form
            sdk.setPinForm(
                type: pinType,
                config: config,
                viewController: dummyVC
            ) { successResponse, errorResponse, callback in
                DispatchQueue.main.async {
                    // Dismiss the navigation controller
                    navVC.dismiss(animated: true) {
                        if let error = errorResponse {
                            result(FlutterError(
                                code: error.errorCode ?? "SET_PIN_FORM_ERROR",
                                message: error.errorMessage,
                                details: nil
                            ))
                        } else if let success = successResponse {
                            result([
                                "success": true,
                                "message": success.message
                            ])
                        } else {
                            result(FlutterError(
                                code: "UNKNOWN_ERROR",
                                message: "Unknown error occurred while setting PIN",
                                details: nil
                            ))
                        }
                        callback() // Call the callback as required by the SDK
                    }
                }
            }

            // Present the navigation controller
            rootViewController.present(navVC, animated: true)
        }
    }

    // Programmatic changePin method (like in CardViewController)
//        private static func changePin(_ call: FlutterMethodCall, _ result: @escaping FlutterResult) {
//            guard let sdk = sdk else {
//                result(FlutterError(code: "SDK_NOT_INITIALIZED", message: "Card Management SDK not initialized", details: nil))
//                return
//            }
//
//            if let args = call.arguments as? [String: Any],
//               let oldPin = args["oldPin"] as? String,
//               let newPin = args["newPin"] as? String {
//
//                print("Changing PIN programmatically on iOS: from \(oldPin) to \(newPin)")
//
//                // Use the SDK's programmatic changePin method
//                sdk.changePin(oldPin: oldPin, newPin: newPin) { successResponse, errorResponse, callback in
//                    DispatchQueue.main.async {
//                        if let error = errorResponse {
//                            result(FlutterError(
//                                code: error.errorCode ?? "CHANGE_PIN_ERROR",
//                                message: error.errorMessage,
//                                details: nil
//                            ))
//                        } else if let success = successResponse {
//                            result([
//                                "success": true,
//                                "message": success.message
//                            ])
//                        } else {
//                            result(FlutterError(
//                                code: "UNKNOWN_ERROR",
//                                message: "Unknown error occurred while changing PIN",
//                                details: nil
//                            ))
//                        }
//                        callback() // Call the callback as required by the SDK
//                    }
//                }
//            } else {
//                result(FlutterError(code: "INVALID_ARGUMENTS", message: "Expected 'oldPin' and 'newPin' strings", details: nil))
//            }
//        }


        private static func changePin(_ call: FlutterMethodCall, _ result: @escaping FlutterResult) {
            guard let sdk = sdk else {
                print("SDK not initialized")
                result(FlutterError(code: "SDK_NOT_INITIALIZED", message: "Card Management SDK not initialized", details: nil))
                return
            }

            if let args = call.arguments as? [String: Any],
               let oldPin = args["oldPin"] as? String,
               let newPin = args["newPin"] as? String {

                print("Received arguments for changePin: oldPin=\(oldPin), newPin=\(newPin)")
                print("Changing PIN programmatically on iOS: from \(oldPin) to \(newPin)")

                // Use the SDK's programmatic changePin method
                sdk.changePin(oldPin: oldPin, newPin: newPin) { successResponse, errorResponse, callback in
                    DispatchQueue.main.async {
                        print("changePin response received")

                        if let error = errorResponse {
                            print("changePin failed with error: \(error.errorCode ?? "UNKNOWN_CODE") - \(error.errorMessage ?? "No message")")
                            result(FlutterError(
                                code: error.errorCode ?? "CHANGE_PIN_ERROR",
                                message: error.errorMessage,
                                details: nil
                            ))
                        } else if let success = successResponse {
                            print("changePin succeeded with message: \(success.message ?? "No message")")
                            result([
                                "success": true,
                                "message": success.message
                            ])
                        } else {
                            print("changePin resulted in unknown state")
                            result(FlutterError(
                                code: "UNKNOWN_ERROR",
                                message: "Unknown error occurred while changing PIN",
                                details: nil
                            ))
                        }

                        print("Calling SDK callback after changePin")
                        callback() // Call the callback as required by the SDK
                    }
                }
            } else {
                print("Invalid arguments passed to changePin method")
                result(FlutterError(code: "INVALID_ARGUMENTS", message: "Expected 'oldPin' and 'newPin' strings", details: nil))
            }
        }




        // changePinForm method (shows the UI form like in CardViewController)
        private static func changePinForm(_ call: FlutterMethodCall, _ result: @escaping FlutterResult, registrar: FlutterPluginRegistrar) {
            guard let sdk = sdk else {
                result(FlutterError(code: "SDK_NOT_INITIALIZED", message: "Card Management SDK not initialized", details: nil))
                return
            }

            DispatchQueue.main.async {
                // Get the root view controller (Flutter view controller)
                guard let rootViewController = UIApplication.shared.windows.first?.rootViewController else {
                    result(FlutterError(code: "NO_ROOT_CONTROLLER", message: "Cannot find root view controller", details: nil))
                    return
                }

                // Use default PIN type and config
                let pinType = NIPinFormType.dynamic // or .static based on your needs
                let config = ChangePinViewModel.Config.default

                // Create a dummy view controller and navigation controller (as done in CardViewController)
                let dummyVC = UIViewController()
                let navVC = UINavigationController(rootViewController: dummyVC)
                navVC.isNavigationBarHidden = true

                // Print pinType and config details
                print("--- Change PinType: \(pinType) ---")
                print("--- Change Config: \(config) ---")

                // Present the Change PIN form
                sdk.changePinForm(
                    type: pinType,
                    config: config,
                    viewController: dummyVC
                ) { successResponse, errorResponse, callback in
                    DispatchQueue.main.async {
                        // Dismiss the navigation controller
                        navVC.dismiss(animated: true) {
                            if let error = errorResponse {
                                result(FlutterError(
                                    code: error.errorCode ?? "CHANGE_PIN_FORM_ERROR",
                                    message: error.errorMessage,
                                    details: nil
                                ))
                            } else if let success = successResponse {
                                result([
                                    "success": true,
                                    "message": success.message
                                ])
                            } else {
                                result(FlutterError(
                                    code: "UNKNOWN_ERROR",
                                    message: "Unknown error occurred while changing PIN",
                                    details: nil
                                ))
                            }
                            callback() // Call the callback as required by the SDK
                        }
                    }
                }

                // Present the navigation controller
                rootViewController.present(navVC, animated: true)
            }
            }
        }

// Simple implementation of NICardManagementTokenFetchable
class SimpleTokenFetchable: NICardManagementTokenFetchable {
    var isRefreshable: Bool = true

    func fetchToken(completion: @escaping (Result<NICardManagementSDK.AccessToken, NICardManagementSDK.TokenError>) -> Void) {
        print("fetchToken called")

        let tokenString = SDKConfiguration.authToken

        // Add validation for token
        if tokenString.isEmpty || tokenString.contains("your-auth-token") {
            print("Token not configured properly")
            // Use a generic network error or similar - check TokenError enum for available cases
            let error = NSError(domain: "TokenFetch", code: -1, userInfo: [NSLocalizedDescriptionKey: "Token is missing or invalid"])

            // ✅ Print full error here
            print("Token error (local): \(error.localizedDescription)")
            print("Token error (full): \(error)")

            completion(.failure(.networkError(error)))
            return
        }

        print("Creating access token with value: \(tokenString)")

        // Use the correct AccessToken initializer with expiresIn (duration in seconds)
        let accessToken = AccessToken(
            value: tokenString,
            type: "Bearer", // Optional: specify token type if needed
            expiresIn: 3600 // Token expires in 1 hour (3600 seconds)
        )

        print("AccessToken created successfully")
        completion(.success(accessToken))
    }

    func clearToken() {
        print("Token cleared")
    }
}
