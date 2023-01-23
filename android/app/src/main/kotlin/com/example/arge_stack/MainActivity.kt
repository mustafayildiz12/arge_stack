package com.example.arge_stack

import android.content.Context
import android.telephony.TelephonyManager
import android.util.Log
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.lang.reflect.Method


class MainActivity: FlutterActivity() {

    private val CHANNEL = "telephony"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler {
                call, result ->
            if (call.method == "endCall") {
                val caller = finishCall()

                result.success(caller)
            } else {
                result.notImplemented()
            }
        }
    }
    private fun finishCall(){
        try {
            val manager = context.getSystemService(Context.TELEPHONY_SERVICE) as TelephonyManager
            val c = Class.forName(manager.javaClass.name)
            val m: Method = c.getDeclaredMethod("getITelephony")
            m.setAccessible(true)
            val telephony = m.invoke(manager) as ITelephony
            telephony.endCall()
        } catch (e: Exception) {
         //   Log.d( e.message,"")
        }
    }

}