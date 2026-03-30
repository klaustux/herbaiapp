import 'package:flutter_test/flutter_test.dart';
import 'package:herbai_app/main.dart';

void main() {
  testWidgets('App loads smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const HerbaiApp());
    expect(find.byType(HerbaiApp), findsOneWidget);
  });
}
