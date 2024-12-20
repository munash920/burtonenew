import 'package:flutter/material.dart';

class PlatformCredentialForm extends StatelessWidget {
  final Map<String, dynamic> platforms;
  final Function(Map<String, dynamic>) onPlatformsChanged;

  const PlatformCredentialForm({
    Key? key,
    required this.platforms,
    required this.onPlatformsChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextFormField(
          initialValue: platforms['CIPZ']?['email'] ?? '',
          decoration: const InputDecoration(
            labelText: 'CIPZ Email',
            border: OutlineInputBorder(),
          ),
          onChanged: (value) {
            platforms['CIPZ'] = {'email': value};
            onPlatformsChanged(platforms);
          },
        ),
        const SizedBox(height: 8),
        TextFormField(
          initialValue: platforms['CIPZ']?['password'] ?? '',
          decoration: const InputDecoration(
            labelText: 'CIPZ Password',
            border: OutlineInputBorder(),
          ),
          obscureText: true,
          onChanged: (value) {
            platforms['CIPZ'] = {'password': value};
            onPlatformsChanged(platforms);
          },
        ),
        const SizedBox(height: 16),
        TextFormField(
          initialValue: platforms['TARMS']?['email'] ?? '',
          decoration: const InputDecoration(
            labelText: 'TARMS Email',
            border: OutlineInputBorder(),
          ),
          onChanged: (value) {
            platforms['TARMS'] = {'email': value};
            onPlatformsChanged(platforms);
          },
        ),
        const SizedBox(height: 8),
        TextFormField(
          initialValue: platforms['TARMS']?['password'] ?? '',
          decoration: const InputDecoration(
            labelText: 'TARMS Password',
            border: OutlineInputBorder(),
          ),
          obscureText: true,
          onChanged: (value) {
            platforms['TARMS'] = {'password': value};
            onPlatformsChanged(platforms);
          },
        ),
      ],
    );
  }
} 