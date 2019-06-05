import 'roster_utils.dart';

void main() async {
  if (!await Directory("tools/roster").exists()) {
    print("Please make the 'roster' directory. "
        "Include Roster.csv and EIHS F18--By Name. "
        "If you don't have them, you don't need this script.");
    return;
  }

  var dirsF = Future.wait(makeAllTheDirs());

  await dirsF;

  await Future.wait(
      (await getStudents()).where((s) => s.gradeLevel < 12).map((s) async {
    var orig = File("tools/roster/EIHS F18--By Name/"
        "${s.gradeLevel}/${s.lastName}_${s.firstName}.jpg");
    if (!await orig.exists()) return;
    await orig.copy("tools/roster/byId/${s.gradeLevel}/${s.id}.jpg");
  }));
  print("Done");
}

Iterable<Future<void>> makeAllTheDirs() sync* {
  for (var i = 9; i < 12; i++) {
    yield Directory("tools/roster/byId/$i").create(recursive: true);
  }
}
