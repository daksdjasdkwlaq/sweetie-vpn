package com.sweetie.sweetie_vpn

import android.content.Intent
import android.net.VpnService
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val CHANNEL = "com.sweetie.sweetie_vpn/vpn"
    private val VPN_REQUEST_CODE = 100
    private var pendingConfig: String? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "startVpn" -> {
                    val config = call.argument<String>("config")
                    if (config == null) {
                        result.error("INVALID_CONFIG", "Config is null", null)
                        return@setMethodCallHandler
                    }
                    val intent = VpnService.prepare(this)
                    if (intent != null) {
                        pendingConfig = config
                        startActivityForResult(intent, VPN_REQUEST_CODE)
                    } else {
                        startVpnService(config)
                    }
                    result.success(true)
                }
                "stopVpn" -> {
                    val intent = Intent(this, SingBoxVpnService::class.java)
                    intent.action = SingBoxVpnService.ACTION_STOP
                    startService(intent)
                    result.success(true)
                }
                "isRunning" -> {
                    result.success(SingBoxVpnService.isRunning)
                }
                else -> result.notImplemented()
            }
        }
    }

    private fun startVpnService(config: String) {
        val intent = Intent(this, SingBoxVpnService::class.java)
        intent.action = SingBoxVpnService.ACTION_START
        intent.putExtra(SingBoxVpnService.EXTRA_CONFIG, config)
        startService(intent)
    }

    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        super.onActivityResult(requestCode, resultCode, data)
        if (requestCode == VPN_REQUEST_CODE && resultCode == RESULT_OK) {
            pendingConfig?.let { startVpnService(it) }
            pendingConfig = null
        }
    }
}
