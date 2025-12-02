import 'package:flutter/material.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../providers/settings_provider.dart';

class FavoritesTab extends StatefulWidget {
  const FavoritesTab({super.key});

  @override
  State<FavoritesTab> createState() => _FavoritesTabState();
}

class _FavoritesTabState extends State<FavoritesTab> {
  List<Contact>? _favorites;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchFavorites();
  }

  Future<void> _fetchFavorites() async {
    if (await FlutterContacts.requestPermission()) {
      // Note: flutter_contacts might not support filtering by 'starred' directly in all versions efficiently,
      // but we can fetch all and filter or use getContacts(withProperties: true) and check isStarred.
      final contacts = await FlutterContacts.getContacts(
        withProperties: true,
        withPhoto: true,
        withThumbnail: true,
      );
      
      final favorites = contacts.where((c) => c.isStarred).toList();
      
      setState(() {
        _favorites = favorites;
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

    if (_favorites == null || _favorites!.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.star_border, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            const Text('No favorites yet'),
          ],
        ),
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 0.8,
      ),
      itemCount: _favorites!.length,
      itemBuilder: (context, index) {
        final contact = _favorites![index];
        final hasPhone = contact.phones.isNotEmpty;

        return InkWell(
          onTap: () {
            if (hasPhone) {
              _makeCall(contact.phones.first.number);
            }
          },
          child: Column(
            children: [
              Expanded(
                child: contact.thumbnail != null
                    ? CircleAvatar(
                        backgroundImage: MemoryImage(contact.thumbnail!),
                        radius: 40,
                      )
                    : CircleAvatar(
                        radius: 40,
                        backgroundColor: settings.primaryColor,
                        child: Text(
                          contact.displayName.isNotEmpty ? contact.displayName[0] : '?',
                          style: const TextStyle(color: Colors.white, fontSize: 24),
                        ),
                      ),
              ),
              const SizedBox(height: 8),
              Text(
                contact.displayName,
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontWeight: FontWeight.w500),
              ),
            ],
          ),
        );
      },
    );
  }
}
