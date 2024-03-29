import 'dart:io';
import 'dart:convert';
import 'dart:async';
import 'package:path_provider/path_provider.dart';

Future<String> saveJsonToDisk(String json, String fileName) async {
  if (json.isEmpty) throw "Empty json";
  Directory dir = await getApplicationDocumentsDirectory();

  final basePath = "${dir.path}${Platform.pathSeparator}";

  // 1. Write the file as filename_new
  final String newFilename = "${fileName}_new.json";
  final String path = "$basePath$newFilename";
  File f = File(path);
  await f.writeAsString(json);

  // 2. Rename the old file to oldfile_bck.json
  File oldFile = File("$basePath$fileName.json");
  if (await oldFile.exists()) {
    await oldFile.rename("$basePath${fileName}_bck.json");
  }

  // 3. Rename the new file fileName.json
  await f.rename("$basePath$fileName.json");

  // done
  return path;
}

Future<Map<String, dynamic>> readJsonFile(String fileName) async {
  final Directory dir = await getApplicationDocumentsDirectory();
  final basePath = "${dir.path}${Platform.pathSeparator}";
  final path = "$basePath$fileName.json";
  try {
    // try normal
    if (await File(path).exists()) {
      return await readJsonFromFilePath(path);
    } else {
      // try backup
      final backupPath = "$basePath${fileName}_bck.json";
      if (await File(backupPath).exists()) {
        return await readJsonFromFilePath(backupPath);
      }
      // otherwise just return empty
      return {};
    }
  } catch (e) {
    rethrow;
  }
}

Future<Map<String, dynamic>> readJsonFromFilePath(String path) async {
  try {
    final jsonFile = File(path);
    if (!await jsonFile.exists()) {
      throw "file: '$path' doesn't exits!";
    }

    final String contents = await jsonFile.readAsString();
    return jsonDecode(contents);
  } catch (e) {
    rethrow;
  }
}
