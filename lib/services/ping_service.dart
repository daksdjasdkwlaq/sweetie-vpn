import 'dart:async';
import 'package:http/http.dart' as http;
import '../models/server_config.dart';

class PingService {
  static Future<int?> ping(ServerConfig server) async {
    final stopwatch = Stopwatch()..start();
    try {
      final uri = Uri.parse('http://${server.address}:${server.port}');
      await http.get(uri).timeout(const Duration(seconds: 5));
      stopwatch.stop();
      return stopwatch.elapsedMilliseconds;
    } on TimeoutException {
      return null;
    } catch (_) {
      stopwatch.stop();
      // Сервер ответил ошибкой, но он доступен
      if (stopwatch.elapsedMilliseconds < 5000) {
        return stopwatch.elapsedMilliseconds;
      }
      return null;
    }
  }
}
