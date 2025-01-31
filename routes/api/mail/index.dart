import 'package:dart_frog/dart_frog.dart';
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server.dart';

Future<Response> onRequest(RequestContext context) async {
  // Gmail credentials
  String username = 'saintrikky357@gmail.com';
  String password = 'mcch jvae nevl kduq';

  // SMTP server configuration
  final smtpServer = gmail(username, password);

  // Email content
  final htmlContent = '''
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Event Ticket Confirmation</title>
  <style>
    /* General Styles */
    body {
      font-family: Arial, sans-serif;
      margin: 0;
      padding: 0;
      background-color: #f4f4f4;
    }

    .email-container {
      max-width: 600px;
      margin: 0 auto;
      background-color: #ffffff;
      border-radius: 8px;
      overflow: hidden;
      box-shadow: 0 4px 8px rgba(0, 0, 0, 0.1);
    }

    .header {
      background-color: #ff4757;
      color: #ffffff;
      text-align: center;
      padding: 20px;
    }

    .header h1 {
      margin: 0;
      font-size: 24px;
    }

    .content {
      padding: 20px;
      color: #333333;
    }

    .ticket-details {
      background-color: #f9f9f9;
      padding: 15px;
      border-radius: 8px;
      margin-bottom: 20px;
    }

    .ticket-details h2 {
      margin-top: 0;
      font-size: 20px;
      color: #ff4757;
    }

    .ticket-details p {
      margin: 5px 0;
    }

    .footer {
      text-align: center;
      padding: 15px;
      background-color: #f4f4f4;
      color: #666666;
      font-size: 14px;
    }

    .footer a {
      color: #ff4757;
      text-decoration: none;
    }

    .footer a:hover {
      text-decoration: underline;
    }

    /* Responsive Styles */
    @media only screen and (max-width: 600px) {
      .email-container {
        width: 100%;
        border-radius: 0;
      }

      .header h1 {
        font-size: 20px;
      }

      .ticket-details h2 {
        font-size: 18px;
      }
    }
  </style>
</head>
<body>
  <div class="email-container">
    <!-- Header -->
    <div class="header">
      <h1>Your Event Ticket Confirmation</h1>
    </div>

    <!-- Content -->
    <div class="content">
      <p>Hello [User's Name],</p>
      <p>Thank you for purchasing your ticket! Below are the details of your event:</p>

      <!-- Ticket Details -->
      <div class="ticket-details">
        <h2>[Event Name]</h2>
        <p><strong>Date:</strong> [Event Date]</p>
        <p><strong>Time:</strong> [Event Time]</p>
        <p><strong>Venue:</strong> [Event Venue]</p>
        <p><strong>Ticket Type:</strong> [Ticket Type]</p>
        <p><strong>Order ID:</strong> [Order ID]</p>
      </div>

      <p>Please present this ticket at the entrance. We look forward to seeing you there!</p>
      <p>If you have any questions, feel free to contact us at <a href="mailto:support@eventfinder.com">support@eventfinder.com</a>.</p>
    </div>

    <!-- Footer -->
    <div class="footer">
      <p>&copy; 2023 EventFinder. All rights reserved.</p>
      <p><a href="#">Unsubscribe</a> | <a href="#">Privacy Policy</a></p>
    </div>
  </div>
</body>
</html>
  ''';

  // Create the email message
  final message = Message()
    ..from = Address(username, 'EventFinder')
    ..recipients
        .add('michaelolusegun357@gmail.com') // Replace with the user's email
    ..subject = 'Your Event Ticket Confirmation'
    ..html = htmlContent;

  try {
    // Send the email
    final sendReport = await send(message, smtpServer);
    print('Message sent: ${sendReport.toString()}');
    return Response.json(body: {'sendReport': sendReport.toString()});
  } on MailerException catch (e) {
    print('Message not sent.');
    for (var p in e.problems) {
      print('Problem: ${p.code}: ${p.msg}');
    }
    return Response.json(body: {'error': e.toString()});
  }
}
