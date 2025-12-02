import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/settings_provider.dart';
import 'providers/theme_provider.dart';
import 'screens/main_screen.dart';
import 'utils/permissions_helper.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize settings (which loads SharedPreferences)
  final settingsProvider = SettingsProvider();
  // We can't await _loadSettings here easily without making main async and waiting, 
  // but the provider constructor calls it. Ideally we wait.
  // For simplicity, we'll let the provider load async and notify.
  
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: settingsProvider),
        ProxyProvider<SettingsProvider, ThemeProvider>(
          update: (_, settings, __) => ThemeProvider(settings),
        ),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    _checkPermissions();
  }

  Future<void> _checkPermissions() async {
    await PermissionsHelper.requestPermissions();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<SettingsProvider, ThemeProvider>(
      builder: (context, settings, themeProvider, child) {
        if (!settings.isInitialized) {
          return const MaterialApp(
            home: Scaffold(body: Center(child: CircularProgressIndicator())),
          );
        }

        return MaterialApp(
          title: 'Call Mody',
          debugShowCheckedModeBanner: false,
          theme: themeProvider.lightTheme,
          darkTheme: themeProvider.darkTheme,
          themeMode: settings.themeMode,
          home: const MainScreen(),
        );
      },
    );
  }
}
