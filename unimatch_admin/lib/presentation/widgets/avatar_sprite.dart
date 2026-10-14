import 'package:flutter/material.dart';

class AvatarSprite extends StatelessWidget {
  const AvatarSprite({required this.avatarId, this.size = 48, super.key});

  final int avatarId;
  final double size;

  @override
  Widget build(BuildContext context) {
    final id = avatarId.clamp(0, 11);
    final row = id ~/ 4;
    final column = id % 4;
    return ClipOval(
      child: SizedBox(
        width: size,
        height: size,
        child: FittedBox(
          fit: BoxFit.none,
          alignment: Alignment(-1 + (column * 2 / 3), -1 + row.toDouble()),
          child: Image.asset(
            'assets/avatars/unimatch_animals.png',
            width: size * 4,
            height: size * 3,
            fit: BoxFit.fill,
          ),
        ),
      ),
    );
  }
}
