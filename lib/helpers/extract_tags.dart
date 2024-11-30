List<String> extractHashtags(String caption) {
  final hashtagRegExp = RegExp(r'\B#\w\w+');
  return hashtagRegExp
      .allMatches(caption)
      .map((match) => match.group(0)!.substring(1))
      .toList();
}

List<String> extractUserTags(String caption) {
  final userTagRegExp = RegExp(r'\B@\w+');
  return userTagRegExp
      .allMatches(caption)
      .map((match) => match.group(0)!.substring(1))
      .toList();
}
