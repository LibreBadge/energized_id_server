import 'dart:io';

import 'package:aqueduct/aqueduct.dart';
import 'package:path/path.dart' as path;

import '../models/student.dart';

class StudentsController extends ResourceController {
  StudentsController(this._context, String imageStoreDir)
      : _imageStoreDir = path.join(imageStoreDir, "students");

  final ManagedContext _context;
  final String _imageStoreDir;

  @Operation.get("id")
  Future<Response> getStudentById(@Bind.path("id") int id) async {
    final studentQuery = Query<DbStudent>(_context)
      ..where((s) => s.id).equalTo(id);

    final student = await studentQuery.fetchOne();

    if (student == null) {
      return Response.notFound();
    }
    return Response.ok(student);
  }

  @Operation.put("id")
  Future<Response> putStudentById(
      @Bind.path("id") int id, @Bind.body() DbStudent student) async {
    if (student.id != null && student.id != id) {
      return Response.badRequest(body: "ID in url and body don't match");
    }

    final query = Query<DbStudent>(_context)
      ..where((s) => s.id).equalTo(id)
      ..values = student;
    query.values.id = id;
    if (await query.fetchOne() != null) {
      return Response.ok(await query.updateOne());
    } else {
      final responseBody = query.insert();
      await File(path.join(_imageStoreDir, "placeholder.jpg"))
          .copy(path.join(_imageStoreDir, "$id.jpg"));
      return Response.ok(await responseBody);
    }
  }

  @Operation.delete("id")
  Future<Response> deleteStudentById(@Bind.path("id") int id) async {
    final query = Query<DbStudent>(_context)..where((s) => s.id).equalTo(id);
    final numDeleted = await query.delete();
    if (numDeleted > 0) {
      try {
        await File(path.join(_imageStoreDir, "$id.jpg")).delete();
      } on FileSystemException {}
      return Response.ok(null);
    } else {
      return Response.notFound();
    }
  }
}
