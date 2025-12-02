import 'package:flutter/material.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../providers/settings_provider.dart';

class ContactsTab extends StatefulWidget {
  const ContactsTab({super.key});

  @override
  State<ContactsTab> createState() => _ContactsTabState();
}

class _ContactsTabState extends State<ContactsTab> {
  List<Contact>? _contacts;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchContacts();
  }

  Future<void> _fetchContacts() async {
    if (await FlutterContacts.requestPermission()) {
      final contacts = await FlutterContacts.getContacts(
        withProperties: true,
        withPhoto: true,
        withThumbnail: true,
      );
      setState(() {
        _contacts = contacts;
        _isLoading = false;
      });
    } else {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _makeCall(String? number) async {
    if (number == null) return;
    final Uri launchUri = Uri(scheme: 'tel', path: number);
    if (await canLaunchUrl(launchUri)) {
      await launchUrl(launchUri);
    }
  }

  @override
  Widget build(BuildContext context) {
    final settings = Provider.of<SettingsProvider>(context);

    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_contacts == null || _contacts!.isEmpty) {
      return const Center(child: Text('No contacts found'));
    }

    return ListView.builder(
      itemCount: _contacts!.length,
      itemBuilder: (context, index) {
        final contact = _contacts![index];
        final hasPhone = contact.phones.isNotEmpty;

        return ListTile(
          leading: contact.thumbnail != null
              ? CircleAvatar(
                  backgroundImage: MemoryImage(contact.thumbnail!),
                  radius: settings.thumbnailSize / 2,
                )
              : CircleAvatar(
                  radius: settings.thumbnailSize / 2,
                  backgroundColor: settings.primaryColor,
                  child: Text(
                    contact.displayName.isNotEmpty ? contact.displayName[0] : '?',
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
          title: Text(contact.displayName),
          subtitle: hasPhone ? Text(contact.phones.first.number) : null,
          onTap: () {
             if (hasPhone) {
               _makeCall(contact.phones.first.number);
             }
          },
        );
      },
    );
  }
}
