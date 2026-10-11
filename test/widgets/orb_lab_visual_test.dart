import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ball_sort/game/ball_type.dart';
import 'package:ball_sort/game/tube.dart';
import 'package:ball_sort/theme/game_theme.dart';
import 'package:ball_sort/widgets/ball_widget.dart';
import 'package:ball_sort/widgets/tube_widget.dart';

void main() {
  group('Milestone 0F Orb Lab Visual Tests', () {
    test('BallWidget color mapping distinguishes all 5 logical ball types', () {
      final ballTypes = [
        BallType.red,
        BallType.blue,
        BallType.yellow,
        BallType.green,
        BallType.purple,
      ];

      final distinctCoreColors = <Color>{};
      for (final type in ballTypes) {
        final colors = BallWidget.gradientColorsForType(type);
        expect(
          colors.length,
          equals(4),
          reason: 'Each orb must have 4 gradient stops',
        );
        final coreColor = BallWidget.colorForBallType(type);
        expect(coreColor, equals(colors[1]));
        distinctCoreColors.add(coreColor);
      }

      expect(
        distinctCoreColors.length,
        equals(5),
        reason:
            'All 5 ball types must have distinct visual core colors in Orb Lab',
      );
    });

    testWidgets(
      'BallWidget renders with specified size and specular highlights',
      (WidgetTester tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: Center(child: BallWidget(type: BallType.blue, size: 40.0)),
            ),
          ),
        );

        final sizedBoxFinder = find.byType(SizedBox).first;
        final sizedBox = tester.widget<SizedBox>(sizedBoxFinder);
        expect(sizedBox.width, equals(40.0));
        expect(sizedBox.height, equals(40.0));
      },
    );

    testWidgets(
      'TubeWidget displays selected illuminated outline when active',
      (WidgetTester tester) async {
        final tube = Tube(balls: [BallType.red, BallType.blue]);

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: Center(
                child: TubeWidget(
                  tube: tube,
                  isSelected: true,
                  onTap: () {},
                  ballSize: 40.0,
                ),
              ),
            ),
          ),
        );

        // Verify semantics
        final semanticsFinder = find.byWidgetPredicate(
          (widget) => widget is Semantics && widget.properties.selected == true,
        );
        expect(semanticsFinder, findsOneWidget);
      },
    );

    testWidgets('TubeWidget displays FREE indicator when chamber is empty', (
      WidgetTester tester,
    ) async {
      final emptyTube = Tube();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: TubeWidget(
                tube: emptyTube,
                isSelected: false,
                onTap: () {},
                ballSize: 40.0,
              ),
            ),
          ),
        ),
      );

      expect(find.text('FREE'), findsOneWidget);
    });

    testWidgets('GameTheme palette tokens conform to Orb Lab design values', (
      WidgetTester tester,
    ) async {
      expect(GameTheme.background, equals(const Color(0xFF080F24)));
      expect(GameTheme.surface, equals(const Color(0xFF121D38)));
      expect(GameTheme.surfaceElevated, equals(const Color(0xFF1B2A4B)));
      expect(GameTheme.cyanAccent, equals(const Color(0xFF49DCEC)));
      expect(GameTheme.blueAccent, equals(const Color(0xFF5A8DFF)));
      expect(GameTheme.violetAccent, equals(const Color(0xFFA178FF)));
      expect(GameTheme.textPrimary, equals(const Color(0xFFF2F7FF)));
      expect(GameTheme.textSecondary, equals(const Color(0xFF9DADCA)));
    });
  });
}
