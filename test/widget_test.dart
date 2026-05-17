import 'package:flutter_test/flutter_test.dart';
import 'package:imter/app/app.dart';

void main() {
  testWidgets('shows the converter shell', (tester) async {
    await tester.pumpWidget(const ImterApp());

    expect(find.text('Imter'), findsWidgets);
    expect(find.text('Convert'), findsOneWidget);
    expect(find.text('Learn'), findsOneWidget);
    expect(find.text('About'), findsOneWidget);
    expect(find.text('Drop an image here'), findsOneWidget);
    expect(find.text('Choose Image'), findsOneWidget);
  });
}
