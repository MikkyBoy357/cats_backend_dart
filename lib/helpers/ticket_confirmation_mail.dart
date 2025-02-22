import 'package:cats_backend/common/common.dart';
import 'package:intl/intl.dart';

String ticketConfirmationHtmlContent({
  required String qrCodeUrl,
  required Ticket ticket,
}) {
  final event = ticket.event.fold(
    (l) => Event.sampleData(),
    (r) => r,
  );
  final ticketOwner = ticket.issuedTo;
  final ticketType = ticket.ticketType.fold(
    (l) => TicketType.sampleData(),
    (r) => r,
  );

  final eventDate = event.date;
  final friendlyDate = DateFormat('MMMM d, yyyy').format(eventDate);
  final friendlyTime = DateFormat('h:mm a').format(eventDate);

  return '''
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
    <meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0"/>
    <title>${event.name} Confirmation</title>
</head>
<body style="margin: 0; padding: 0; font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, Helvetica, Arial, sans-serif; background-color: #f4f4f4;">
    <!-- Main Container -->
    <table border="0" cellpadding="0" cellspacing="0" width="100%" style="background-color: #f4f4f4; padding: 20px;">
        <tr>
            <td align="center">
                <!-- Content Container -->
                <table border="0" cellpadding="0" cellspacing="0" width="100%" style="max-width: 600px; background-color: #ffffff; border-radius: 16px; overflow: hidden; box-shadow: 0 4px 12px rgba(0, 0, 0, 0.1);">
                    <!-- Header -->
                    <tr>
                        <td align="center" style="background-color: #5454D1; padding: 30px;">
                            <img src="$qrCodeUrl" alt="QR Code" style="width: 32px; height: 32px;" />
                            <div style="color: #ffffff; font-size: 20px; font-weight: 500;">Ticket #${ticket.ticketNumber}</div>
                        </td>
                    </tr>

                    <!-- Content -->
                    <tr>
                        <td style="padding: 30px;">
                            <!-- Event Name -->
                            <h1 style="margin: 0 0 20px 0; font-size: 24px; color: #5454D1;">${event.name}</h1>

                            <!-- Ticket Type Badge -->
                            <div style="display: inline-block; background-color: #5454D1; color: white; padding: 8px 16px; border-radius: 20px; font-size: 14px; font-weight: 500; margin-bottom: 20px;">${ticketType.name} TICKET</div>

                            <!-- Event Details -->
                            <table border="0" cellpadding="0" cellspacing="0" width="100%" style="margin-bottom: 20px;">
                                <tr>
                                    <td style="padding: 10px 0;">
                                        <table border="0" cellpadding="0" cellspacing="0">
                                            <tr>
                                                <td width="24" style="padding-right: 15px;">
                                                    🗓️
                                                </td>
                                                <td style="color: #1f2937;">$friendlyDate</td>
                                            </tr>
                                        </table>
                                    </td>
                                </tr>
                                <tr>
                                    <td style="padding: 10px 0;">
                                        <table border="0" cellpadding="0" cellspacing="0">
                                            <tr>
                                                <td width="24" style="padding-right: 15px;">
                                                    ⏰
                                                </td>
                                                <td style="color: #1f2937;">$friendlyTime</td>
                                            </tr>
                                        </table>
                                    </td>
                                </tr>
                                <tr>
                                    <td style="padding: 10px 0;">
                                        <table border="0" cellpadding="0" cellspacing="0">
                                            <tr>
                                                <td width="24" style="padding-right: 15px;">
                                                    📍
                                                </td>
                                                <td style="color: #1f2937;">${event.location}</td>
                                            </tr>
                                        </table>
                                    </td>
                                </tr>
                                <tr>
                                    <td style="padding: 10px 0;">
                                        <table border="0" cellpadding="0" cellspacing="0">
                                            <tr>
                                                <td width="24" style="padding-right: 15px;">
                                                    😎
                                                </td>
                                                <td style="color: #1f2937;">${ticketOwner.name}</td>
                                            </tr>
                                        </table>
                                    </td>
                                </tr>
                            </table>

                            <!-- Additional Details -->
                            <table border="0" cellpadding="0" cellspacing="0" width="100%" style="background-color: #f8f8f8; border-radius: 8px; margin-bottom: 20px;">
                                <tr>
                                    <td style="padding: 20px;">
                                        <table border="0" cellpadding="0" cellspacing="0" width="100%">
                                            <tr>
                                                <td style="padding-bottom: 10px;">
                                                    <strong style="color: #5454D1;">${ticketType.name} Benefits:</strong>
                                                </td>
                                            </tr>
                                            <tr>
                                                <td style="color: #666666; font-size: 14px; line-height: 1.5;">
                                                    • Priority entrance<br/>
                                                    • Access to VIP lounge<br/>
                                                    • Meet & Greet with artists<br/>
                                                    • Complimentary refreshments
                                                </td>
                                            </tr>
                                        </table>
                                    </td>
                                </tr>
                            </table>

                            <!-- QR Code -->
                            <table border="0" cellpadding="0" cellspacing="0" width="100%" style="margin-bottom: 20px;">
                                <tr>
                                    <td align="center">
                                        <img src="$qrCodeUrl" alt="QR Code" style="width: 150px; height: 150px;" />
                                        <p style="margin: 10px 0 0 0; color: #666666; font-size: 14px;">Scan for quick entry</p>
                                    </td>
                                </tr>
                            </table>
                        </td>
                    </tr>

                    <!-- Footer -->
                    <tr>
                        <td style="padding: 20px; background-color: #f4f4f4; text-align: center;">
                            <p style="margin: 0; color: #666666; font-size: 14px;">Thank you for your purchase! Please present this ticket at the event entrance.</p>
                        </td>
                    </tr>
                </table>

                <!-- Additional Information -->
                <table border="0" cellpadding="0" cellspacing="0" width="100%" style="max-width: 600px; margin-top: 20px;">
                    <tr>
                        <td style="padding: 20px; text-align: center; color: #666666; font-size: 12px;">
                            <p style="margin: 0;">This ticket was sent to ${ticketOwner.email}</p>
                            <p style="margin: 10px 0 0 0;">If you have any questions, please contact our support team.</p>
                        </td>
                    </tr>
                </table>
            </td>
        </tr>
    </table>
</body>
</html>
  ''';
}
