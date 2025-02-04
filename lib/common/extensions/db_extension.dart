import 'dart:convert';

import 'package:cats_backend/common/common.dart';
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
  DbCollection get eventCategoriesCollection => collection('eventCategories');
  DbCollection get ticketTypesCollection => collection('ticketTypes');
  DbCollection get ticketsCollection => collection('tickets');
  DbCollection get sckalerCollectionsCollection =>
      collection('sckalerCollections');
}

extension RequestX on Request {
  Future<Map<String, dynamic>?> get tryJson async => () async {
        try {
          final x = jsonDecode(await body()) as Map<String, dynamic>;
          return x;
        } catch (e) {
          printYellow('Error parsing JSON: $e');
          return null;
        }
      }();
}
