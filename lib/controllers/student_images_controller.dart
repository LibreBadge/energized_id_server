import 'dart:io';

import 'package:async/async.dart';
import 'package:aqueduct/aqueduct.dart';
import 'package:image/image.dart';
import 'package:path/path.dart' as path;

const _supportedSubTypes = {"jpg", "jpeg", "png", "gif"};

class StudentImagesController extends Controller {
  StudentImagesController(String imageStoreDir)
      : _imageStoreDir = path.join(imageStoreDir, "students");

  final String _imageStoreDir;

  @override
  Future<Response> handle(Request request) {
    switch (request.method) {
      case "GET":
        return handleGet(request);
      case "PUT":
        return handlePut(request);
      case "DELETE":
        return Future.value(Response(405, null, "Use DELETE on /students/:id"));
      default:
        return Future.value(Response(405, null, null));
    }
  }

  Future<Response> handleGet(Request request) async {
    if (!request.acceptsContentType(ContentType("image", "jpeg"))) {
      return Response(406, null, null);
    }

    final file =
        File(path.join(_imageStoreDir, "${request.path.variables["id"]}.jpg"));
    if (!await file.exists()) {
      return Response.notFound();
    }

    return Response.ok(file.openRead())
      ..contentType = ContentType("image", "jpeg")
      ..encodeBody = false;
  }

  Future<Response> handlePut(Request request) async {
    if (request.body.contentType.primaryType != "image" ||
        !_supportedSubTypes.contains(request.body.contentType.subType)) {
      return Response(415, null, null);
    }

    final body = await collectBytes(request.body.bytes);
    Image image;
    try {
      image = decodeImage(body);
    } on FormatException {
      return Response.badRequest(body: "Corrupt image data");
    }

    final outfile =
        File(path.join(_imageStoreDir, "${request.path.variables["id"]}.jpg"));
    await outfile.create(recursive: true);
    await outfile.writeAsBytes(encodeJpg(image));
    return Response(204, null, null);
  }
}
