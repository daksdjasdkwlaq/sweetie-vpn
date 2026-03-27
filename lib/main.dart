import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/vpn_provider.dart';
import 'screens/home_screen.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => VpnProvider()..init(),
      child: const SweetieVpnApp(),
    ),
  );
}

class SweetieVpnApp extends StatelessWidget {
  const SweetieVpnApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Sweetie VPN',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.dark(
          primary: const Color(0xFF7C4DFF),
          surface: const Color(0xFF0D0D1A),
        ),
        useMaterial3: true,
      ),
      home: const HomeScreen(),
    );
  }
}
