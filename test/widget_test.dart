import 'package:flutter_test/flutter_test.dart';
import 'package:aqua_node/app.dart';

void main() {
  testWidgets('shows sign in first', (tester) async {
    await tester.pumpWidget(const AquaApp());
    expect(find.text('Sign in'), findsWidgets);
  });
}
