import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:provider/provider.dart';
import '../providers/vpn_provider.dart';
import '../services/link_parser.dart';
class AddServerScreen extends StatefulWidget {
  const AddServerScreen({super.key});

  @override
  State<AddServerScreen> createState() => _AddServerScreenState();
}

class _AddServerScreenState extends State<AddServerScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabs;
  final _linkController = TextEditingController();
  bool _scanned = false;

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabs.dispose();
    _linkController.dispose();
    super.dispose();
  }

  void _addLink(String link) {
    final config = LinkParser.parse(link);
    if (config == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Неверный формат ссылки'),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }
    context.read<VpnProvider>().addServer(config);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Добавлен: ${config.name}'),
        backgroundColor: const Color(0xFF00C853),
      ),
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D0D1A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0D0D1A),
        foregroundColor: Colors.white,
        title: const Text('Добавить сервер'),
        bottom: TabBar(
          controller: _tabs,
          indicatorColor: const Color(0xFF7C4DFF),
          labelColor: const Color(0xFF7C4DFF),
          unselectedLabelColor: Colors.white38,
          tabs: const [
            Tab(text: 'Ссылка'),
            Tab(text: 'QR-код'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabs,
        children: [
          _buildLinkTab(),
          _buildQrTab(),
        ],
      ),
    );
  }

  Widget _buildLinkTab() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Вставьте ссылку конфигурации',
            style: TextStyle(color: Colors.white70, fontSize: 14),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _linkController,
            style: const TextStyle(color: Colors.white, fontSize: 13),
            maxLines: 4,
            decoration: InputDecoration(
              hintText: 'vless://... или vmess://... или ss://...',
              hintStyle: const TextStyle(color: Colors.white24, fontSize: 12),
              filled: true,
              fillColor: const Color(0xFF1A1A2E),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Colors.white12),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Colors.white12),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0xFF7C4DFF)),
              ),
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Поддерживается: vless://, vmess://, ss://, trojan://, hysteria2://',
            style: TextStyle(color: Colors.white24, fontSize: 11),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF7C4DFF),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: () {
                final text = _linkController.text.trim();
                if (text.isNotEmpty) _addLink(text);
              },
              child: const Text('Добавить', style: TextStyle(fontSize: 16)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQrTab() {
    return Column(
      children: [
        Expanded(
          child: _scanned
              ? const Center(
                  child: Icon(Icons.check_circle, color: Color(0xFF00E676), size: 80),
                )
              : MobileScanner(
                  onDetect: (capture) {
                    if (_scanned) return;
                    final barcode = capture.barcodes.firstOrNull;
                    if (barcode?.rawValue != null) {
                      setState(() => _scanned = true);
                      _addLink(barcode!.rawValue!);
                    }
                  },
                ),
        ),
        const Padding(
          padding: EdgeInsets.all(16),
          child: Text(
            'Наведите камеру на QR-код конфигурации',
            style: TextStyle(color: Colors.white54, fontSize: 14),
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }
}
