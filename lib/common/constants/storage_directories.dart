class StorageDirectories {
  const StorageDirectories();

  static String chatsById({required String chatId}) {
    return 'chats/$chatId';
  }

  static String avatarById({required String userId}) {
    return 'avatars/$userId';
  }
}
