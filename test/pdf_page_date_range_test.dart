import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:apk_ieee/screens/main_menu_screen.dart';

void main() {
  test('PDFPage max year is 20230', () {
    expect(PDFPage.maxYear, 20230);
    expect(PDFPage.maxDate.year, 20230);
    expect(PDFPage.maxDate.month, 12);
    expect(PDFPage.maxDate.day, 31);
  });

  test('formatDateStatic full and year', () {
    final d = DateTime(2023, 1, 15);
    expect(PDFPage.formatDateStatic(d), 'Enero 15 2023');
    expect(PDFPage.formatDateStatic(d, onlyYear: true), '2023');
  });

  testWidgets('Descargar Reporte habilitado con fechas futuras válidas', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(body: PDFPage(apiBaseUrl: 'https://example.com/exec')),
      ),
    );
    await tester.pumpAndSettle();

    final state = tester.state(find.byType(PDFPage)) as dynamic;
    state.setState(() {
      state.fechaInicio = DateTime(20230, 11, 14);
      state.fechaFin = DateTime(20230, 11, 20);
    });

    await tester.pump();
    final downloadButton = find.widgetWithText(ElevatedButton, '📄 Descargar Reporte');
    expect(downloadButton, findsOneWidget);
    final btnWidget = tester.widget<ElevatedButton>(downloadButton);
    expect(btnWidget.onPressed != null, isTrue);
  });
}