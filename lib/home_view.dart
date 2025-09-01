// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
//
// class HomeView extends StatefulWidget {
//   const HomeView({super.key});
//
//   @override
//   State<HomeView> createState() => _HomeViewState();
// }
//
// class _HomeViewState extends State<HomeView> {
//   static const MethodChannel _channel = MethodChannel('com.example.card_sdk');
//   final TextEditingController _pinController = TextEditingController();
//
//   @override
//   void dispose() {
//     _pinController.dispose();
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text("Card Management SDK"),
//         centerTitle: true,
//         backgroundColor: Colors.blueAccent,
//         foregroundColor: Colors.white,
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(20.0),
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             // PIN Input Field
//             TextField(
//               controller: _pinController,
//               decoration: const InputDecoration(
//                 labelText: 'Enter PIN',
//                 hintText: 'Enter 4-digit PIN',
//                 border: OutlineInputBorder(),
//                 prefixIcon: Icon(Icons.lock),
//               ),
//               keyboardType: TextInputType.number,
//               maxLength: 4,
//               obscureText: true,
//             ),
//
//             const SizedBox(height: 30),
//
//             // Programmatic Set PIN Button
//             SizedBox(
//               width: double.infinity,
//               child: ElevatedButton(
//                 onPressed: () async {
//                   final pin = _pinController.text.trim();
//                   if (pin.isEmpty) {
//                     _showSnackBar("Please enter a PIN", isError: true);
//                     return;
//                   }
//                   if (pin.length != 4) {
//                     _showSnackBar("PIN must be 4 digits", isError: true);
//                     return;
//                   }
//
//                   try {
//                     final result = await _channel.invokeMethod('setPin', {
//                       "pin": pin,
//                     });
//
//                     if (result is Map && result['success'] == true) {
//                       _showSnackBar(result['message'] ?? "PIN set successfully!");
//                       _pinController.clear();
//                     } else {
//                       _showSnackBar("Failed to set PIN", isError: true);
//                     }
//                   } on PlatformException catch (e) {
//                     _showSnackBar("Error: ${e.message}", isError: true);
//                   } catch (e) {
//                     _showSnackBar("Unexpected error: $e", isError: true);
//                   }
//                 },
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: Colors.blueAccent,
//                   foregroundColor: Colors.white,
//                   padding: const EdgeInsets.symmetric(vertical: 16),
//                   shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(10),
//                   ),
//                   textStyle: const TextStyle(
//                     fontSize: 16,
//                     fontWeight: FontWeight.w600,
//                   ),
//                 ),
//                 child: const Text("Set PIN (Programmatic)"),
//               ),
//             ),
//
//             const SizedBox(height: 20),
//
//             // Form-based Set PIN Button
//             SizedBox(
//               width: double.infinity,
//               child: ElevatedButton(
//                 onPressed: () async {
//                   try {
//                     final result = await _channel.invokeMethod('setPinForm');
//
//                     if (result is Map && result['success'] == true) {
//                       _showSnackBar(result['message'] ?? "PIN set successfully using form!");
//                     } else {
//                       _showSnackBar("Failed to set PIN using form", isError: true);
//                     }
//                   } on PlatformException catch (e) {
//                     _showSnackBar("Error: ${e.message}", isError: true);
//                   } catch (e) {
//                     _showSnackBar("Unexpected error: $e", isError: true);
//                   }
//                 },
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: Colors.green,
//                   foregroundColor: Colors.white,
//                   padding: const EdgeInsets.symmetric(vertical: 16),
//                   shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(10),
//                   ),
//                   textStyle: const TextStyle(
//                     fontSize: 16,
//                     fontWeight: FontWeight.w600,
//                   ),
//                 ),
//                 child: const Text("Set PIN (Form UI)"),
//               ),
//             ),
//
//             const SizedBox(height: 40),
//
//             const Text(
//               "Note: Use 'Set PIN (Programmatic)' to set PIN directly with the entered value, or 'Set PIN (Form UI)' to show the SDK's PIN entry form.",
//               style: TextStyle(
//                 color: Colors.grey,
//                 fontSize: 12,
//               ),
//               textAlign: TextAlign.center,
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   void _showSnackBar(String message, {bool isError = false}) {
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(
//         content: Text(message),
//         backgroundColor: isError ? Colors.red : Colors.green,
//         duration: const Duration(seconds: 3),
//       ),
//     );
//   }
// }


import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  static const MethodChannel _channel = MethodChannel('com.example.card_sdk');
  final TextEditingController _pinController = TextEditingController();
  final TextEditingController _oldPinController = TextEditingController();
  final TextEditingController _newPinController = TextEditingController();

  bool _sdkConfigured = false;
  bool _isConfiguring = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _configureSDK(); // call right away
  }

  @override
  void dispose() {
    _pinController.dispose();
    _oldPinController.dispose();
    _newPinController.dispose();
    super.dispose();
  }

  Future<void> _configureSDK() async {
    setState(() {
      _isConfiguring = true;
    });

    // TODO: replace these values with real runtime values from your secure storage / server
    final config = {
      "rootUrl": "https://apiuat.za.network.global/sdk/v2",
      "cardIdentifierId": "44135857194304827113",
      "cardIdentifierType": "EXID",
      "bankCode": "ABSA",
      // IMPORTANT: pass the raw token only, NOT "Bearer <token>"
      "authToken": "eyJhbGciOiJSUzI1NiIsInR5cCIgOiAiSldUIiwia2lkIiA6ICJhVS1uNnVldXVNNWpfSU5XU1htcVc0NVBLY1psaDE3d2Q0WDRuRVFNVktFIn0.eyJleHAiOjE3NTY3NDAzODIsImlhdCI6MTc1NjczODU4MiwianRpIjoiOTY4YmI1ZWQtM2YxMy00ZDk5LWI1YjYtY2ZiMzJjNjJhNjQxIiwiaXNzIjoiaHR0cHM6Ly8xMC4yMTMuMzUuNzQvYXV0aC9yZWFsbXMvTkktTm9uUHJvZCIsInN1YiI6ImZjNmQ3ZTk5LTQwYmMtNDVmZS05NGNlLTU4NjU3ZGNlODU3NCIsInR5cCI6IkJlYXJlciIsImF6cCI6ImM5ZTJlODcwLTZhNDAtNDQ0Zi04ZDFmLTJhODYwMjJiNmNmNTQ0NjY2NCIsInNjb3BlIjoicHJvZmlsZSBlbWFpbCIsImVtYWlsX3ZlcmlmaWVkIjpmYWxzZSwiY2xpZW50SWQiOiJjOWUyZTg3MC02YTQwLTQ0NGYtOGQxZi0yYTg2MDIyYjZjZjU0NDY2NjQiLCJyb2xlIjoiYmFuayIsInJvdXRlX2lkIjoiQVBJQyIsIm9yZ19pZCI6IkFCU0EiLCJpc1BjaURzcyI6ImZhbHNlIiwicHJlZmVycmVkX3VzZXJuYW1lIjoic2VydmljZS1hY2NvdW50LWM5ZTJlODcwLTZhNDAtNDQ0Zi04ZDFmLTJhODYwMjJiNmNmNTQ0NjY2NCIsIm9yZ19jb2RlIjoiMzQzIn0.CLpGLpq-clCztb-tpJuqtt_Er0wDJ9l5UJTOO-Y-u3EEnerAxZjPVJN4MHty3gNzYryAkh87cZq8ETGco8GWUILPjzAXMHmPJP1Q-xwRIHbRjEt8r5FU-ZlrTb6an8xBhcK3BRwUgQk-EDjb0UZTq5dYYBJAuknS6HgMfrujCeOyegu_YMsX51H-DrwCkFObl3w71ETVV_dUlhYnfhkQOx0TDm4D124XPVocagc5YnYVAQfNkKT-OhjNDJDkSDXxwnW3-T9_vnlxLHIzo_AR19g9yJrRDeuws1tJTLzs95vE3SAhMW-TR9UnLtm3QP2oZO_EbWLm4gfMaf-fsJwE8g"
    };

    try {
      final result = await _channel.invokeMethod('configureSDK', config);
      if (result is Map && result['success'] == true) {
        setState(() {
          _sdkConfigured = true;
        });
        _showSnackBar(result['message'] ?? "SDK configured");
      } else {
        _showSnackBar("Failed to configure SDK", isError: true);
      }
    } on PlatformException catch (e) {
      _showSnackBar("Configuration error: ${e.message}", isError: true);
    } catch (e) {
      _showSnackBar("Unexpected error: $e", isError: true);
    } finally {
      setState(() {
        _isConfiguring = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Card Management SDK"),
        centerTitle: true,
        backgroundColor: Colors.blueAccent,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Set PIN Section
            _buildSectionTitle("Set PIN"),
            const SizedBox(height: 16),

            // PIN Input Field
            TextField(
              controller: _pinController,
              decoration: const InputDecoration(
                labelText: 'Enter PIN',
                hintText: 'Enter 4-digit PIN',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.lock),
              ),
              keyboardType: TextInputType.number,
              maxLength: 4,
              obscureText: true,
            ),

            const SizedBox(height: 20),

            // Programmatic Set PIN Button
            _buildFullWidthButton(
              text: "Set PIN (Programmatic)",
              color: Colors.blueAccent,
              onPressed: () => _setPinProgrammatic(),
            ),

            const SizedBox(height: 12),

            // Form-based Set PIN Button
            _buildFullWidthButton(
              text: "Set PIN (Form UI)",
              color: Colors.green,
              onPressed: () => _setPinForm(),
            ),

            const SizedBox(height: 40),

            // Change PIN Section
            _buildSectionTitle("Change PIN"),
            const SizedBox(height: 16),

            // Old PIN Input Field
            TextField(
              controller: _oldPinController,
              decoration: const InputDecoration(
                labelText: 'Enter Old PIN',
                hintText: 'Enter current 4-digit PIN',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.lock_open),
              ),
              keyboardType: TextInputType.number,
              maxLength: 4,
              obscureText: true,
            ),

            const SizedBox(height: 16),

            // New PIN Input Field
            TextField(
              controller: _newPinController,
              decoration: const InputDecoration(
                labelText: 'Enter New PIN',
                hintText: 'Enter new 4-digit PIN',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.lock_reset),
              ),
              keyboardType: TextInputType.number,
              maxLength: 4,
              obscureText: true,
            ),

            const SizedBox(height: 20),

            // Programmatic Change PIN Button
            _buildFullWidthButton(
              text: "Change PIN (Programmatic)",
              color: Colors.orange,
              onPressed: () => _changePinProgrammatic(),
            ),

            const SizedBox(height: 12),

            // Form-based Change PIN Button
            _buildFullWidthButton(
              text: "Change PIN (Form UI)",
              color: Colors.purple,
              onPressed: () => _changePinForm(),
            ),

            const SizedBox(height: 40),

            // Instructions
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Instructions:",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: Colors.black87,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    "• Set PIN: Use programmatic method to set PIN with entered value, or Form UI to show SDK's PIN entry form.",
                    style: TextStyle(
                      color: Colors.black54,
                      fontSize: 12,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    "• Change PIN: Use programmatic method with old/new PIN values, or Form UI to show SDK's change PIN form.",
                    style: TextStyle(
                      color: Colors.black54,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Text(
        title,
        textAlign: TextAlign.center,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.black87,
        ),
      ),
    );
  }

  Widget _buildFullWidthButton({
    required String text,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        child: Text(text),
      ),
    );
  }

  // Set PIN Programmatically
  Future<void> _setPinProgrammatic() async {
    final pin = _pinController.text.trim();
    if (pin.isEmpty) {
      _showSnackBar("Please enter a PIN", isError: true);
      return;
    }
    if (pin.length != 4) {
      _showSnackBar("PIN must be 4 digits", isError: true);
      return;
    }

    try {
      final result = await _channel.invokeMethod('setPin', {
        "pin": pin,
      });

      if (result is Map && result['success'] == true) {
        _showSnackBar(result['message'] ?? "PIN set successfully!");
        _pinController.clear();
      } else {
        _showSnackBar("Failed to set PIN", isError: true);
      }
    } on PlatformException catch (e) {
      _showSnackBar("Error: ${e.message}", isError: true);
    } catch (e) {
      _showSnackBar("Unexpected error: $e", isError: true);
    }
  }

  // Set PIN using Form UI
  Future<void> _setPinForm() async {
    try {
      final result = await _channel.invokeMethod('setPinForm');

      if (result is Map && result['success'] == true) {
        _showSnackBar(result['message'] ?? "PIN set successfully using form!");
      } else {
        _showSnackBar("Failed to set PIN using form", isError: true);
      }
    } on PlatformException catch (e) {
      _showSnackBar("Error: ${e.message}", isError: true);
    } catch (e) {
      _showSnackBar("Unexpected error: $e", isError: true);
    }
  }

  // Change PIN Programmatically
  Future<void> _changePinProgrammatic() async {
    final oldPin = _oldPinController.text.trim();
    final newPin = _newPinController.text.trim();

    if (oldPin.isEmpty || newPin.isEmpty) {
      _showSnackBar("Please enter both old and new PIN", isError: true);
      return;
    }
    if (oldPin.length != 4 || newPin.length != 4) {
      _showSnackBar("Both PINs must be 4 digits", isError: true);
      return;
    }
    if (oldPin == newPin) {
      _showSnackBar("New PIN must be different from old PIN", isError: true);
      return;
    }

    try {
      final result = await _channel.invokeMethod('changePin', {
        "oldPin": oldPin,
        "newPin": newPin,
      });

      if (result is Map && result['success'] == true) {
        _showSnackBar(result['message'] ?? "PIN changed successfully!");
        _oldPinController.clear();
        _newPinController.clear();
      } else {
        _showSnackBar("Failed to change PIN", isError: true);
      }
    } on PlatformException catch (e) {
      _showSnackBar("Error: ${e.message}", isError: true);
    } catch (e) {
      _showSnackBar("Unexpected error: $e", isError: true);
    }
  }

  // Change PIN using Form UI
  Future<void> _changePinForm() async {
    try {
      final result = await _channel.invokeMethod('changePinForm');

      if (result is Map && result['success'] == true) {
        _showSnackBar(result['message'] ?? "PIN changed successfully using form!");
      } else {
        _showSnackBar("Failed to change PIN using form", isError: true);
      }
    } on PlatformException catch (e) {
      _showSnackBar("Error: ${e.message}", isError: true);
    } catch (e) {
      _showSnackBar("Unexpected error: $e", isError: true);
    }
  }

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
        duration: const Duration(seconds: 3),
      ),
    );
  }
}