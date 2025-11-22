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