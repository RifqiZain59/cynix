package com.example.cynix

import android.content.Context
import android.os.Build
import android.telecom.Call
import android.telecom.CallScreeningService
import android.util.Log
import androidx.annotation.RequiresApi

@RequiresApi(Build.VERSION_CODES.N)
class CynixCallScreeningService : CallScreeningService() {

    override fun onScreenCall(callDetails: Call.Details) {
        val phoneNumber = callDetails.handle?.schemeSpecificPart ?: ""
        
        if (callDetails.callDirection == Call.Details.DIRECTION_INCOMING) {
            val isSpam = checkIsSpamPattern(phoneNumber)

            if (isSpam) {
                // SIMPAN KE LOG INTERNAL CYNIX SEBELUM DIBLOKIR
                saveBlockedCallToInternal(phoneNumber)

                val response = CallResponse.Builder()
                    .setDisallowCall(true)
                    .setRejectCall(true)
                    .setSkipCallLog(true) // AKTIF: Jangan masukkan ke riwayat sistem HP
                    .setSkipNotification(true)
                    .build()
                respondToCall(callDetails, response)
            } else {
                respondToCall(callDetails, CallResponse.Builder().build())
            }
        }
    }

    private fun checkIsSpamPattern(currentNumber: String): Boolean {
        if (currentNumber.length < 9) return false
        val prefs = getSharedPreferences("CynixData", Context.MODE_PRIVATE)
        val history = prefs.getStringSet("seen_numbers", mutableSetOf()) ?: mutableSetOf()
        val currentPrefix = currentNumber.take(8)

        for (oldNumber in history) {
            if (oldNumber.take(8) == currentPrefix && currentNumber != oldNumber) return true
        }
        
        // Simpan nomor yang lewat untuk pengecekan berikutnya
        val newHistory = history.toMutableSet()
        newHistory.add(currentNumber)
        prefs.edit().putStringSet("seen_numbers", newHistory.take(20).toSet()).apply()
        
        return false
    }

    // Fungsi untuk mencatat log sendiri karena kita mematikan log sistem
    private fun saveBlockedCallToInternal(number: String) {
        val prefs = getSharedPreferences("CynixData", Context.MODE_PRIVATE)
        val blockedList = prefs.getString("blocked_list", "") ?: ""
        val timestamp = System.currentTimeMillis()
        
        // Simpan dengan format: nomor|waktu;nomor|waktu;
        val newData = "$number|$timestamp;$blockedList"
        prefs.edit().putString("blocked_list", newData.take(2000)).apply() 
    }
}