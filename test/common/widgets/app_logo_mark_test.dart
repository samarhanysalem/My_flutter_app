import 'package:doctor_appointment_app/common/widgets/app_logo_mark.dart';
import 'package:doctor_appointment_app/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets(
    'falls back to the glyph icon when the logo asset is missing',
    (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: AppLogoMark())),
      );
      await tester.pumpAndSettle();

      // assets/branding/logo.png isn't bundled in this template, so
      // Image.asset's errorBuilder should render the fallback glyph rather
      // than a broken-image error.
      final icon = tester.widget<Icon>(find.byIcon(Icons.favorite));
      expect(icon.color, AppTheme.onPrimary);

      final container = tester.widget<Container>(find.byType(Container));
      final decoration = container.decoration! as BoxDecoration;
      expect(decoration.color, AppTheme.primary);
    },
  );

  testWidgets('sizes the badge from the size parameter', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(home: Scaffold(body: AppLogoMark(size: 80))),
    );
    await tester.pumpAndSettle();

    final container = tester.widget<Container>(find.byType(Container));
    expect(container.constraints?.maxWidth, 80);
    expect(container.constraints?.maxHeight, 80);
  });
}
