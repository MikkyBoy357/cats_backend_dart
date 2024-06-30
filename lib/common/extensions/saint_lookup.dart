import 'package:mongo_dart/mongo_dart.dart';

class SaintLookup {
  final String from;
  final String localField;
  final String foreignField;
  final String as;

  SaintLookup({
    required this.from,
    required this.localField,
    required this.foreignField,
    required this.as,
  });

  Lookup toMongoLookup() {
    return Lookup(
      from: from,
      localField: localField,
      foreignField: foreignField,
      as: as,
    );
  }
}
