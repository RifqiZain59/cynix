package com.example.cynix

import android.app.Activity
import android.app.Service
import android.app.role.RoleManager
import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.os.Build
import android.os.IBinder
import androidx.annotation.NonNull
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity: FlutterActivity() {
    private val CHANNEL = "com.cynix.app/call_screening"
    private val ROLE_DIALER_CODE = 123
    private val ROLE_SMS_CODE = 124

    private var pendingResult: MethodChannel.Result? = null

    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "checkRoles" -> {
                    result.success(checkCurrentRoles())
                }
                "requestRole" -> {
                    pendingResult = result
                    requestSystemRole(RoleManager.ROLE_DIALER, ROLE_DIALER_CODE)
                }
                "requestSmsRole" -> {
                    pendingResult = result
                    requestSystemRole(RoleManager.ROLE_SMS, ROLE_SMS_CODE)
                }
                else -> {
                    result.notImplemented()
                }
            }
        }
    }

    private fun checkCurrentRoles(): Int {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
            val roleManager = getSystemService(Context.ROLE_SERVICE) as RoleManager
            val isDialer = roleManager.isRoleHeld(RoleManager.ROLE_DIALER)
            val isSms = roleManager.isRoleHeld(RoleManager.ROLE_SMS)

            if (isDialer && isSms) return 2 // Hijau
            if (isDialer) return 1          // Kuning
            return 0                        // Merah
        }
        return 0
    }

    private fun requestSystemRole(roleName: String, requestCode: Int) {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
            val roleManager = getSystemService(Context.ROLE_SERVICE) as RoleManager
            
            if (!roleManager.isRoleHeld(roleName)) {
                val intent = roleManager.createRequestRoleIntent(roleName)
                startActivityForResult(intent, requestCode)
            } else {
                pendingResult?.success("Sudah Default")
                pendingResult = null
            }
        } else {
            pendingResult?.error("GAGAL", "Android versi lama", null)
            pendingResult = null
        }
    }

    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        super.onActivityResult(requestCode, resultCode, data)
        
        if (requestCode == ROLE_DIALER_CODE || requestCode == ROLE_SMS_CODE) {
            if (resultCode == Activity.RESULT_OK) {
                pendingResult?.success("Berhasil")
            } else {
                pendingResult?.error("DIBATALKAN", "User membatalkan izin", null)
            }
            pendingResult = null 
        }
    }
}

// ======================================================================
// KELAS FORMALITAS (WAJIB ADA) AGAR ANDROID MENGAKUI CYNIX SEBAGAI APLIKASI SMS
// ======================================================================

class SmsReceiver : BroadcastReceiver() {
    override fun onReceive(context: Context, intent: Intent) {}
}

class MmsReceiver : BroadcastReceiver() {
    override fun onReceive(context: Context, intent: Intent) {}
}

class HeadlessSmsSendService : Service() {
    override fun onBind(intent: Intent): IBinder? = null
}

class ComposeSmsActivity : Activity() {
    override fun onResume() {
        super.onResume()
        finish() // Langsung tutup agar tidak mengganggu UI Flutter
    }
}