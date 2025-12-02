import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../providers/settings_provider.dart';

class DialpadScreen extends StatefulWidget {
  const DialpadScreen({super.key});

  @override
  State<DialpadScreen> createState() => _DialpadScreenState();
}

class _DialpadScreenState extends State<DialpadScreen> {
  final TextEditingController _controller = TextEditingController();

  void _onKeyPress(String value) {
    setState(() {
      _controller.text += value;
    });
  }

  void _onBackspace() {
    if (_controller.text.isNotEmpty) {
      setState(() {
        _controller.text = _controller.text.substring(0, _controller.text.length - 1);
      });
    }
  }

  Future<void> _makeCall() async {
    if (_controller.text.isEmpty) return;
    final Uri launchUri = Uri(scheme: 'tel', path: _controller.text);
    if (await canLaunchUrl(launchUri)) {
      await launchUrl(launchUri);
    }
  }

  Widget _buildKey(String number, String letters) {
    final settings = Provider.of<SettingsProvider>(context, listen: false);
    return InkWell(
      onTap: () => _onKeyPress(number),
      borderRadius: BorderRadius.circular(50),
      child: Container(
        margin: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.grey.withOpacity(0.1),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              number,
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).textTheme.bodyLarge?.color,
              ),
            ),
            if (letters.isNotEmpty)
              Text(
                letters,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final settings = Provider.of<SettingsProvider>(context);
    
    return Container(
      height: MediaQuery.of(context).size.height * 0.75,
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          const SizedBox(height: 16),
          // Handle drag handle
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 24),
          // Display
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    _controller.text,
                    style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (_controller.text.isNotEmpty)
                  IconButton(
                    icon: const Icon(Icons.backspace),
                    onPressed: _onBackspace,
                  ),
              ],
            ),
          ),
          const Spacer(),
          // Keypad
          Expanded(
            flex: 4,
            child: GridView.count(
              crossAxisCount: 3,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 32),
              children: [
                _buildKey('1', ''),
                _buildKey('2', 'ABC'),
                _buildKey('3', 'DEF'),
                _buildKey('4', 'GHI'),
                _buildKey('5', 'JKL'),
                _buildKey('6', 'MNO'),
                _buildKey('7', 'PQRS'),
                _buildKey('8', 'TUV'),
                _buildKey('9', 'WXYZ'),
                _buildKey('*', ''),
                _buildKey('0', '+'),
                _buildKey('#', ''),
              ],
            ),
          ),
          // Call Button
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: FloatingActionButton.large(
              onPressed: _makeCall,
              backgroundColor: settings.simColor, // Using SIM color for call button as per some dialers
              child: const Icon(Icons.call, color: Colors.white),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
