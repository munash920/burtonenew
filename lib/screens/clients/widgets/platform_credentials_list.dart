import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class PlatformCredentialsList extends StatelessWidget {
  final Map<String, dynamic> platforms;

  const PlatformCredentialsList({
    Key? key,
    required this.platforms,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: platforms.entries.map((entry) {
        final platform = entry.key;
        final credentials = entry.value as Map<String, dynamic>;
        return _PlatformCredentialTile(
          platform: platform,
          credentials: credentials,
        );
      }).toList(),
    );
  }
}

class _PlatformCredentialTile extends StatefulWidget {
  final String platform;
  final Map<String, dynamic> credentials;

  const _PlatformCredentialTile({
    required this.platform,
    required this.credentials,
  });

  @override
  _PlatformCredentialTileState createState() => _PlatformCredentialTileState();
}

class _PlatformCredentialTileState extends State<_PlatformCredentialTile> {
  bool _showPassword = false;

  void _copyToClipboard(String text, String field) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$field copied to clipboard'),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ExpansionTile(
        title: Text(
          widget.platform,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.email_outlined, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        widget.credentials['email'] as String? ?? '',
                        style: const TextStyle(fontSize: 16),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.copy, size: 20),
                      onPressed: () {
                        _copyToClipboard(
                          widget.credentials['email'] as String? ?? '',
                          'Email',
                        );
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.lock_outline, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _showPassword
                            ? widget.credentials['password'] as String? ?? ''
                            : '••••••••',
                        style: const TextStyle(fontSize: 16),
                      ),
                    ),
                    IconButton(
                      icon: Icon(
                        _showPassword ? Icons.visibility_off : Icons.visibility,
                        size: 20,
                      ),
                      onPressed: () {
                        setState(() {
                          _showPassword = !_showPassword;
                        });
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.copy, size: 20),
                      onPressed: () {
                        _copyToClipboard(
                          widget.credentials['password'] as String? ?? '',
                          'Password',
                        );
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
} 