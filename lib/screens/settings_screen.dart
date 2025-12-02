import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/settings_provider.dart';
import '../utils/constants.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: Consumer<SettingsProvider>(
        builder: (context, settings, child) {
          return ListView(
            children: [
              _buildSectionHeader(context, 'Appearance'),
              _buildColorTile(
                context,
                'Primary Color',
                settings.primaryColor,
                (color) => settings.setPrimaryColor(color),
              ),
              _buildColorTile(
                context,
                'SIM Card Color',
                settings.simColor,
                (color) => settings.setSimColor(color),
              ),
              ListTile(
                title: const Text('Thumbnail Size'),
                subtitle: Slider(
                  value: settings.thumbnailSize,
                  min: 20,
                  max: 80,
                  divisions: 6,
                  label: settings.thumbnailSize.round().toString(),
                  onChanged: (value) => settings.setThumbnailSize(value),
                ),
              ),
              ListTile(
                title: const Text('Theme Mode'),
                trailing: DropdownButton<ThemeMode>(
                  value: settings.themeMode,
                  onChanged: (ThemeMode? newValue) {
                    if (newValue != null) {
                      settings.setThemeMode(newValue);
                    }
                  },
                  items: const [
                    DropdownMenuItem(value: ThemeMode.system, child: Text('System')),
                    DropdownMenuItem(value: ThemeMode.light, child: Text('Light')),
                    DropdownMenuItem(value: ThemeMode.dark, child: Text('Dark')),
                  ],
                ),
              ),

              _buildSectionHeader(context, 'List View'),
              SwitchListTile(
                title: const Text('Group Calls'),
                subtitle: const Text('Group consecutive calls from same number'),
                value: settings.groupCalls,
                onChanged: (value) => settings.setGroupCalls(value),
              ),
              SwitchListTile(
                title: const Text('Show Dividers'),
                value: settings.showDividers,
                onChanged: (value) => settings.setShowDividers(value),
              ),
              ListTile(
                title: const Text('History Limit'),
                subtitle: Text('${settings.historyLimit} entries'),
                onTap: () => _showHistoryLimitDialog(context, settings),
              ),

              _buildSectionHeader(context, 'Calls'),
              SwitchListTile(
                title: const Text('Vibrate on Answer'),
                value: settings.vibrateOnAnswer,
                onChanged: (value) => settings.setVibrateOnAnswer(value),
              ),
              SwitchListTile(
                title: const Text('Vibrate on End'),
                value: settings.vibrateOnEnd,
                onChanged: (value) => settings.setVibrateOnEnd(value),
              ),
              SwitchListTile(
                title: const Text('Disable Proximity Sensor'),
                subtitle: const Text('Keep screen on during calls'),
                value: settings.disableProximity,
                onChanged: (value) => settings.setDisableProximity(value),
              ),

              _buildSectionHeader(context, 'General'),
              SwitchListTile(
                title: const Text('Start with Keypad'),
                value: settings.startWithKeypad,
                onChanged: (value) => settings.setStartWithKeypad(value),
              ),
              ListTile(
                title: const Text('Language'),
                trailing: DropdownButton<String>(
                  value: settings.language,
                  onChanged: (String? newValue) {
                    if (newValue != null) {
                      settings.setLanguage(newValue);
                    }
                  },
                  items: const [
                    DropdownMenuItem(value: 'en', child: Text('English')),
                    DropdownMenuItem(value: 'ar', child: Text('العربية')),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
      child: Text(
        title,
        style: TextStyle(
          color: Theme.of(context).primaryColor,
          fontWeight: FontWeight.bold,
          fontSize: 14,
        ),
      ),
    );
  }

  Widget _buildColorTile(
    BuildContext context,
    String title,
    Color currentColor,
    Function(Color) onColorChanged,
  ) {
    return ListTile(
      title: Text(title),
      trailing: CircleAvatar(
        backgroundColor: currentColor,
        radius: 16,
      ),
      onTap: () => _showColorPickerDialog(context, currentColor, onColorChanged),
    );
  }

  void _showColorPickerDialog(
    BuildContext context,
    Color currentColor,
    Function(Color) onColorChanged,
  ) {
    final List<Color> colors = [
      Colors.blue,
      Colors.red,
      Colors.green,
      Colors.orange,
      Colors.purple,
      Colors.teal,
      Colors.pink,
      Colors.indigo,
      Colors.brown,
      Colors.blueGrey,
    ];

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Color'),
        content: Wrap(
          spacing: 8,
          runSpacing: 8,
          children: colors.map((color) {
            return InkWell(
              onTap: () {
                onColorChanged(color);
                Navigator.pop(context);
              },
              child: CircleAvatar(
                backgroundColor: color,
                radius: 24,
                child: currentColor.value == color.value
                    ? const Icon(Icons.check, color: Colors.white)
                    : null,
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  void _showHistoryLimitDialog(BuildContext context, SettingsProvider settings) {
    final controller = TextEditingController(text: settings.historyLimit.toString());
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('History Limit'),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(labelText: 'Number of entries'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              final val = int.tryParse(controller.text);
              if (val != null && val > 0) {
                settings.setHistoryLimit(val);
              }
              Navigator.pop(context);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
}
