import 'dart:io';

import 'package:aqueduct/aqueduct.dart';

import 'controllers/students_controller.dart';
import 'controllers/student_images_controller.dart';

/// This type initializes an application.
///
/// Override methods in this class to set up routes and initialize services like
/// database connections. See http://aqueduct.io/docs/http/channel/.
class EnergizedIdServerChannel extends ApplicationChannel {
  IdConfig _config;
  ManagedContext _context;

  /// Initialize services in this method.
  ///
  /// Implement this method to initialize services, read values from [options]
  /// and any other initialization required before constructing [entryPoint].
  ///
  /// This method is invoked prior to [entryPoint] being accessed.
  @override
  Future prepare() async {
    logger.onRecord.listen(
        (rec) => print("$rec ${rec.error ?? ""} ${rec.stackTrace ?? ""}"));

    _config = IdConfig(options.configurationFilePath);

    final dataModel = ManagedDataModel.fromCurrentMirrorSystem();
    final persistentStore = PostgreSQLPersistentStore.fromConnectionInfo(
        _config.database.username,
        _config.database.password,
        _config.database.host,
        _config.database.port,
        _config.database.databaseName);

    _context = ManagedContext(dataModel, persistentStore);
  }

  /// Construct the request channel.
  ///
  /// Return an instance of some [Controller] that will be the initial receiver
  /// of all [Request]s.
  ///
  /// This method is invoked after [prepare].
  @override
  Controller get entryPoint {
    final router = Router();

    // Prefer to use `link` instead of `linkFunction`.
    // See: https://aqueduct.io/docs/http/request_controller/
    router.route("/example").linkFunction((request) async {
      return Response.ok({"key": "value"});
    });

    router
        .route("/students/[:id]")
        .link(() => StudentsController(_context, _config.imageStoreDir));
    router
        .route("/students/:id/image")
        .link(() => StudentImagesController(_config.imageStoreDir));

    router.route("/*").link(() => FileController(_config.fileServeDir));

    return router;
  }
}

class IdConfig extends Configuration {
  IdConfig(String path) : super.fromFile(File(path));

  String fileServeDir;
  String imageStoreDir;
  DatabaseConfiguration database;
}
