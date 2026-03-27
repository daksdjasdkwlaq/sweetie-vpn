import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/server_config.dart';

class StorageService {
  static const _serversKey = 'servers';
  static const _selectedKey = 'selected_id';

  Future<List<ServerConfig>> loadServers() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList(_serversKey) ?? [];
    return raw.map((s) => ServerConfig.fromJson(jsonDecode(s))).toList();
  }

  Future<void> saveServers(List<ServerConfig> servers) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(
      _serversKey,
      servers.map((s) => jsonEncode(s.toJson())).toList(),
    );
  }

  Future<String?> loadSelectedId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_selectedKey);
  }

  Future<void> saveSelectedId(String? id) async {
    final prefs = await SharedPreferences.getInstance();
    if (id == null) {
      await prefs.remove(_selectedKey);
    } else {
      await prefs.setString(_selectedKey, id);
    }
  }
}
