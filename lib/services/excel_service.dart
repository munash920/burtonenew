import 'dart:convert';
import 'package:excel/excel.dart';
import 'package:file_picker/file_picker.dart';
import '../models/client.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ExcelService {
  static Future<String> exportClientsToExcel(List<Client> clients) async {
    final excel = Excel.createExcel();
    final sheet = excel['Clients'];

    // Add headers
    sheet.appendRow([
      'Name',
      'Email',
      'Phone',
      'Company Name',
      'Registration Number',
      'Directors',
      'Services',
      'TARMS Email',
      'CIPZ Email',
    ]);

    // Add data
    for (var client in clients) {
      sheet.appendRow([
        client.name,
        client.email,
        client.phone,
        client.companyName,
        client.registrationNumber,
        client.directors.map((d) => '${d.name} (${d.email})').join('; '),
        client.services.map((s) => s.name).join('; '),
        client.platforms['TARMS']?['email'] ?? '',
        client.platforms['CIPZ']?['email'] ?? '',
      ]);
    }

    // Convert to bytes
    final bytes = excel.encode();
    if (bytes == null) throw Exception('Failed to encode Excel file');

    // Convert to base64 for web
    return base64Encode(bytes);
  }

  static Future<List<Client>> importClientsFromExcel() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['xlsx'],
      allowMultiple: false,
    );

    if (result == null || result.files.isEmpty) {
      throw Exception('No file selected');
    }

    final bytes = result.files.first.bytes;
    if (bytes == null) throw Exception('Failed to read file');

    final excel = Excel.decodeBytes(bytes);
    final sheet = excel.tables[excel.tables.keys.first];
    if (sheet == null) throw Exception('No sheet found in Excel file');

    final headers = sheet.rows[0].map((cell) => cell?.value.toString() ?? '').toList();
    final clients = <Client>[];
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) throw Exception('User not authenticated');

    for (var i = 1; i < sheet.rows.length; i++) {
      final row = sheet.rows[i];
      final clientData = Map<String, String>.fromIterables(
        headers,
        row.map((cell) => cell?.value.toString() ?? ''),
      );

      // Parse directors
      final directorsStr = clientData['Directors'] ?? '';
      final directors = directorsStr.split(';').map((d) {
        final match = RegExp(r'(.*?)\s*\((.*?)\)').firstMatch(d.trim());
        if (match != null) {
          return Director(
            name: match.group(1)?.trim() ?? '',
            email: match.group(2)?.trim() ?? '',
            phone: '', // Default empty as it's not in Excel
          );
        }
        return Director(name: d.trim(), email: '', phone: '');
      }).toList();

      // Parse services
      final servicesStr = clientData['Services'] ?? '';
      final services = servicesStr.split(';')
          .map((s) => Service(
                name: s.trim(),
                description: '', // Default empty as it's not in Excel
              ))
          .toList();

      // Create client
      final client = Client(
        id: '', // Will be set by Firestore
        userId: userId,
        name: clientData['Name'] ?? '',
        email: clientData['Email'] ?? '',
        phone: clientData['Phone'] ?? '',
        companyName: clientData['Company Name'] ?? '',
        registrationNumber: clientData['Registration Number'] ?? '',
        directors: directors,
        services: services,
        platforms: {
          'TARMS': {
            'email': clientData['TARMS Email'] ?? '',
            'password': '', // Default empty as it's not in Excel
          },
          'CIPZ': {
            'email': clientData['CIPZ Email'] ?? '',
            'password': '', // Default empty as it's not in Excel
          },
        },
        createdAt: DateTime.now(),
      );

      clients.add(client);
    }

    return clients;
  }

  static String generateExcelTemplate() {
    final excel = Excel.createExcel();
    final sheet = excel['Template'];

    // Add headers
    sheet.appendRow([
      'Name',
      'Email',
      'Phone',
      'Company Name',
      'Registration Number',
      'Directors',
      'Services',
      'TARMS Email',
      'CIPZ Email',
    ]);

    // Add example row
    sheet.appendRow([
      'John Doe',
      'john@example.com',
      '+1234567890',
      'Example Corp',
      'REG123456',
      'John Doe (john@example.com); Jane Smith (jane@example.com)',
      'Registration; Tax Returns',
      'example@tarms.com',
      'example@cipz.com',
    ]);

    // Convert to bytes and base64
    final bytes = excel.encode();
    if (bytes == null) throw Exception('Failed to encode Excel template');
    return base64Encode(bytes);
  }
} 