import 'package:aqueduct/aqueduct.dart';

import '../models/student.dart';

class StudentsController extends ResourceController {
  StudentsController(this._context);

  final ManagedContext _context;

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
}
