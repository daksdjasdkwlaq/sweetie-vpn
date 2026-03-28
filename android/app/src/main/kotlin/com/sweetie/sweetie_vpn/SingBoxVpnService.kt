package com.sweetie.sweetie_vpn

import android.app.Notification
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.content.Intent
import android.net.VpnService
import android.os.Build
import android.os.ParcelFileDescriptor
import android.util.Log
import java.io.File
import java.io.FileOutputStream

class SingBoxVpnService : VpnService() {
    companion object {
        const val TAG = "SingBoxVpnService"
        const val ACTION_START = "START"
        const val ACTION_STOP = "STOP"
        const val EXTRA_CONFIG = "config"
        const val CHANNEL_ID = "vpn_channel"
        const val NOTIFICATION_ID = 1
        var isRunning = false
    }

    private var vpnInterface: ParcelFileDescriptor? = null
    private var singBoxProcess: Process? = null

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        when (intent?.action) {
            ACTION_START -> {
                val config = intent.getStringExtra(EXTRA_CONFIG) ?: return START_NOT_STICKY
                startVpn(config)
            }
            ACTION_STOP -> stopVpn()
        }
        return START_NOT_STICKY
    }

    private fun startVpn(config: String) {
        try {
            createNotificationChannel()
            startForeground(NOTIFICATION_ID, buildNotification())

            // Write config to file
            val configFile = File(filesDir, "config.json")
            configFile.writeText(config)

            // Extract sing-box binary
            val binaryFile = extractBinary()

            // Build VPN interface
            val builder = Builder()
                .setSession("Sweetie VPN")
                .addAddress("10.0.0.1", 32)
                .addAddress("fd00::1", 128)
                .addDnsServer("8.8.8.8")
                .addDnsServer("8.8.4.4")
                .addRoute("0.0.0.0", 0)
                .addRoute("::", 0)
                .setMtu(1500)

            vpnInterface = builder.establish()

            val fd = vpnInterface?.fd ?: return

            // Start sing-box process
            val cmd = arrayOf(
                binaryFile.absolutePath,
                "run",
                "-c", configFile.absolutePath,
                "--disable-color"
            )

            singBoxProcess = ProcessBuilder(*cmd)
                .redirectErrorStream(true)
                .start()

            isRunning = true
            Log.d(TAG, "VPN started")

        } catch (e: Exception) {
            Log.e(TAG, "Failed to start VPN: ${e.message}")
            stopVpn()
        }
    }

    private fun stopVpn() {
        singBoxProcess?.destroy()
        singBoxProcess = null
        vpnInterface?.close()
        vpnInterface = null
        isRunning = false
        stopForeground(true)
        stopSelf()
        Log.d(TAG, "VPN stopped")
    }

    private fun extractBinary(): File {
        val abi = Build.SUPPORTED_ABIS[0]
        val assetName = when {
            abi.contains("arm64") -> "sing-box-arm64"
            abi.contains("armeabi") -> "sing-box-arm"
            abi.contains("x86_64") -> "sing-box-x86_64"
            else -> "sing-box-arm64"
        }

        val binaryFile = File(filesDir, "sing-box")
        if (!binaryFile.exists()) {
            assets.open(assetName).use { input ->
                FileOutputStream(binaryFile).use { output ->
                    input.copyTo(output)
                }
            }
            binaryFile.setExecutable(true)
        }
        return binaryFile
    }

    private fun createNotificationChannel() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val channel = NotificationChannel(
                CHANNEL_ID,
                "VPN Service",
                NotificationManager.IMPORTANCE_LOW
            )
            val manager = getSystemService(NotificationManager::class.java)
            manager.createNotificationChannel(channel)
        }
    }

    private fun buildNotification(): Notification {
        val intent = packageManager.getLaunchIntentForPackage(packageName)
        val pendingIntent = PendingIntent.getActivity(
            this, 0, intent,
            PendingIntent.FLAG_IMMUTABLE
        )

        return if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            Notification.Builder(this, CHANNEL_ID)
                .setContentTitle("Sweetie VPN")
                .setContentText("Подключено")
                .setSmallIcon(android.R.drawable.ic_dialog_info)
                .setContentIntent(pendingIntent)
                .build()
        } else {
            @Suppress("DEPRECATION")
            Notification.Builder(this)
                .setContentTitle("Sweetie VPN")
                .setContentText("Подключено")
                .setSmallIcon(android.R.drawable.ic_dialog_info)
                .setContentIntent(pendingIntent)
                .build()
        }
    }

    override fun onDestroy() {
        stopVpn()
        super.onDestroy()
    }
}
