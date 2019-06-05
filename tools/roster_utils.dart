import 'roster_utils.dart';

export 'dart:io';

export 'package:csv/csv.dart';
export 'package:energized_id/energized_id.dart';

final RegExp _lastNameRegex = RegExp("(.+),");
final RegExp _firstNameRegex = RegExp(",\\s*([\\S]+)");

String lastName(String rosterName) =>
    _lastNameRegex.firstMatch(rosterName).group(1);
String firstName(String rosterName) =>
    _firstNameRegex.firstMatch(rosterName).group(1);

Future<Iterable<Student>> getStudents() async {
  var roster = CsvToListConverter().convert(await File("tools/roster/Roster.csv").readAsString());
  return roster.map((List<dynamic> record) => Student()
    ..lastName = lastName(record[0])
    ..firstName = firstName(record[0])
    ..id = record[1]
    ..gradeLevel = record[2]);
}