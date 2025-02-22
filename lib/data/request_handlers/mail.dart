import 'package:cats_backend/common/common.dart';
import 'package:cats_backend/data/data.dart';
import 'package:cats_backend/helpers/helpers.dart';
import 'package:dart_frog/dart_frog.dart';

class MailRequestHandler {
  final MailRepository _mailRepository;

  MailRequestHandler({
    required MailRepository mailRepository,
  }) : _mailRepository = mailRepository;

  Future<Response> handleSendTicketConfirmationEmail({
    required String to,
    required String subject,
    required Ticket ticket,
    required PaymentTransactionResponse paymentTransactionResponse,
  }) async {
    printBlue('Ticket Rikky: ${ticket.id}');
    printBlue('Ticket Rikky: ${ticket.toJson()}');
    final qrCodeUrl =
        'http://${await getPublicIpAddress()}:8080/api/qr?keyWord=${ticket.id.oid}';

    final htmlContent = ticketConfirmationHtmlContent(
      qrCodeUrl: qrCodeUrl,
      ticket: ticket,
    );

    final sendReport = await _mailRepository.sendEmail(
      to: to,
      subject: subject,
      htmlContent: htmlContent,
    );

    return Response.json(
      statusCode: sendReport != null ? 200 : 500,
      body: {
        'status': sendReport != null ? 'success' : 'error',
        'message': sendReport != null
            ? 'Ticket confirmation email sent successfully to $to'
            : 'Failed to send ticket confirmation email to $to',
        'sendReport': sendReport.toString(),
      },
    );
  }
}
