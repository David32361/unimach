import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:unimatch_user/presentation/widgets/avatar_sprite.dart';

void main() {
  testWidgets('renders every bundled avatar without layout errors', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Wrap(
            children: [
              for (var index = 0; index < avatarCount; index++)
                AvatarSprite(avatarId: index, size: 72),
            ],
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.byType(AvatarSprite), findsNWidgets(avatarCount));
    expect(tester.takeException(), isNull);
  });
}
