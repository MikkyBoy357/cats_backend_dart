import 'dart:convert';

import 'package:dart_frog/dart_frog.dart';
import 'package:mongo_dart/mongo_dart.dart';

extension DbX on Db {
  DbCollection get usersCollection => collection('users');
  DbCollection get catsCollection => collection('cats');
  DbCollection get followersCollection => collection('followers');
  DbCollection get transactionsCollection => collection('transactions');
  DbCollection get chatsCollection => collection('chats');
  DbCollection get chatMessagesCollection => collection('chatMessages');
  DbCollection get postsCollection => collection('posts');
  DbCollection get eventsCollection => collection('events');
  DbCollection get ticketTypesCollection => collection('ticketTypes');
}

extension RequestX on Request {
  Future<Map<String, dynamic>?> get tryJson async => () async {
        try {
          final x = jsonDecode(await body()) as Map<String, dynamic>;
          return x;
        } catch (e) {
          print('Error parsing JSON: $e');
          return null;
        }
      }();
}
