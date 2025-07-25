import 'package:cats_backend/config/config.dart';
import 'package:get_it/get_it.dart';
import 'package:mongo_pool/mongo_pool.dart';
import 'package:paystack/paystack.dart';

final getIt = GetIt.instance;

void setupLocator() {
  getIt
    ..registerLazySingleton(
      () => MongoDbPoolService(
        const MongoPoolConfiguration(
          maxLifetimeMilliseconds: 900000,
          leakDetectionThreshold: 100000,
          uriString: Config.mongoDBUrl,
          poolSize: 20,
        ),
      ),
    )
    ..registerLazySingleton(() => PaystackClient())
    ..registerLazySingleton(
      () => ConnectionPool(
        10,
        () => Db.create(Config.mongoDBUrl),
      ),
    );
}
