import 'package:flutter/material.dart';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';

class EmojiPickerOverlay extends StatelessWidget {
  final TextEditingController controller;
  final double keyboardHeight;

  const EmojiPickerOverlay({super.key, required this.controller, required this.keyboardHeight});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: EmojiPicker(
        onEmojiSelected: (category, emoji) {
          controller
            ..text += emoji.emoji
            ..selection = TextSelection.fromPosition(
              TextPosition(offset: controller.text.length),
            );
        },
        onBackspacePressed: () {
          final text = controller.text;
          final selection = controller.selection;

          if (text.isNotEmpty) {
            final newText = text.characters.skipLast(1).toString(); // Handles emojis safely
            controller.text = newText;
            controller.selection = TextSelection.fromPosition(
              TextPosition(offset: newText.length),
            );
          }
        },
        config: Config(
            height: keyboardHeight,
            emojiTextStyle: const TextStyle(fontSize: 24),
            emojiViewConfig: EmojiViewConfig(emojiSizeMax: 28, columns: 8),
            categoryViewConfig: CategoryViewConfig(iconColorSelected: Colors.green),
            bottomActionBarConfig: BottomActionBarConfig(showBackspaceButton: true),
            checkPlatformCompatibility: true,
            searchViewConfig: SearchViewConfig(backgroundColor: Colors.white)),
      ),
    );
  }
}
