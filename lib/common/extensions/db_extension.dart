import 'package:mongo_dart/mongo_dart.dart';

extension DbX on Db {
  DbCollection get usersCollection => collection('users');
  DbCollection get catsCollection => collection('cats');
  DbCollection get followersCollection => collection('followers');
  DbCollection get transactionsCollection => collection('transactions');
  DbCollection get chatsCollection => collection('chats');
  DbCollection get chatMessagesCollection => collection('chatMessages');
}
