import 'package:cats_backend/config/config.dart';
import 'package:mongo_dart/mongo_dart.dart';

final mongoDbService = MongoService();

class MongoService {
  MongoService();

  bool _initialized = false;
  Db? _database;

  bool get isInitialized => _initialized;

  Db get database {
    assert(_database != null, 'MongoDB is not initialized');
    return _database!;
  }

  Future<void> initializeMongo() async {
    if (!_initialized) {
      _database = await Db.create(Config.mongoDBUrl);
      _initialized = true;
    }
    print('==================> Connected to MongoDB <==================');
  }

  Future<void> open() async {
    await _database!.open();
  }

  Future<void> close() async {
    await _database!.close();
  }
}
