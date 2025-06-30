import 'package:flutter/material.dart';

import '../Helper/attachment_sheet.dart';
import '../Helper/emoji_picker_overlay.dart';
import '../model/attachment_model.dart';

class WhatsAppTextField extends StatefulWidget {
  final TextEditingController controller;
  final String hintText;
  final IconData sendIcon;
  final Color sendButtonColor;
  final double textFieldRadius;
  final double sendButtonRadius;
  final IconData emojiIcon;
  final IconData attachmentIcon;
  final bool showAttachmentIcon;
  final VoidCallback? onSendTap;
  final ValueChanged<String>? onChanged;
  final TextInputAction textInputAction;
  final TextInputType keyboardType;
  final bool autoFocus;
  final int maxLines;
  final AttachmentConfig? attachmentConfig;

  const WhatsAppTextField({
    Key? key,
    required this.controller,
    this.hintText = "Type a message",
    this.sendIcon = Icons.send,
    this.sendButtonColor = Colors.green,
    this.textFieldRadius = 25.0,
    this.sendButtonRadius = 25.0,
    this.emojiIcon = Icons.emoji_emotions_outlined,
    this.attachmentIcon = Icons.attach_file,
    this.showAttachmentIcon = true,
    this.onSendTap,
    this.onChanged,
    this.textInputAction = TextInputAction.send,
    this.keyboardType = TextInputType.multiline,
    this.autoFocus = false,
    this.maxLines = 1,
    this.attachmentConfig,
  }) : super(key: key);

  @override
  State<WhatsAppTextField> createState() => _WhatsAppTextFieldState();
}

class _WhatsAppTextFieldState extends State<WhatsAppTextField>
    with WidgetsBindingObserver {
  bool _showAboveSheet = false;
  bool _showEmojiPicker = false;
  final FocusNode _focusNode = FocusNode();
  // double? _keyboardHeight = 259.0;
  double? _keyboardHeight = 399.21569373964223;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) => didChangeMetrics());
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _focusNode.dispose();
    super.dispose();
  }

  @override
  void didChangeMetrics() {
    final bottomInset =
        WidgetsBinding.instance.window.viewInsets.bottom /
        WidgetsBinding.instance.window.devicePixelRatio;
    print('_keyboardHeight=>>${_keyboardHeight}');
    // if (bottomInset > 0) {
    // _keyboardHeight = bottomInset;
    // setState(() {
    //   if (_showEmojiPicker) _showEmojiPicker = false;
    // });
    // }
  }

  void _toggleEmojiKeyboard() async {
    if (_showEmojiPicker) {
      // Hide emoji picker first
      if (mounted) {
        FocusScope.of(context).requestFocus(_focusNode);
      }
      await Future.delayed(const Duration(milliseconds: 300));
      setState(() => _showEmojiPicker = false);

      // Delay slightly before opening the keyboard
    } else {
      // Hide keyboard first
      FocusScope.of(context).unfocus();

      // Wait until keyboard is fully hidden
      await Future.delayed(const Duration(milliseconds: 300));

      // Then show emoji picker
      if (mounted) {
        setState(() => _showEmojiPicker = true);
      }
    }

    // Always hide the attachment sheet
    setState(() => _showAboveSheet = false);
  }

  void _toggleAboveSheet() {
    setState(() {
      _showAboveSheet = !_showAboveSheet;
      _showEmojiPicker = false;
      _focusNode.unfocus();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (_showAboveSheet) const SizedBox(height: 260),
            Padding(
              padding: const EdgeInsets.all(8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: widget.controller,
                      focusNode: _focusNode,
                      maxLines: widget.maxLines,
                      autofocus: widget.autoFocus,
                      keyboardType:
                          widget.keyboardType ?? TextInputType.multiline,
                      textInputAction: widget.textInputAction,
                      onChanged: widget.onChanged,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.grey[200],
                        hintText: widget.hintText,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 10,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(
                            widget.textFieldRadius,
                          ),
                          borderSide: BorderSide.none,
                        ),
                        prefixIcon: IconButton(
                          icon: Icon(
                            _showEmojiPicker
                                ? Icons.keyboard_alt_outlined
                                : widget.emojiIcon,
                            color: Colors.grey,
                          ),
                          onPressed: _toggleEmojiKeyboard,
                        ),
                        suffixIcon:
                            widget.showAttachmentIcon &&
                                ((widget.attachmentConfig?.showCamera ??
                                        true) ||
                                    (widget.attachmentConfig?.showGallery ??
                                        true) ||
                                    (widget.attachmentConfig?.showAudio ??
                                        true))
                            ? IconButton(
                                icon: Icon(
                                  widget.attachmentIcon,
                                  color: Colors.grey,
                                ),
                                onPressed: _toggleAboveSheet,
                              )
                            : null,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    width: widget.sendButtonRadius * 2,
                    height: widget.sendButtonRadius * 2,
                    decoration: BoxDecoration(
                      color: widget.sendButtonColor,
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      icon: Icon(widget.sendIcon, color: Colors.white),
                      onPressed: widget.onSendTap,
                    ),
                  ),
                ],
              ),
            ),
            if (_showEmojiPicker) SizedBox(height: _keyboardHeight ?? 0),
          ],
        ),
        if (_showAboveSheet)
          AttachmentSheet(
            context: context,
            onCameraTap: widget.attachmentConfig?.onCameraFilesPicked,
            onGalleryTap: widget.attachmentConfig?.onGalleryFilesPicked,
            onAudioTap: widget.attachmentConfig?.onAudioFilesPicked,
            onDocSelect: widget.attachmentConfig?.onDocFilerPicked,
            onContactSelect: widget.attachmentConfig?.onContactPicked,
            showCamera: widget.attachmentConfig?.showCamera ?? true,
            showGallery: widget.attachmentConfig?.showGallery ?? true,
            showAudio: widget.attachmentConfig?.showAudio ?? true,
            showDoc: widget.attachmentConfig?.showDoc ?? true,
            showContact: widget.attachmentConfig?.showContact ?? true,
            backgroundColor:
                widget.attachmentConfig?.backgroundColor ?? Colors.white,
            iconColor: widget.attachmentConfig?.iconColor ?? Colors.black,
            textColor: widget.attachmentConfig?.textColor ?? Colors.black,
            iconBackgroundColor:
                widget.attachmentConfig?.iconBackgroundColor ??
                Color(0xFFE0E0E0),
          ),
        if (_showEmojiPicker)
          EmojiPickerOverlay(
            controller: widget.controller,
            keyboardHeight: _keyboardHeight ?? 0,
          ),
      ],
    );
  }
}
