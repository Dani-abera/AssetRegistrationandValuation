import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server/gmail.dart';

class EmailSend {
  // Helper method to send email
  Future<void> sendValidatorCredentials(String email, String password) async {
    //  email credentials
    String username = 'daniabera74@gmail.com';
    String password = 'ybot wtyf yhmp wnxr'; //  app-specific password for Gmail

    final smtpServer = gmail(username, password);

    final message = Message()
      ..from = Address(username, 'LandHouseVerify')
      ..recipients.add(email)
      ..subject = 'Your Validator Account Credentials'
      ..text = '''
        Welcome as an approved validator!
        
        Here are your login credentials:
        Email: $email
        Password: Password123
        
        Please change your password after your first login.
        
        Best regards,
        Your App Team
      ''';

    try {
      await send(message, smtpServer);
    } catch (e) {
      print('Error sending email: $e');
    }
  }
}
