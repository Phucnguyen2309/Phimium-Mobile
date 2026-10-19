import 'package:flutter_test/flutter_test.dart';

import 'package:app_short_drama/app.dart';

void main() {
  testWidgets('App renders smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const AppShortDrama());
    // Basic smoke test - app should render without errors
    expect(find.text('Short Drama'), findsAny);
  });
}
