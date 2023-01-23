package com.example.arge_stack;

import android.content.Context;
import android.telephony.TelephonyManager;

import androidx.annotation.NonNull;

import java.lang.reflect.Method;

import io.flutter.Log;
import io.flutter.embedding.android.FlutterActivity;
import io.flutter.embedding.engine.FlutterEngine;
import io.flutter.plugin.common.BinaryMessenger;
import io.flutter.plugin.common.MethodChannel;

public class mainActivity2 extends FlutterActivity {

    static final String CHANNEL = "telephony";
    private MethodChannel methodChannel;

    public void configureFlutterEngine(@NonNull FlutterEngine flutterEngine ) {
        super.configureFlutterEngine(flutterEngine);
        BinaryMessenger messenger = flutterEngine.getDartExecutor().getBinaryMessenger();
        methodChannel =new MethodChannel(messenger,CHANNEL) ;
        methodChannel.setMethodCallHandler((call,result)->{
            if (call.method == "endCall") {

                result.success(finishCall());
            } else {
                result.notImplemented();
            }
        });
    }

    public Object finishCall() {
        try{
            TelephonyManager manager = (TelephonyManager) getSystemService(Context.TELEPHONY_SERVICE);
            Class c = Class.forName(manager.getClass().getName());
            Method m = c.getDeclaredMethod("getITelephony");
            m.setAccessible(true);
            ITelephony telephony = (ITelephony)m.invoke(manager);
            telephony.endCall();
        } catch(Exception e){
            Log.d("",e.getMessage());
        }
        return null;
    }
}
