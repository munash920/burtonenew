import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import '../models/email_template.dart';

class EmailTemplateProvider with ChangeNotifier {
  List<EmailTemplate> _templates = [];
  final _uuid = Uuid();

  EmailTemplateProvider() {
    _initializeTemplates();
  }

  List<EmailTemplate> get templates => _templates;

  void _initializeTemplates() {
    final now = DateTime.now();
    _templates = [
      EmailTemplate(
        id: _uuid.v4(),
        title: 'Account Update Notice',
        content: '''Good day,

Kindly note that we have an important update regarding your account. Please review the details at your earliest convenience.

Thank you for your attention to this matter.

Best regards,
Tafadzwa Mazhara
Marketing and Public Relations Manager
BurtoneCoopër''',
        createdAt: now,
        updatedAt: now,
      ),
      EmailTemplate(
        id: _uuid.v4(),
        title: 'Meeting Schedule',
        content: '''Good day,

Kindly note that you have a scheduled meeting with us on [Date] at [Time]. Please ensure your availability.

We look forward to our discussion.

Best regards,
Tafadzwa Mazhara
Marketing and Public Relations Manager
BurtoneCoopër''',
        createdAt: now,
        updatedAt: now,
      ),
      EmailTemplate(
        id: _uuid.v4(),
        title: 'Payment Reminder',
        content: '''Good day,

Kindly note that your payment for the invoice [Invoice Number] is due on [Due Date]. We appreciate your prompt attention to this matter.

Thank you for your cooperation.

Best regards,
Tafadzwa Mazhara
Marketing and Public Relations Manager
BurtoneCoopër''',
        createdAt: now,
        updatedAt: now,
      ),
    ];
  }

  void addTemplate(String title, String content) {
    final now = DateTime.now();
    final template = EmailTemplate(
      id: _uuid.v4(),
      title: title,
      content: content,
      createdAt: now,
      updatedAt: now,
    );
    _templates.add(template);
    notifyListeners();
  }

  void updateTemplate(String id, String title, String content) {
    final index = _templates.indexWhere((template) => template.id == id);
    if (index != -1) {
      _templates[index] = EmailTemplate(
        id: id,
        title: title,
        content: content,
        createdAt: _templates[index].createdAt,
        updatedAt: DateTime.now(),
      );
      notifyListeners();
    }
  }

  void deleteTemplate(String id) {
    _templates.removeWhere((template) => template.id == id);
    notifyListeners();
  }
}
