import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/vpn_provider.dart';
import '../models/server_config.dart';
import 'servers_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D0D1A),
      body: SafeArea(
        child: Consumer<VpnProvider>(
          builder: (context, vpn, _) {
            return Column(
              children: [
                _buildHeader(context),
                const Spacer(),
                _buildConnectButton(context, vpn),
                const SizedBox(height: 24),
                _buildStatusText(vpn),
                const SizedBox(height: 16),
                _buildPingWidget(vpn),
                const Spacer(),
                _buildServerCard(context, vpn),
                const SizedBox(height: 32),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'Sweetie VPN',
            style: TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          IconButton(
            icon: const Icon(Icons.dns_rounded, color: Colors.white70),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const ServersScreen()),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConnectButton(BuildContext context, VpnProvider vpn) {
    final isConnected = vpn.status == VpnStatus.connected;
    final isConnecting = vpn.status == VpnStatus.connecting;

    Color ringColor;
    Color coreColor;
    if (isConnected) {
      ringColor = const Color(0xFF00E676);
      coreColor = const Color(0xFF00C853);
    } else if (isConnecting) {
      ringColor = const Color(0xFFFFB300);
      coreColor = const Color(0xFFFF8F00);
    } else {
      ringColor = const Color(0xFF7C4DFF);
      coreColor = const Color(0xFF651FFF);
    }

    return GestureDetector(
      onTap: vpn.selected == null ? null : () => vpn.toggleConnection(),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 400),
        width: 180,
        height: 180,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: ringColor.withOpacity(0.3), width: 16),
          boxShadow: [
            BoxShadow(
              color: ringColor.withOpacity(0.4),
              blurRadius: 40,
              spreadRadius: 8,
            ),
          ],
        ),
        child: Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: coreColor,
          ),
          child: isConnecting
              ? const Center(
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 3,
                  ),
                )
              : Icon(
                  isConnected ? Icons.power_settings_new : Icons.power_settings_new,
                  color: Colors.white,
                  size: 64,
                ),
        ),
      ),
    );
  }

  Widget _buildStatusText(VpnProvider vpn) {
    String text;
    Color color;
    switch (vpn.status) {
      case VpnStatus.connected:
        text = 'Подключено';
        color = const Color(0xFF00E676);
        break;
      case VpnStatus.connecting:
        text = 'Подключение...';
        color = const Color(0xFFFFB300);
        break;
      default:
        text = 'Отключено';
        color = Colors.white54;
    }
    return Text(
      text,
      style: TextStyle(color: color, fontSize: 18, fontWeight: FontWeight.w500),
    );
  }

  Widget _buildPingWidget(VpnProvider vpn) {
    if (vpn.status != VpnStatus.connected) return const SizedBox.shrink();

    return GestureDetector(
      onTap: () => vpn.checkPing(),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: const Color(0xFF1A1A2E),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white12),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.network_ping, color: Colors.white38, size: 16),
            const SizedBox(width: 8),
            vpn.pinging
                ? const SizedBox(
                    width: 14,
                    height: 14,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white38,
                    ),
                  )
                : Text(
                    vpn.ping == null ? 'Нет ответа' : '${vpn.ping} мс',
                    style: TextStyle(
                      color: _pingColor(vpn.ping),
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
            const SizedBox(width: 6),
            const Icon(Icons.refresh, color: Colors.white24, size: 14),
          ],
        ),
      ),
    );
  }

  Color _pingColor(int? ping) {
    if (ping == null) return Colors.redAccent;
    if (ping < 100) return const Color(0xFF00E676);
    if (ping < 300) return const Color(0xFFFFB300);
    return Colors.redAccent;
  }
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const ServersScreen()),
      ),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 24),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF1A1A2E),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white12),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: const Color(0xFF7C4DFF).withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.language, color: Color(0xFF7C4DFF)),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: vpn.selected == null
                  ? const Text(
                      'Выберите сервер',
                      style: TextStyle(color: Colors.white54, fontSize: 16),
                    )
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          vpn.selected!.name,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          '${vpn.selected!.protocolLabel} · ${vpn.selected!.address}:${vpn.selected!.port}',
                          style: const TextStyle(color: Colors.white38, fontSize: 12),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
            ),
            const Icon(Icons.chevron_right, color: Colors.white38),
          ],
        ),
      ),
    );
  }
}
