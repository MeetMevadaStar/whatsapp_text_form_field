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
  final bool showEmogyIcon;
  final bool showAttachmentIcon;
  final VoidCallback? onSendTap;
  final ValueChanged<String>? onChanged;
  final TextInputAction textInputAction;
  final TextInputType keyboardType;
  final bool autoFocus;
  final int maxLines;
  final AttachmentConfig? attachmentConfig;
  final bool readOnly;
  final bool enabled;
  final bool enableSuggestions;
  final bool autocorrect;
  final TextCapitalization textCapitalization;
  final Widget? customEmojiIcon;
  final VoidCallback? onCustomEmojiTap;

  WhatsAppTextField({
    Key? key,
    required this.controller,
    this.hintText = "Type a message",
    this.sendIcon = Icons.send,
    this.sendButtonColor = Colors.green,
    this.textFieldRadius = 25.0,
    this.sendButtonRadius = 25.0,
    this.emojiIcon = Icons.emoji_emotions_outlined,
    this.attachmentIcon = Icons.attach_file,
    this.showEmogyIcon = true,
    this.showAttachmentIcon = true,
    this.onSendTap,
    this.onChanged,
    this.textInputAction = TextInputAction.send,
    this.keyboardType = TextInputType.multiline,
    this.autoFocus = false,
    this.maxLines = 1,
    this.attachmentConfig,
    this.readOnly = false,
    this.enabled = true,
    this.enableSuggestions = false,
    this.autocorrect = false,
    this.textCapitalization = TextCapitalization.sentences,
    this.customEmojiIcon,
    this.onCustomEmojiTap,
  }) : super(key: key);

  @override
  State<WhatsAppTextField> createState() => _WhatsAppTextFieldState();
}

class _WhatsAppTextFieldState extends State<WhatsAppTextField> with WidgetsBindingObserver {
  bool _showAboveSheet = false;
  bool _showEmojiPicker = false;
  bool isFocused = false;
  final FocusNode _focusNode = FocusNode();
  double? _keyboardHeight = 259.0;

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
    final bottomInset = WidgetsBinding.instance.window.viewInsets.bottom / WidgetsBinding.instance.window.devicePixelRatio;

    if (bottomInset > 0 && bottomInset > (_keyboardHeight ?? 0)) {
      setState(() {
        _keyboardHeight = bottomInset;
        if (_showEmojiPicker) _showEmojiPicker = false;
      });
    }

    if (isFocused && _showEmojiPicker == true) {
      setState(() {
        _showEmojiPicker = false;
      });
    }
    print('_keyboardHeight =>> $_keyboardHeight');
  }

  void _toggleEmojiKeyboard() async {
    if (_showEmojiPicker) {
      if (mounted) {
        FocusScope.of(context).requestFocus(_focusNode);
      }
      await Future.delayed(const Duration(milliseconds: 50));
      setState(() => _showEmojiPicker = false);
    } else {
      FocusScope.of(context).unfocus();
      await Future.delayed(const Duration(milliseconds: 50));
      if (mounted) {
        setState(() => _showEmojiPicker = true);
      }
    }

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
    return Container(
      child: Stack(
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
                      child: Focus(
                        onFocusChange: (value) {
                          setState(() {
                            isFocused = value;
                          });
                        },
                        child: TextFormField(
                          controller: widget.controller,
                          focusNode: _focusNode,
                          maxLines: widget.maxLines,
                          autofocus: widget.autoFocus,
                          keyboardType: widget.keyboardType,
                          textInputAction: widget.textInputAction,
                          onChanged: widget.onChanged,
                          readOnly: widget.readOnly,
                          enabled: widget.enabled,
                          enableSuggestions: widget.enableSuggestions,
                          autocorrect: widget.autocorrect,
                          textCapitalization: widget.textCapitalization,
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: Colors.grey[200],
                            hintText: widget.hintText,
                            contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(widget.textFieldRadius),
                              borderSide: BorderSide.none,
                            ),
                            prefixIcon: widget.showEmogyIcon
                                ? IconButton(
                                    icon: Icon(
                                      _showEmojiPicker ? Icons.keyboard_alt_outlined : widget.emojiIcon,
                                      color: Colors.grey,
                                    ),
                                    onPressed: _toggleEmojiKeyboard,
                                  )
                                : (widget.customEmojiIcon != null
                                    ? IconButton(
                                        icon: widget.customEmojiIcon!,
                                        onPressed: widget.onCustomEmojiTap,
                                      )
                                    : null),
                            suffixIcon: widget.showAttachmentIcon &&
                                    ((widget.attachmentConfig?.showCamera ?? true) ||
                                        (widget.attachmentConfig?.showGallery ?? true) ||
                                        (widget.attachmentConfig?.showAudio ?? true))
                                ? IconButton(
                                    icon: Icon(widget.attachmentIcon, color: Colors.grey),
                                    onPressed: _toggleAboveSheet,
                                  )
                                : null,
                          ),
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
              backgroundColor: widget.attachmentConfig?.backgroundColor ?? Colors.white,
              iconColor: widget.attachmentConfig?.iconColor ?? Colors.black,
              textColor: widget.attachmentConfig?.textColor ?? Colors.black,
              iconBackgroundColor: widget.attachmentConfig?.iconBackgroundColor ?? const Color(0xFFE0E0E0),
            ),
          if (_showEmojiPicker)
            EmojiPickerOverlay(
              controller: widget.controller,
              keyboardHeight: _keyboardHeight ?? 0,
            ),
        ],
      ),
    );
  }
}
