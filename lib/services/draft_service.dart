import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class DraftService {
  static const String _transactionDraftKey = 'transaction_draft';
  static const String _clientDraftKey = 'client_draft';

  static Future<void> saveTransactionDraft({
    required String? selectedClientId,
    required String? selectedClientName,
    required String description,
    required String amount,
    required String type,
    required String serviceType,
    required String? paymentMethod,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final draft = {
      'selectedClientId': selectedClientId,
      'selectedClientName': selectedClientName,
      'description': description,
      'amount': amount,
      'type': type,
      'serviceType': serviceType,
      'paymentMethod': paymentMethod,
      'timestamp': DateTime.now().toIso8601String(),
    };
    await prefs.setString(_transactionDraftKey, jsonEncode(draft));
  }

  static Future<Map<String, dynamic>?> getTransactionDraft() async {
    final prefs = await SharedPreferences.getInstance();
    final draftString = prefs.getString(_transactionDraftKey);
    if (draftString == null) return null;
    return jsonDecode(draftString) as Map<String, dynamic>;
  }

  static Future<void> clearTransactionDraft() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_transactionDraftKey);
  }

  static Future<void> saveClientDraft({
    required String name,
    required String email,
    required String phone,
    required String companyName,
    required String registrationNumber,
    required List<Map<String, dynamic>> directors,
    required List<Map<String, dynamic>> services,
    required Map<String, dynamic> platforms,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final draft = {
      'name': name,
      'email': email,
      'phone': phone,
      'companyName': companyName,
      'registrationNumber': registrationNumber,
      'directors': directors,
      'services': services,
      'platforms': platforms,
      'timestamp': DateTime.now().toIso8601String(),
    };
    await prefs.setString(_clientDraftKey, jsonEncode(draft));
  }

  static Future<Map<String, dynamic>?> getClientDraft() async {
    final prefs = await SharedPreferences.getInstance();
    final draftString = prefs.getString(_clientDraftKey);
    if (draftString == null) return null;
    return jsonDecode(draftString) as Map<String, dynamic>;
  }

  static Future<void> clearClientDraft() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_clientDraftKey);
  }
} 