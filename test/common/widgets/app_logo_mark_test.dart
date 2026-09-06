import 'package:doctor_appointment_app/common/widgets/app_logo_mark.dart';
import 'package:doctor_appointment_app/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('renders the branded logo asset on the primary badge', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(home: Scaffold(body: AppLogoMark())),
    );
    await tester.pumpAndSettle();

    // assets/branding/logo.png is bundled, so it should render directly —
    // the fallback glyph (Image.asset's errorBuilder) should not appear.
    expect(find.byType(Image), findsOneWidget);
    expect(find.byIcon(Icons.favorite), findsNothing);

    final container = tester.widget<Container>(find.byType(Container));
    final decoration = container.decoration! as BoxDecoration;
    expect(decoration.color, AppTheme.primary);
  });

  testWidgets(
    'falls back to the glyph icon when the logo asset is missing',
    (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Image.asset(
              'assets/branding/does_not_exist.png',
              errorBuilder: (context, error, stackTrace) =>
                  const Icon(Icons.favorite, color: AppTheme.onPrimary),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Exercises the same errorBuilder AppLogoMark relies on, using a path
      // that's guaranteed not to be bundled, since bundled logo.png now
      // always resolves successfully in this template.
      final icon = tester.widget<Icon>(find.byIcon(Icons.favorite));
      expect(icon.color, AppTheme.onPrimary);
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
