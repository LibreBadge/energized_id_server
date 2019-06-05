import 'dart:convert';

import 'package:http/http.dart' as http;

import 'roster_utils.dart';

const origin = "http://localhost:8888";

final _client = http.Client();

void main() async {
  if (!await Directory("tools/roster").exists()) {
    print("Please make the 'roster' directory. "
        "Include Roster.csv and EIHS F18--By Name. "
        "If you don't have them, you don't need this script.");
    print("You should also run roster_photo_rename.dart first.");
    return;
  }
  if (!await Directory("tools/roster/byId").exists()) {
    print("Run roster_photo_rename.dart first.");
  }

  await Future.wait(
      (await getStudents()).where((s) => s.gradeLevel < 12).map((s) async {
    await _client.put(
      "$origin/students/${s.id}",
      body: jsonEncode((s..gradeLevel += 1).toJson()),
      headers: {"Content-Type": "application/json"},
    );
    var imgfile = File("tools/roster/byId/"
        "${s.gradeLevel - 1}/${s.id}.jpg");
    if (await imgfile.exists()) {
      await _client.put(
        "$origin/students/${s.id}/image",
        body: await imgfile.readAsBytes(),
        headers: {"Content-Type": "image/jpeg"},
      );
    }
  }));
  print("Done");
  _client.close();
}
