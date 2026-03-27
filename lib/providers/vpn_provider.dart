import 'package:flutter/foundation.dart';
import '../models/server_config.dart';
import '../services/storage_service.dart';
import '../services/ping_service.dart';

enum VpnStatus { disconnected, connecting, connected }

class VpnProvider extends ChangeNotifier {
  final _storage = StorageService();

  List<ServerConfig> _servers = [];
  ServerConfig? _selected;
  VpnStatus _status = VpnStatus.disconnected;
  int? _ping;
  bool _pinging = false;

  List<ServerConfig> get servers => _servers;
  ServerConfig? get selected => _selected;
  VpnStatus get status => _status;
  bool get isConnected => _status == VpnStatus.connected;
  int? get ping => _ping;
  bool get pinging => _pinging;

  Future<void> init() async {
    _servers = await _storage.loadServers();
    final selectedId = await _storage.loadSelectedId();
    if (selectedId != null) {
      try {
        _selected = _servers.firstWhere((s) => s.id == selectedId);
      } catch (_) {}
    }
    notifyListeners();
  }

  Future<void> addServer(ServerConfig config) async {
    _servers.add(config);
    await _storage.saveServers(_servers);
    if (_selected == null) {
      _selected = config;
      await _storage.saveSelectedId(config.id);
    }
    notifyListeners();
  }

  Future<void> removeServer(String id) async {
    _servers.removeWhere((s) => s.id == id);
    if (_selected?.id == id) {
      _selected = _servers.isNotEmpty ? _servers.first : null;
      await _storage.saveSelectedId(_selected?.id);
    }
    await _storage.saveServers(_servers);
    notifyListeners();
  }

  Future<void> selectServer(ServerConfig config) async {
    _selected = config;
    await _storage.saveSelectedId(config.id);
    notifyListeners();
  }

  Future<void> toggleConnection() async {
    if (_selected == null) return;

    if (_status == VpnStatus.connected) {
      _status = VpnStatus.disconnected;
      _ping = null;
      notifyListeners();
      return;
    }

    _status = VpnStatus.connecting;
    _ping = null;
    notifyListeners();

    await Future.delayed(const Duration(seconds: 2));
    _status = VpnStatus.connected;
    notifyListeners();

    // Измеряем пинг после подключения
    await checkPing();
  }

  Future<void> checkPing() async {
    if (_selected == null) return;
    _pinging = true;
    notifyListeners();
    _ping = await PingService.ping(_selected!);
    _pinging = false;
    notifyListeners();
  }
}
