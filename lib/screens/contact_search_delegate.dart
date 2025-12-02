import 'package:flutter/material.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:url_launcher/url_launcher.dart';

class ContactSearchDelegate extends SearchDelegate {
  final List<Contact> contacts;

  ContactSearchDelegate(this.contacts);

  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      if (query.isNotEmpty)
        IconButton(
          icon: const Icon(Icons.clear),
          onPressed: () {
            query = '';
          },
        ),
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () {
        close(context, null);
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return _buildList(context);
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return _buildList(context);
  }

  Widget _buildList(BuildContext context) {
    final cleanQuery = query.toLowerCase();
    final filteredContacts = contacts.where((contact) {
      final name = contact.displayName.toLowerCase();
      final phone = contact.phones.isNotEmpty ? contact.phones.first.number : '';
      return name.contains(cleanQuery) || phone.contains(cleanQuery);
    }).toList();

    if (filteredContacts.isEmpty) {
      return Center(
        child: Text(
          query.isEmpty ? 'Search contacts' : 'No contacts found',
          style: TextStyle(color: Colors.grey[600]),
        ),
      );
    }

    return ListView.builder(
      itemCount: filteredContacts.length,
      itemBuilder: (context, index) {
        final contact = filteredContacts[index];
        final hasPhone = contact.phones.isNotEmpty;

        return ListTile(
          leading: contact.thumbnail != null
              ? CircleAvatar(
                  backgroundImage: MemoryImage(contact.thumbnail!),
                )
              : CircleAvatar(
                  backgroundColor: Theme.of(context).primaryColor,
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
              close(context, null);
            }
          },
        );
      },
    );
  }

  Future<void> _makeCall(String? number) async {
    if (number == null) return;
    final Uri launchUri = Uri(scheme: 'tel', path: number);
    if (await canLaunchUrl(launchUri)) {
      await launchUrl(launchUri);
    }
  }
}
