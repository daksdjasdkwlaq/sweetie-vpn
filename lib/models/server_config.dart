enum Protocol { vless, vmess, shadowsocks, trojan, hysteria2, unknown }

class ServerConfig {
  final String id;
  final String name;
  final String address;
  final int port;
  final Protocol protocol;
  final Map<String, dynamic> extra;
  final String rawLink;

  const ServerConfig({
    required this.id,
    required this.name,
    required this.address,
    required this.port,
    required this.protocol,
    required this.extra,
    required this.rawLink,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'address': address,
        'port': port,
        'protocol': protocol.name,
        'extra': extra,
        'rawLink': rawLink,
      };

  factory ServerConfig.fromJson(Map<String, dynamic> json) => ServerConfig(
        id: json['id'],
        name: json['name'],
        address: json['address'],
        port: json['port'],
        protocol: Protocol.values.firstWhere(
          (p) => p.name == json['protocol'],
          orElse: () => Protocol.unknown,
        ),
        extra: Map<String, dynamic>.from(json['extra'] ?? {}),
        rawLink: json['rawLink'] ?? '',
      );

  String get protocolLabel {
    switch (protocol) {
      case Protocol.vless:
        return 'VLESS';
      case Protocol.vmess:
        return 'VMess';
      case Protocol.shadowsocks:
        return 'SS';
      case Protocol.trojan:
        return 'Trojan';
      case Protocol.hysteria2:
        return 'Hysteria2';
      default:
        return 'Unknown';
    }
  }
}
