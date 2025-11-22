import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  static const platform = MethodChannel('com.example.device_info/methods');
  String _deviceInfo = 'Press the button to get device info';

  Future<void> _getDeviceInfo() async {
    String deviceInfo;
    try {
      final String result = await platform.invokeMethod('getAllDeviceInfo');
      deviceInfo = result;
    } on PlatformException catch (e) {
      deviceInfo = "Failed to get device info: '${e.message}'.";
    }

    setState(() {
      _deviceInfo = deviceInfo;
    });

    // Show success dialog after getting info
    _showSuccessDialog();
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => SuccessDialog(deviceInfo: _deviceInfo),
    );

    // Auto close after 2.5 seconds
    Future.delayed(const Duration(milliseconds: 2500), () {
      if (mounted && Navigator.canPop(context)) {
        Navigator.of(context).pop();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Native Device Info'),
        backgroundColor: Colors.teal,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _getDeviceInfo,
        backgroundColor: Colors.teal,
        child: const Icon(Icons.refresh),
      ),

      // body: Center(
      //   child: Padding(
      //     padding: const EdgeInsets.all(20.0),
      //     child: Column(
      //       mainAxisAlignment: MainAxisAlignment.center,
      //       children: [
      //         const Icon(Icons.phone_android, size: 80, color: Colors.teal),
      //         const SizedBox(height: 30),
      //         Text(
      //           _deviceInfo,
      //           textAlign: TextAlign.center,
      //           style: const TextStyle(fontSize: 16),
      //         ),
      //         const SizedBox(height: 40),
      //         ElevatedButton.icon(
      //           onPressed: _getDeviceInfo,
      //           icon: const Icon(Icons.info_outline),
      //           label: const Text('Get Device Info'),
      //           style: ElevatedButton.styleFrom(
      //             backgroundColor: Colors.teal,
      //             padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
      //             textStyle: const TextStyle(fontSize: 18),
      //           ),
      //         ),
      //       ],
      //     ),
      //   ),
      // ),
    );
  }
}

// Beautiful Success Dialog Widget
class SuccessDialog extends StatelessWidget {
  const SuccessDialog({super.key, required this.deviceInfo});

  final String deviceInfo;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(30),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 90,
              height: 90,
              decoration: const BoxDecoration(
                color: Colors.green,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.check, size: 56, color: Colors.white),
            ),
            const SizedBox(height: 24),
            const Text(
              'Success!',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.green,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              deviceInfo,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, color: Colors.black87),
            ),
          ],
        ),
      ),
    );
  }
}
