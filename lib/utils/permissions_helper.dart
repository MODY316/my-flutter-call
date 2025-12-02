import 'package:permission_handler/permission_handler.dart';

class PermissionsHelper {
  static Future<void> requestPermissions() async {
    Map<Permission, PermissionStatus> statuses = await [
      Permission.phone,
      Permission.contacts,
      // Permission.microphone, // Might be needed for in-app calls, but native dialer handles the actual call
    ].request();

    // You can handle denied permissions here if needed
    if (statuses[Permission.phone]!.isDenied) {
      // Show explanation?
    }
  }

  static Future<bool> hasPermissions() async {
    return await Permission.phone.isGranted &&
           await Permission.contacts.isGranted;
  }
}
