import 'package:cats_backend/common/common.dart';
import 'package:cats_backend/config/config.dart';
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server.dart';

abstract class MailRepository {
  Future<SendReport?> sendEmail({
    required String from,
    required String to,
    required String subject,
    required String htmlContent,
  });
}

class MailRepositoryImpl implements MailRepository {
  final String? username;
  final String? password;

  MailRepositoryImpl({
    this.username,
    this.password,
  });

  @override
  Future<SendReport?> sendEmail({
    String from = 'Saint Inc',
    required String to,
    required String subject,
    required String htmlContent,
  }) async {
    final username = this.username ?? Config.gmailUsername;
    final password = this.password ?? Config.gmailPassword;
    final smtpServer = gmail(username, password);

    final message = Message()
      ..from = Address(username, 'Saint Inc.')
      ..recipients.add(to)
      ..subject = subject
      ..html = htmlContent;

    try {
      final sendReport = await send(message, smtpServer);
      printGreen('Message sent: $sendReport');
      return sendReport;
    } on MailerException catch (e) {
      printRed('Message not sent.');
      for (final p in e.problems) {
        printRed('Problem: ${p.code}: ${p.msg}');
      }
    }
    return null;
  }
}
