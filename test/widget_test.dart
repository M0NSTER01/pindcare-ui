import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pindcare/app.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(child: ArogyaLinkApp()),
    );
    await tester.pump();
    expect(find.byType(ArogyaLinkApp), findsOneWidget);
  });
}
