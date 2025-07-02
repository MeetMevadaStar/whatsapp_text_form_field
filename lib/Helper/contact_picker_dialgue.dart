import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:collection/collection.dart';
import 'package:contacts_service/contacts_service.dart'; // Make sure this package is imported

class ContactPickerDialog extends StatefulWidget {
  final Iterable<Contact> contacts;
  final void Function(Map<String, dynamic>)? onContactSelect;

  const ContactPickerDialog({
    Key? key,
    required this.contacts,
    this.onContactSelect,
  }) : super(key: key);

  @override
  State<ContactPickerDialog> createState() => _ContactPickerDialogState();
}

class _ContactPickerDialogState extends State<ContactPickerDialog> {
  late TextEditingController _searchController;
  late List<Contact> _filteredContacts;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _filteredContacts = List.from(widget.contacts);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  LinearGradient _getRandomGradient() {
    final List<Color> colors = [
      Colors.blue.shade300,
      Colors.purple.shade300,
      Colors.green.shade300,
      Colors.orange.shade300,
      Colors.red.shade300,
      Colors.teal.shade300,
    ];
    colors.shuffle();
    return LinearGradient(
      colors: [colors[0], colors[1]],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      elevation: 16,
      backgroundColor: Colors.white,
      titlePadding: const EdgeInsets.fromLTRB(10, 20, 10, 10),
      contentPadding: const EdgeInsets.fromLTRB(15, 0, 15, 20),
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Select a Contact',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black87),
          ),
          const SizedBox(height: 15),
          TextField(
            controller: _searchController,
            onChanged: (query) {
              setState(() {
                _filteredContacts = widget.contacts.where((contact) {
                  final name = contact.displayName?.toLowerCase() ?? '';
                  final number = contact.phones?.firstOrNull?.value?.toLowerCase() ?? '';
                  return name.contains(query.toLowerCase()) || number.contains(query.toLowerCase());
                }).toList();
              });
            },
            decoration: InputDecoration(
              hintText: 'Search contacts...',
              hintStyle: TextStyle(color: Colors.grey[500]),
              prefixIcon: const Icon(Icons.search, color: Colors.blueGrey),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey[300]!, width: 1),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Colors.blueAccent, width: 2),
              ),
              fillColor: Colors.grey[100],
              filled: true,
              contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
            ),
          ),
        ],
      ),
      content: SizedBox(
        width: double.maxFinite,
        height: 400,
        child: _filteredContacts.isEmpty
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.person_off_rounded, size: 60, color: Colors.grey[400]),
                    const SizedBox(height: 10),
                    Text('No contacts found', style: TextStyle(fontSize: 16, color: Colors.grey[600])),
                    Text('Try a different search query.', style: TextStyle(fontSize: 14, color: Colors.grey[500])),
                  ],
                ),
              )
            : ListView.separated(
                itemCount: _filteredContacts.length,
                separatorBuilder: (_, __) => Divider(height: 1, color: Colors.grey[200]),
                itemBuilder: (context, index) {
                  final contact = _filteredContacts[index];
                  final displayName = contact.displayName ?? 'Unnamed Contact';
                  final phone = contact.phones?.firstOrNull?.value ?? 'No number';

                  return ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 0),
                    leading: CircleAvatar(
                      radius: 24,
                      backgroundColor: Colors.transparent,
                      child: Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: _getRandomGradient(),
                        ),
                        child: Center(
                          child: Text(
                            displayName.isNotEmpty ? displayName[0].toUpperCase() : '?',
                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20),
                          ),
                        ),
                      ),
                    ),
                    title: Text(displayName, style: const TextStyle(fontWeight: FontWeight.w600, color: Colors.black87)),
                    subtitle: Text(phone, style: TextStyle(color: Colors.grey[600], fontSize: 13)),
                    trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 16, color: Colors.grey),
                    onTap: () {
                      Navigator.pop(context);
                      if (widget.onContactSelect != null) {
                        var contactJson = {
                          'displayName': contact.displayName,
                          'givenName': contact.givenName,
                          'middleName': contact.middleName,
                          'familyName': contact.familyName,
                          'prefix': contact.prefix,
                          'suffix': contact.suffix,
                          'company': contact.company,
                          'jobTitle': contact.jobTitle,
                          'phones': contact.phones
                              ?.map((p) => {
                                    'label': p.label,
                                    'value': p.value,
                                  })
                              .toList(),
                          'emails': contact.emails
                              ?.map((e) => {
                                    'label': e.label,
                                    'value': e.value,
                                  })
                              .toList(),
                          'postalAddresses': contact.postalAddresses
                              ?.map((a) => {
                                    'label': a.label,
                                    'street': a.street,
                                    'city': a.city,
                                    'postcode': a.postcode,
                                    'region': a.region,
                                    'country': a.country,
                                  })
                              .toList(),
                          'avatar': contact.avatar != null ? base64Encode(contact.avatar!) : null,
                        };

                        widget.onContactSelect!(contactJson);
                      }
                    },
                  );
                },
              ),
      ),
    );
  }
}
