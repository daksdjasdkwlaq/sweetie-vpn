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
          border: Border.all(color: ringColor.withAlpha(76), width: 16),
          boxShadow: [
            BoxShadow(
              color: ringColor.withAlpha(102),
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
              : const Icon(
                  Icons.power_settings_new,
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

  Widget _buildServerCard(BuildContext context, VpnProvider vpn) {
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
                color: const Color(0xFF7C4DFF).withAlpha(51),
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
