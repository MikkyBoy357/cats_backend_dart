import 'dart:convert';

import 'package:cats_backend/common/common.dart';
import 'package:cats_backend/data/data.dart';
import 'package:cats_backend/helpers/helpers.dart';
import 'package:cats_backend/services/services.dart';
import 'package:dart_frog/dart_frog.dart';

Future<Response> onRequest(RequestContext context) async {
  final authValidationResponse = context.read<AuthValidationResponse>();

  if (!authValidationResponse.isValid) {
    return Response.json(
      statusCode: 401,
      body: 'Auth Error: ${authValidationResponse.errorMessage}',
    );
  }

  final saint = authValidationResponse.user!;
  final eventRepository = EventRepository(database: mongoDbService.database);
  final ticketTypeRepository = TicketTypeRepository(
    database: mongoDbService.database,
  );

  final request = context.request;
  final method = request.method;
  final handler = EventRequestHandlerImpl(
    eventRepository: eventRepository,
    ticketTypeRepository: ticketTypeRepository,
  );

  return switch (method) {
    HttpMethod.post => () async {
        final formData = await request.formData();
        final files = formData.files;

        final name = formData.fields['name'];
        final owner = formData.fields['owner'];
        final description = formData.fields['description'];
        final location = formData.fields['location'];
        final dateString = formData.fields['date'];
        final categoriesString = formData.fields['categories'];
        final ticketTypesString = formData.fields['ticketTypes'];

        if ([
          name,
          owner,
          description,
          location,
          dateString,
          categoriesString,
          ticketTypesString,
        ].contains(null)) {
          return Response.json(
            body: {'message': 'Missing required fields'},
            statusCode: 400,
          );
        }

        final date = DateTime.tryParse(dateString!) ?? DateTime.now();

        final categories = (jsonDecode(categoriesString!) as List)
            .map((id) => id.toString())
            .map(toObjectId)
            .toList();

        final ticketTypes = (jsonDecode(ticketTypesString!) as List)
            .map((id) => id.toString())
            .map(toObjectId)
            .toList();

        final eventRequest = EventRequest(
          name: name!,
          owner: owner!,
          description: description!,
          location: location!,
          date: date,
          categories: categories,
          ticketTypes: ticketTypes,
          createdBy: saint.$_id,
          createdAt: DateTime.now(),
        );

        printGreen('Event Request Parsed: ${eventRequest.toJson()}');

        return handler.handleCreateEvent(
          eventRequest: eventRequest,
          saint: saint,
          files: files,
        );
      }(),
    _ => Future.value(Response.json(body: 'Invalid request method')),
  };
}
