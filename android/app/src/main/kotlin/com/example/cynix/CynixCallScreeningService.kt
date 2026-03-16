package com.example.cynix

import android.os.Build
import android.telecom.InCallService
import androidx.annotation.RequiresApi

@RequiresApi(Build.VERSION_CODES.M)
class CynixInCallService : InCallService() {
}