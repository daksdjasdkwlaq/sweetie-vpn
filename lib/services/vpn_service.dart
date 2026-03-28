import 'package:flutter/services.dart';
import '../models/server_config.dart';
import 'singbox_config.dart';

class VpnNativeService {
  static const _channel = MethodChannel('com.sweetie.sweetie_vpn/vpn');

  static Future<bool> start(ServerConfig server) async {
    try {
      final config = SingBoxConfig.toJson(server);
      final result = await _channel.invokeMethod<bool>('startVpn', {'config': config});
      return result ?? false;
    } on PlatformException catch (e) {
      throw Exception('Failed to start VPN: ${e.message}');
    }
  }

  static Future<bool> stop() async {
    try {
      final result = await _channel.invokeMethod<bool>('stopVpn');
      return result ?? false;
    } on PlatformException catch (e) {
      throw Exception('Failed to stop VPN: ${e.message}');
    }
  }

  static Future<bool> isRunning() async {
    try {
      final result = await _channel.invokeMethod<bool>('isRunning');
      return result ?? false;
    } catch (_) {
      return false;
    }
  }
}
