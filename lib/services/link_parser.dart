import 'dart:convert';
import 'package:uuid/uuid.dart';
import '../models/server_config.dart';

class LinkParser {
  static const _uuid = Uuid();

  static ServerConfig? parse(String raw) {
    final link = raw.trim();
    try {
      if (link.startsWith('vless://')) return _parseVless(link);
      if (link.startsWith('vmess://')) return _parseVmess(link);
      if (link.startsWith('ss://')) return _parseShadowsocks(link);
      if (link.startsWith('trojan://')) return _parseTrojan(link);
      if (link.startsWith('hysteria2://') || link.startsWith('hy2://')) {
        return _parseHysteria2(link);
      }
    } catch (_) {}
    return null;
  }

  static ServerConfig _parseVless(String link) {
    // vless://uuid@host:port?params#name
    final uri = Uri.parse(link.replaceFirst('vless://', 'https://'));
    final name = Uri.decodeComponent(uri.fragment.isEmpty ? 'VLESS Server' : uri.fragment);
    return ServerConfig(
      id: _uuid.v4(),
      name: name,
      address: uri.host,
      port: uri.port,
      protocol: Protocol.vless,
      extra: {
        'uuid': uri.userInfo,
        ...uri.queryParameters,
      },
      rawLink: link,
    );
  }

  static ServerConfig _parseVmess(String link) {
    // vmess://base64json
    final b64 = link.replaceFirst('vmess://', '');
    final json = jsonDecode(utf8.decode(base64Url.decode(base64Url.normalize(b64))));
    return ServerConfig(
      id: _uuid.v4(),
      name: json['ps'] ?? json['remarks'] ?? 'VMess Server',
      address: json['add'] ?? '',
      port: int.tryParse(json['port'].toString()) ?? 443,
      protocol: Protocol.vmess,
      extra: Map<String, dynamic>.from(json),
      rawLink: link,
    );
  }

  static ServerConfig _parseShadowsocks(String link) {
    // ss://base64(method:password)@host:port#name  OR  ss://base64@host:port#name
    final withoutScheme = link.replaceFirst('ss://', '');
    final hashIdx = withoutScheme.indexOf('#');
    final name = hashIdx != -1
        ? Uri.decodeComponent(withoutScheme.substring(hashIdx + 1))
        : 'SS Server';
    final main = hashIdx != -1 ? withoutScheme.substring(0, hashIdx) : withoutScheme;

    final atIdx = main.lastIndexOf('@');
    String method = '', password = '';
    String hostPort = main;

    if (atIdx != -1) {
      final userInfo = main.substring(0, atIdx);
      hostPort = main.substring(atIdx + 1);
      try {
        final decoded = utf8.decode(base64Url.decode(base64Url.normalize(userInfo)));
        final colonIdx = decoded.indexOf(':');
        method = decoded.substring(0, colonIdx);
        password = decoded.substring(colonIdx + 1);
      } catch (_) {
        final colonIdx = userInfo.indexOf(':');
        method = userInfo.substring(0, colonIdx);
        password = userInfo.substring(colonIdx + 1);
      }
    }

    final colonIdx = hostPort.lastIndexOf(':');
    final host = hostPort.substring(0, colonIdx);
    final port = int.tryParse(hostPort.substring(colonIdx + 1)) ?? 443;

    return ServerConfig(
      id: _uuid.v4(),
      name: name,
      address: host,
      port: port,
      protocol: Protocol.shadowsocks,
      extra: {'method': method, 'password': password},
      rawLink: link,
    );
  }

  static ServerConfig _parseTrojan(String link) {
    // trojan://password@host:port?params#name
    final uri = Uri.parse(link.replaceFirst('trojan://', 'https://'));
    final name = Uri.decodeComponent(uri.fragment.isEmpty ? 'Trojan Server' : uri.fragment);
    return ServerConfig(
      id: _uuid.v4(),
      name: name,
      address: uri.host,
      port: uri.port,
      protocol: Protocol.trojan,
      extra: {'password': uri.userInfo, ...uri.queryParameters},
      rawLink: link,
    );
  }

  static ServerConfig _parseHysteria2(String link) {
    // hysteria2://auth@host:port?params#name
    final normalized = link.replaceFirst(RegExp(r'^hy2://'), 'hysteria2://');
    final uri = Uri.parse(normalized.replaceFirst('hysteria2://', 'https://'));
    final name = Uri.decodeComponent(uri.fragment.isEmpty ? 'Hysteria2 Server' : uri.fragment);
    return ServerConfig(
      id: _uuid.v4(),
      name: name,
      address: uri.host,
      port: uri.port,
      protocol: Protocol.hysteria2,
      extra: {'auth': uri.userInfo, ...uri.queryParameters},
      rawLink: link,
    );
  }
}
