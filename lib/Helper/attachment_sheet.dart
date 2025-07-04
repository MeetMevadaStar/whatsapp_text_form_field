import 'dart:io';
import 'package:contacts_service/contacts_service.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:whatsapp_camera/camera/camera_whatsapp.dart';

import 'contact_picker_dialgue.dart';

class AttachmentSheet extends StatelessWidget {
  final BuildContext context;
  final Function(List<File>)? onCameraTap;
  final Function(List<File>)? onGalleryTap;
  final Function(List<File>)? onAudioTap;
  final Function(List<File>)? onDocSelect;
  final void Function(Map<String, dynamic>)? onContactSelect;
  final bool showCamera;
  final bool showGallery;
  final bool showAudio;
  final bool showDoc;
  final bool showContact;
  final Color backgroundColor;
  final Color iconColor;
  final Color textColor;
  final Color iconBackgroundColor;

  const AttachmentSheet({
    required this.context,
    this.onCameraTap,
    this.onGalleryTap,
    this.onAudioTap,
    this.onDocSelect,
    this.onContactSelect,
    this.showCamera = true,
    this.showGallery = true,
    this.showAudio = true,
    this.showDoc = true,
    this.showContact = true,
    this.backgroundColor = Colors.white,
    this.iconColor = Colors.black,
    this.textColor = Colors.black,
    this.iconBackgroundColor = const Color(0xFFE0E0E0),
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final List<_AttachmentOption> options = [];

    if (showCamera) {
      options.add(_AttachmentOption(
        icon: Icons.camera_alt,
        label: 'Camera',
        onTap: onCameraTapEvent,
      ));
    }

    if (showGallery) {
      options.add(_AttachmentOption(
        icon: Icons.photo,
        label: 'Gallery',
        onTap: onGalleryTapEvent,
      ));
    }

    if (showAudio) {
      options.add(_AttachmentOption(
        icon: Icons.audiotrack,
        label: 'Audio',
        onTap: onAudioTapEvent,
      ));
    }

    if (showDoc) {
      options.add(_AttachmentOption(
        icon: Icons.description,
        label: 'Document',
        onTap: onDocSelectEvent,
      ));
    }

    if (showContact) {
      options.add(_AttachmentOption(
        icon: Icons.contacts,
        label: 'Contact',
        onTap: onContactSelectEvent,
      ));
    }

    return Positioned(
      bottom: 70,
      left: 8,
      right: 8,
      child: Material(
        color: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(0),
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: options.length,
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4,
              mainAxisSpacing: 6,
              crossAxisSpacing: 6,
              childAspectRatio: 1.1,
            ),
            itemBuilder: (context, index) {
              final option = options[index];
              return GestureDetector(
                onTap: option.onTap,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: iconBackgroundColor,
                      ),
                      padding: const EdgeInsets.all(10),
                      child: Icon(option.icon, size: 20, color: iconColor),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      option.label,
                      style: TextStyle(fontSize: 11, color: textColor),
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  void onCameraTapEvent() async {
    final res = await Navigator.push<List<File>>(
      context,
      MaterialPageRoute(
        builder: (context) => const WhatsappCamera(multiple: true),
      ),
    );
    if (res != null) {
      onCameraTap?.call(res);
    }
  }

  void onGalleryTapEvent() async {
    final result = await FilePicker.platform.pickFiles(
      allowMultiple: true,
      type: FileType.custom,
      allowedExtensions: ['jpg', 'jpeg', 'png', 'gif', 'bmp', 'mp4', 'mov', 'avi', 'mkv'],
    );
    if (result != null) {
      final files = result.paths.map((e) => File(e!)).toList();
      onGalleryTap?.call(files);
    }
  }

  void onAudioTapEvent() async {
    final result = await FilePicker.platform.pickFiles(
      allowMultiple: true,
      type: FileType.custom,
      allowedExtensions: ['mp3', 'wav', 'aac', 'm4a', 'flac'],
    );
    if (result != null) {
      final files = result.paths.map((e) => File(e!)).toList();
      onAudioTap?.call(files);
    }
  }

  void onDocSelectEvent() async {
    final result = await FilePicker.platform.pickFiles(
      allowMultiple: true,
      type: FileType.custom,
      allowedExtensions: ['pdf', 'doc', 'docx', 'xls', 'xlsx', 'ppt'],
    );
    if (result != null) {
      final files = result.paths.map((e) => File(e!)).toList();
      onDocSelect?.call(files);
    }
  }

  void onContactSelectEvent() async {
    final permissionStatus = await Permission.contacts.request();

    if (!permissionStatus.isGranted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Contacts permission denied')),
      );
      return;
    }

    final contacts = await ContactsService.getContacts(withThumbnails: false);
    showDialog(
      context: context,
      builder: (_) => ContactPickerDialog(
        contacts: contacts,
        onContactSelect: onContactSelect,
      ),
    );
  }
}

class _AttachmentOption {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  _AttachmentOption({
    required this.icon,
    required this.label,
    required this.onTap,
  });
}
