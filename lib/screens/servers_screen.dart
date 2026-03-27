import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/vpn_provider.dart';
import '../models/server_config.dart';
import 'add_server_screen.dart';
// ignore_for_file: deprecated_member_use

class ServersScreen extends StatelessWidget {
  const ServersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D0D1A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0D0D1A),
        foregroundColor: Colors.white,
        title: const Text('Серверы'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const AddServerScreen()),
            ),
          ),
        ],
      ),
      body: Consumer<VpnProvider>(
        builder: (context, vpn, _) {
          if (vpn.servers.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.dns_outlined, color: Colors.white24, size: 64),
                  const SizedBox(height: 16),
                  const Text(
                    'Нет серверов',
                    style: TextStyle(color: Colors.white54, fontSize: 18),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Добавьте сервер по ссылке или QR-коду',
                    style: TextStyle(color: Colors.white38, fontSize: 14),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF7C4DFF),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    icon: const Icon(Icons.add),
                    label: const Text('Добавить сервер'),
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const AddServerScreen()),
                    ),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: vpn.servers.length,
            itemBuilder: (context, index) {
              final server = vpn.servers[index];
              final isSelected = vpn.selected?.id == server.id;
              return _ServerTile(
                server: server,
                isSelected: isSelected,
                onTap: () {
                  vpn.selectServer(server);
                  Navigator.pop(context);
                },
                onDelete: () => _confirmDelete(context, vpn, server),
              );
            },
          );
        },
      ),
    );
  }

  void _confirmDelete(BuildContext context, VpnProvider vpn, ServerConfig server) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A2E),
        title: const Text('Удалить сервер?', style: TextStyle(color: Colors.white)),
        content: Text(server.name, style: const TextStyle(color: Colors.white70)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Отмена', style: TextStyle(color: Colors.white54)),
          ),
          TextButton(
            onPressed: () {
              vpn.removeServer(server.id);
              Navigator.pop(context);
            },
            child: const Text('Удалить', style: TextStyle(color: Colors.redAccent)),
          ),
        ],
      ),
    );
  }
}

class _ServerTile extends StatelessWidget {
  final ServerConfig server;
  final bool isSelected;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const _ServerTile({
    required this.server,
    required this.isSelected,
    required this.onTap,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: isSelected
            ? const Color(0xFF7C4DFF).withOpacity(0.15)
            : const Color(0xFF1A1A2E),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isSelected ? const Color(0xFF7C4DFF) : Colors.white12,
        ),
      ),
      child: ListTile(
        onTap: onTap,
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: const Color(0xFF7C4DFF).withOpacity(0.2),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Center(
            child: Text(
              server.protocolLabel,
              style: const TextStyle(
                color: Color(0xFF7C4DFF),
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        title: Text(
          server.name,
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Text(
          '${server.address}:${server.port}',
          style: const TextStyle(color: Colors.white38, fontSize: 12),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isSelected)
              const Icon(Icons.check_circle, color: Color(0xFF7C4DFF), size: 20),
            IconButton(
              icon: const Icon(Icons.delete_outline, color: Colors.white38, size: 20),
              onPressed: onDelete,
            ),
          ],
        ),
      ),
    );
  }
}
