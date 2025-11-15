import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:apk_ieee/screens/sensor_dashboard_screen.dart';
import 'package:apk_ieee/screens/sensor_detail_page.dart';

void main() {
  Future<void> _pumpDashboard(WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: SensorDashboardScreen(ip: ''),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('Temperatura navega al detalle correcto', (tester) async {
    await _pumpDashboard(tester);
    final btn = find.byKey(const ValueKey('sensor-action-temperatura'));
    expect(btn, findsOneWidget);
    await tester.tap(btn);
    await tester.pumpAndSettle(const Duration(milliseconds: 300));
    expect(find.byType(SensorDetailPage), findsOneWidget);
    expect(find.text('Temperatura'), findsOneWidget);
  });

  testWidgets('UV navega al detalle correcto', (tester) async {
    await _pumpDashboard(tester);
    final btn = find.byKey(const ValueKey('sensor-action-uv'));
    expect(btn, findsOneWidget);
    await tester.tap(btn);
    await tester.pumpAndSettle(const Duration(milliseconds: 300));
    expect(find.byType(SensorDetailPage), findsOneWidget);
    expect(find.text('UV'), findsOneWidget);
  });
}