import 'package:flutter/material.dart';

const avatarCount = 12;
const _avatarColumns = 4;
const _avatarRows = 3;
const _avatarAsset = 'assets/avatars/unimatch_animals.png';

class AvatarSprite extends StatelessWidget {
  const AvatarSprite({
    required this.avatarId,
    required this.size,
    this.selected = false,
    super.key,
  });

  final int avatarId;
  final double size;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    final normalizedId = avatarId.clamp(0, avatarCount - 1);
    final column = normalizedId % _avatarColumns;
    final row = normalizedId ~/ _avatarColumns;
    final borderWidth = selected ? 3.0 : 1.0;

    return Container(
      width: size,
      height: size,
      padding: EdgeInsets.all(borderWidth),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: selected
              ? Theme.of(context).colorScheme.primary
              : Theme.of(context).colorScheme.outlineVariant,
          width: borderWidth,
        ),
      ),
      child: ClipOval(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final cellSize = constraints.maxWidth;
            return ClipRect(
              child: Stack(
                children: [
                  Positioned(
                    left: -column * cellSize,
                    top: -row * cellSize,
                    width: cellSize * _avatarColumns,
                    height: cellSize * _avatarRows,
                    child: Image.asset(
                      _avatarAsset,
                      fit: BoxFit.fill,
                      filterQuality: FilterQuality.high,
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
