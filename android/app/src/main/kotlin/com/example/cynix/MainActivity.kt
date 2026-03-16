package com.example.cynix // <-- JANGAN LUPA SESUAIKAN NAMA PACKAGE INI JIKA BERBEDA

import android.app.Activity
import android.app.Service
import android.app.role.RoleManager
import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.os.Build
import android.os.IBinder
import android.provider.CallLog // <-- IMPORT INI PENTING UNTUK BACA RIWAYAT
import android.telephony.TelephonyManager
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
                "getSimInfo" -> {
                    val telephonyManager = getSystemService(Context.TELEPHONY_SERVICE) as TelephonyManager
                    val carrierName = telephonyManager.networkOperatorName
                    var phoneNumber = ""

                    try {
                        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
                            if (checkSelfPermission(android.Manifest.permission.READ_PHONE_STATE) == android.content.pm.PackageManager.PERMISSION_GRANTED) {
                                phoneNumber = telephonyManager.line1Number ?: ""
                            }
                        } else {
                            phoneNumber = telephonyManager.line1Number ?: ""
                        }
                    } catch (e: Exception) {
                        phoneNumber = ""
                    }

                    val info = mapOf(
                        "carrierName" to if (carrierName.isNotEmpty()) carrierName else "Tidak Diketahui",
                        "phoneNumber" to if (phoneNumber.isNotEmpty()) phoneNumber else "Tidak Tersedia di SIM"
                    )
                    result.success(info)
                }
                // ============================================================
                // FITUR BARU: BACA SEMUA RIWAYAT PANGGILAN
                // ============================================================
                "getAllCallLogs" -> {
                    val logs = fetchCallLogs()
                    result.success(logs)
                }
                // ============================================================
                // FITUR BARU: HAPUS RIWAYAT PANGGILAN
                // ============================================================
                "clearCallLogs" -> {
                    val isDeleted = deleteCallLogs()
                    result.success(isDeleted)
                }
                else -> {
                    result.notImplemented()
                }
            }
        }
    }

    // ============================================================
    // FUNGSI KOTLIN UNTUK MEMBACA DATABASE TELEPON HP
    // ============================================================
    private fun fetchCallLogs(): List<Map<String, Any?>> {
        val callLogList = mutableListOf<Map<String, Any?>>()
        
        // Cek Izin Dulu
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
            if (checkSelfPermission(android.Manifest.permission.READ_CALL_LOG) != android.content.pm.PackageManager.PERMISSION_GRANTED) {
                return callLogList // Kembali kosong jika belum ada izin
            }
        }

        try {
            // Mengambil data dari CallLog Provider Android, diurutkan dari yang terbaru
            val cursor = contentResolver.query(
                CallLog.Calls.CONTENT_URI,
                null, null, null, CallLog.Calls.DATE + " DESC"
            )

            cursor?.use {
                val numberIndex = it.getColumnIndex(CallLog.Calls.NUMBER)
                val nameIndex = it.getColumnIndex(CallLog.Calls.CACHED_NAME)
                val typeIndex = it.getColumnIndex(CallLog.Calls.TYPE)
                val dateIndex = it.getColumnIndex(CallLog.Calls.DATE)

                var count = 0
                // Ambil maksimal 100 riwayat terbaru agar aplikasi tidak lemot
                while (it.moveToNext() && count < 100) { 
                    val typeInt = it.getInt(typeIndex)
                    
                    // Memetakan Tipe Panggilan ke String yang dikenali Flutter
                    val typeString = when (typeInt) {
                        CallLog.Calls.INCOMING_TYPE -> "INCOMING"
                        CallLog.Calls.OUTGOING_TYPE -> "OUTGOING"
                        CallLog.Calls.MISSED_TYPE -> "MISSED"
                        CallLog.Calls.REJECTED_TYPE -> "BLOCKED_SYSTEM"
                        CallLog.Calls.BLOCKED_TYPE -> "BLOCKED_SYSTEM"
                        else -> "INCOMING"
                    }

                    val logMap = mapOf(
                        "number" to (it.getString(numberIndex) ?: "Unknown"),
                        "name" to (it.getString(nameIndex) ?: ""),
                        "timestamp" to it.getLong(dateIndex),
                        "type" to typeString
                    )
                    callLogList.add(logMap)
                    count++
                }
            }
        } catch (e: Exception) {
            e.printStackTrace()
        }
        
        return callLogList
    }

    // ============================================================
    // FUNGSI KOTLIN UNTUK MENGHAPUS RIWAYAT (JIKA TOMBOL DITEKAN)
    // ============================================================
    private fun deleteCallLogs(): Boolean {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
            if (checkSelfPermission(android.Manifest.permission.WRITE_CALL_LOG) != android.content.pm.PackageManager.PERMISSION_GRANTED) {
                return false
            }
        }
        return try {
            contentResolver.delete(CallLog.Calls.CONTENT_URI, null, null)
            true
        } catch (e: Exception) {
            false
        }
    }

    private fun checkCurrentRoles(): Int {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
            val roleManager = getSystemService(Context.ROLE_SERVICE) as RoleManager
            val isDialer = roleManager.isRoleHeld(RoleManager.ROLE_DIALER)
            val isSms = roleManager.isRoleHeld(RoleManager.ROLE_SMS)

            if (isDialer && isSms) return 2 // Hijau (Aman)
            if (isDialer) return 1          // Kuning (Menengah)
            return 0                        // Merah (Rendah)
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