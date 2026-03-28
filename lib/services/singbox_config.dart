import 'dart:convert';
import '../models/server_config.dart';

class SingBoxConfig {
  static Map<String, dynamic> generate(ServerConfig server) {
    return {
      "log": {"level": "info"},
      "dns": {
        "servers": [
          {"tag": "google", "address": "8.8.8.8"},
          {"tag": "local", "address": "local", "detour": "direct"}
        ],
        "rules": [
          {"outbound": "any", "server": "local"}
        ]
      },
      "inbounds": [
        {
          "type": "tun",
          "tag": "tun-in",
          "address": ["172.19.0.1/30", "fdfe:dcba:9876::1/126"],
          "mtu": 1500,
          "auto_route": true,
          "strict_route": true,
          "stack": "system",
          "sniff": true
        }
      ],
      "outbounds": [
        _buildOutbound(server),
        {"type": "direct", "tag": "direct"},
        {"type": "block", "tag": "block"},
        {"type": "dns", "tag": "dns-out"}
      ],
      "route": {
        "rules": [
          {"protocol": "dns", "outbound": "dns-out"},
          {"geoip": "private", "outbound": "direct"}
        ],
        "final": "proxy",
        "auto_detect_interface": true
      }
    };
  }

  static Map<String, dynamic> _buildOutbound(ServerConfig server) {
    switch (server.protocol) {
      case Protocol.vless:
        return {
          "type": "vless",
          "tag": "proxy",
          "server": server.address,
          "server_port": server.port,
          "uuid": server.extra['uuid'] ?? '',
          "flow": server.extra['flow'] ?? '',
          "tls": _buildTls(server),
          "transport": _buildTransport(server),
          "packet_encoding": "xudp"
        };
      case Protocol.vmess:
        return {
          "type": "vmess",
          "tag": "proxy",
          "server": server.address,
          "server_port": server.port,
          "uuid": server.extra['id'] ?? server.extra['uuid'] ?? '',
          "security": server.extra['scy'] ?? server.extra['security'] ?? 'auto',
          "alter_id": int.tryParse(server.extra['aid']?.toString() ?? '0') ?? 0,
          "tls": _buildTls(server),
          "transport": _buildTransport(server)
        };
      case Protocol.shadowsocks:
        return {
          "type": "shadowsocks",
          "tag": "proxy",
          "server": server.address,
          "server_port": server.port,
          "method": server.extra['method'] ?? 'aes-256-gcm',
          "password": server.extra['password'] ?? ''
        };
      case Protocol.trojan:
        return {
          "type": "trojan",
          "tag": "proxy",
          "server": server.address,
          "server_port": server.port,
          "password": server.extra['password'] ?? '',
          "tls": _buildTls(server),
          "transport": _buildTransport(server)
        };
      case Protocol.hysteria2:
        return {
          "type": "hysteria2",
          "tag": "proxy",
          "server": server.address,
          "server_port": server.port,
          "password": server.extra['auth'] ?? server.extra['password'] ?? '',
          "tls": {
            "enabled": true,
            "insecure": server.extra['allowInsecure'] == '1',
            "server_name": server.extra['sni'] ?? server.address
          }
        };
      default:
        return {"type": "direct", "tag": "proxy"};
    }
  }

  static Map<String, dynamic> _buildTls(ServerConfig server) {
    final security = server.extra['security'] ?? server.extra['tls'] ?? '';
    final enabled = security == 'tls' || security == 'reality';
    return {
      "enabled": enabled,
      "insecure": server.extra['allowInsecure'] == '1',
      "server_name": server.extra['sni'] ?? server.address,
      if (security == 'reality') "reality": {
        "enabled": true,
        "public_key": server.extra['pbk'] ?? '',
        "short_id": server.extra['sid'] ?? ''
      }
    };
  }

  static Map<String, dynamic>? _buildTransport(ServerConfig server) {
    final type = server.extra['type'] ?? server.extra['net'] ?? '';
    if (type.isEmpty || type == 'tcp') return null;
    switch (type) {
      case 'ws':
        return {
          "type": "ws",
          "path": server.extra['path'] ?? '/',
          "headers": {
            if ((server.extra['host'] ?? '').isNotEmpty)
              "Host": server.extra['host']
          }
        };
      case 'grpc':
        return {
          "type": "grpc",
          "service_name": server.extra['serviceName'] ?? server.extra['path'] ?? ''
        };
      case 'h2':
        return {
          "type": "http",
          "path": server.extra['path'] ?? '/',
          "host": [server.extra['host'] ?? server.address]
        };
      default:
        return null;
    }
  }

  static String toJson(ServerConfig server) =>
      jsonEncode(generate(server));
}
