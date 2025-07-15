import 'package:cats_backend/common/common.dart';
import 'package:cats_backend/config/config.dart';
import 'package:cats_backend/helpers/helpers.dart';
import 'package:mongo_dart/mongo_dart.dart';
import 'package:paystack/paystack.dart' hide HttpMethod, Response;

final mongoDbService = MongoService();
final paystackClient = PaystackClient(
  secretKey: Config.paystackSecretKey,
);

class MongoService {
  MongoService();

  bool _initialized = false;
  Db? _database;

  bool get isInitialized => _initialized;
  int get secondsSinceStart => DateTime.now().difference(startTime).inSeconds;
  int get secondsSinceLastRequest =>
      DateTime.now().difference(lastRequestTime).inSeconds;

  // TODO: Make this async and validate the connection before using it
  Db get database {
    assert(_database != null, 'MongoDB is not initialized');
    printBlue(
      'MasterConnection validation: ${_database?.masterConnection.connected}',
    );
    return _database!;
  }

  Future<void> initializeMongo() async {
    if (!_initialized) {
      _database = await Db.create(Config.mongoDBUrl);
      _initialized = true;

      await open();
    }
    printGreen(
      '==================> Connected to MongoDB ✅ <==================',
    );
  }

  Future<void> open() async {
    final stopwatch = Stopwatch()..start();
    if (_database!.state == State.open) {
      printBlue('========> ⚠️ MongoDB is already OPEN <========');
      return;
    }
    if (_database!.state == State.opening) {
      printYellow('========> ⚠️ MongoDB is opening... <========');
      await Future<void>.delayed(const Duration(seconds: 3));
    }
    printGreen('==================> Opening MongoDB... <==================');
    await _database!.open();
    stopwatch.stop();
    printGreen(
      '==================> ✅ MongoDB OPENED in ${stopwatch.elapsed} <==================',
    );
  }

  Future<void> close() async {
    if (_database!.state == State.closed) {
      printYellow('========> ⚠️ MongoDB is already CLOSED <========');
      return;
    }
    await _database!.close();
    printRed(
      '******************> Closed MongoDB Connection <******************',
    );
  }

  Future<void> refreshDbConnection() async {
    printMagenta('========> 🌳 Refreshing MongoDB Connection... <========');
    printBlue('startTime: $startTime');
    printMagenta('secondsSinceStart: $secondsSinceStart');
    printBlue('lastRequestTime: $lastRequestTime');
    printMagenta('secondsSinceLastRequest: $secondsSinceLastRequest');
    printGreen('requestCount: $requestCount');

    final requestCountFresh = requestCount % 10 == 0;
    final lastRequestTimeFresh = secondsSinceLastRequest < 120;

    // Renew MongoDB connection every 2 minutes and after every 10 requests
    printGreen('requestCountFresh: $requestCountFresh');
    printGreen('lastRequestTimeFresh: $lastRequestTimeFresh');
    if (requestCountFresh || lastRequestTimeFresh) {
      printBlue('========> 😎 MongoDB Connection is still fresh <========');
      return;
    }
    printYellow('========> ⚠️ Refreshing MongoDB Connection... <========');

    await close();
    _database = await Db.create(Config.mongoDBUrl);
    await open();
    printGreen(
      '==================> Re-Opened MongoDB ✅ <==================',
    );
  }
}
