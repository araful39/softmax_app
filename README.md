# softmax_app

A new Flutter project.

## Getting Started


## Project Overview

This Flutter project demonstrates a complete mini-application built to showcase essential real-world development skills. It implements authentication, REST API integration, infinite scrolling, deep linking, and native Android communication using MethodChannel.

The architecture follows clean coding practices with Provider for state management, ensuring scalability and easy maintenance.

The project consists of four major features.

## Open AndroidManifest.xml

Inside <activity android:name=".MainActivity"> add:


    <intent-filter android:autoVerify="true">
    <action android:name="android.intent.action.VIEW" />
    <category android:name="android.intent.category.DEFAULT" />
    <category android:name="android.intent.category.BROWSABLE" />
    <data android:scheme="https" android:host="dummyjson.com" />
</intent-filter>




  Future<void> _initDeepLinkListener() async {
    Uri? initialLink = await _appLinks.getInitialLink();
    if (initialLink != null) {
      log('Cold start - Initial Link: $initialLink');
      _handleDeepLink(initialLink);
    }

    if (!isListening) {
      isListening = true;
      _appLinks.uriLinkStream.listen(
        (Uri? uri) {
          if (uri != null) _handleDeepLink(uri);
        },
        onError: (err) => log('Deep link stream error: $err'),
      );
    }
  }

  void _handleDeepLink(Uri uri) async {
    log('Handling deep link: $uri');

    if (uri.host != 'dummyjson.com') return;

    if (uri.pathSegments.length >= 2 && uri.pathSegments[0] == 'posts') {
      final String postId = uri.pathSegments[1];
      if (postId.isEmpty) return;

      final authProvider = context.read<AuthProvider>();

      if (authProvider.user == null) {
        bool success = await authProvider.login("emilys", "emilyspass");
        if (!success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Auto-login failed. Please login manually.")),
          );
          return;
        }
      }

      if (!mounted) return;

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => PostDetailsScreen(postId: int.parse(postId)),
        ),
      );
    }
  }




  

## ADB Deep Link Test Command:

adb shell am start -a android.intent.action.VIEW -c android.intent.category.BROWSABLE -d "https://dummyjson.com/posts/1" com.softmax.app



## MethodChannel Setup (Android):
Open MainActivity.kt
android/app/src/main/kotlin/.../MainActivity.kt


package com.softmax.app
import android.os.Build
import android.provider.Settings
import androidx.annotation.NonNull
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity: FlutterActivity() {

    private val CHANNEL = "com.example.device_info/methods"

    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)
            .setMethodCallHandler { call, result ->

                if (call.method == "getAllDeviceInfo") {
                    val info = getDeviceInformation()
                    result.success(info)
                } else {
                    result.notImplemented()
                }
            }
    }

    private fun getDeviceInformation(): String {

        val androidId = Settings.Secure.getString(
            contentResolver,
            Settings.Secure.ANDROID_ID
        )

        return """
DeviceID: $androidId
Model: ${Build.MODEL}
ID: ${Build.ID}
SDK: ${Build.VERSION.SDK_INT}
Manufacture: ${Build.MANUFACTURER}
Brand: ${Build.BRAND}
User: ${Build.USER}
Type: ${Build.TYPE}
Base: ${Build.VERSION_CODES.BASE}
Incremental: ${Build.VERSION.INCREMENTAL}
Board: ${Build.BOARD}
Host: ${Build.HOST}
FingerPrint: ${Build.FINGERPRINT}
Version Code: ${Build.VERSION.RELEASE}
""".trimIndent()
    }
}





Future<void> _getDeviceInfo() async {
    String deviceInfo;
    try {
      final String result = await platform.invokeMethod('getAllDeviceInfo');
      deviceInfo = result;
    } on PlatformException catch (e) {
      deviceInfo = "Failed to get device info: '${e.message}'.";
    }

    if (!mounted) return;

    setState(() => _deviceInfo = deviceInfo);
    _showSuccessDialog();
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => SuccessDialog(deviceInfo: _deviceInfo),
    );

    Future.delayed(const Duration(milliseconds: 2500), () {
      if (mounted && Navigator.canPop(context)) Navigator.of(context).pop();
    });
  }





## apk:

https://drive.google.com/file/d/1tIuhV737dtfI2Pq3wcEV4JkiaUf1jSnH/view?usp=sharing

## video:

https://youtu.be/xT4GPZJruYY?si=3ddFwMUf9k_brYDX


<img width="438" height="878" alt="image" src="https://github.com/user-attachments/assets/2e007148-9daf-4200-8d87-dad21fab0201" />

<img width="407" height="881" alt="image" src="https://github.com/user-attachments/assets/da3609be-8318-4182-98db-f31fe1fda569" />

<img width="423" height="883" alt="image" src="https://github.com/user-attachments/assets/c2fe4a7b-ca13-469d-9f91-0f4cca9fa646" />

<img width="470" height="897" alt="image" src="https://github.com/user-attachments/assets/0ee71a48-7e56-445b-a761-c5899b0842bf" />
<img width="425" height="893" alt="image" src="https://github.com/user-attachments/assets/a9e9827e-e7f2-49d0-a835-0a5b738bfb68" />
<img width="423" height="891" alt="image" src="https://github.com/user-attachments/assets/bbe0e4f7-d371-4854-a8ee-228a56f2b7c4" />





