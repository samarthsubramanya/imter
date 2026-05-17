import 'package:flutter_test/flutter_test.dart';

import 'package:imter_site/main.dart';

void main() {
  testWidgets('renders the product site', (tester) async {
    await tester.pumpWidget(const ImterSite());

    expect(find.text('Imter'), findsWidgets);
    expect(
      find.textContaining('fully local desktop image converter'),
      findsOneWidget,
    );
    expect(find.text('WebP'), findsWidgets);
    expect(find.text('AVIF'), findsWidgets);
  });
}
