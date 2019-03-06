import 'package:aqueduct/aqueduct.dart';
import 'package:energized_id/energized_id.dart';

class DbStudent extends ManagedObject<_DbStudent> implements _DbStudent {}

@Table(name: "StudentTable")
class _DbStudent with StudentRecord {
  // can't use @primaryKey bcuz don't want to autoincrement
  @Column(primaryKey: true)
  int id;

  @Column()
  String firstName;

  @Column()
  String lastName;

  @Column()
  int gradeLevel;

  @Column(nullable: true)
  DateTime lastPrinted;
}
