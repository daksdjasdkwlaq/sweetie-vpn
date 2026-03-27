import 'package:flutter_test/flutter_test.dart';
import 'package:sweetie_vpn/main.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const SweetieVpnApp());
    expect(find.text('Sweetie VPN'), findsOneWidget);
  });
}
