package com.example.arge_stack;

import android.Manifest;
import android.content.Context;
import android.content.pm.PackageManager;
import android.os.Build;
import android.telecom.TelecomManager;
import android.telephony.TelephonyManager;
import androidx.annotation.NonNull;
import androidx.core.app.ActivityCompat;

import com.android.internal.telephony.ITelephony;

import java.lang.reflect.Method;
import io.flutter.Log;
import io.flutter.embedding.android.FlutterActivity;
import io.flutter.embedding.engine.FlutterEngine;
import io.flutter.plugin.common.BinaryMessenger;
import io.flutter.plugin.common.MethodChannel;
public class MainActivity extends FlutterActivity {

    static final String CHANNEL = "telephony";
    private MethodChannel methodChannel;

    public void configureFlutterEngine(@NonNull FlutterEngine flutterEngine) {
        super.configureFlutterEngine(flutterEngine);
        BinaryMessenger messenger = flutterEngine.getDartExecutor().getBinaryMessenger();
        methodChannel = new MethodChannel(messenger, CHANNEL);
        methodChannel.setMethodCallHandler((call, result) -> {
            if (call.method.equals("endCall")) {

                cutTheCall();
            } else {
                result.notImplemented();
            }
        });
    }


    private boolean cutTheCall() {
        TelecomManager telecomManager =
                (TelecomManager) getApplicationContext().getSystemService(TELECOM_SERVICE);
        ///If we dont have permissions or telecomservice returns null,then the function return false
        if (ActivityCompat.checkSelfPermission(this, Manifest.permission.READ_PHONE_STATE) != PackageManager.PERMISSION_GRANTED || telecomManager == null) {
            return false;
        }

        if (telecomManager.isInCall()) {
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.P) {
                telecomManager.endCall();
            }
        
        }
        return true;
    }

    public void finishCall() {
        /// The method did'nt work because endcall method depreceated
        /// https://developer.android.com/reference/android/telecom/TelecomManager#endCall()
        /// The telephonyManager class throw us modify phone state permission required.But we add the
        /// permissions to manifest file.So we are using cutTheCAll function and it works
        try {
            TelephonyManager manager = (TelephonyManager) getSystemService(Context.TELEPHONY_SERVICE);
            Class c = Class.forName(manager.getClass().getName());
            Method m = c.getDeclaredMethod("getITelephony");
            m.setAccessible(true);
            ITelephony telephony = (ITelephony) m.invoke(manager);

            /// we need to define ITelephony as an interface and rebuild project to get generated java code
            /// After generate java code we can import the interface.
            /// https://github.com/cayden/autophone/blob/master/src/com/android/internal/telephony/ITelephony.aidl

            telephony.endCall();
        } catch (Exception e) {
            Log.d("", e.getMessage());
        }

    }
}
