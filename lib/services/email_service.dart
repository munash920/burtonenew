import 'package:flutter_email_sender/flutter_email_sender.dart';

class EmailService {
  static final EmailService _instance = EmailService._internal();
  factory EmailService() => _instance;
  EmailService._internal();

  final String _senderName = 'Tafadzwa Mazhara';
  final String _senderTitle = 'Marketing and Public Relations Manager';
  final String _companyName = 'BurtoneCoopër';

  Future<void> sendEmail({
    required List<String> recipients,
    required String subject,
    required String content,
  }) async {
    try {
      final Email email = Email(
        body: content + getSignature(),
        subject: subject,
        bcc: recipients,
        isHTML: false,
      );

      await FlutterEmailSender.send(email);
      print('Email sent successfully');
    } catch (e) {
      print('Failed to send email: $e');
      rethrow;
    }
  }

  String getSignature() {
    return '''

Best regards,
$_senderName
$_senderTitle
$_companyName''';
  }
}
