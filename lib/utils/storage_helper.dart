import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'content.dart';

class StorageHelper {
  static const String boxName = 'contentBox';

  static Future<void> init() async {
    if (!kIsWeb) {
      final appDocumentDir = await getApplicationDocumentsDirectory();
      Hive.init(appDocumentDir.path);
    } else {
      await Hive.initFlutter();
    }
    Hive.registerAdapter(ContentAdapter());
    await Hive.openBox<Content>(boxName);
  }

  static Box<Content> getBox() => Hive.box<Content>(boxName);

  static Future<void> addContent(Content content) async {
    final box = getBox();
    await box.add(content);
  }

  static List<Content> getAllContent() {
    final box = getBox();
    return box.values.toList();
  }

  static Future<void> deleteContent(int index) async {
    final box = getBox();
    await box.deleteAt(index);
  }

  static Future<void> saveContentToFile(Content content) async {
    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/${content.datetime.toIso8601String()}.json');
    await file.writeAsString(jsonEncode(content.toJson()));
  }

  static Future<List<Content>> readContentFromFile() async {
    final directory = await getApplicationDocumentsDirectory();
    final files = directory.listSync();
    List<Content> contents = [];

    for (var file in files) {
      if (file is File && file.path.endsWith('.json')) {
        final jsonContent = jsonDecode(await file.readAsString());
        contents.add(Content.fromJson(jsonContent));
      }
    }

    return contents;
  }

  static Future<void> deleteContentFromFile(DateTime datetime) async {
    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/${datetime.toIso8601String()}.json');
    if (await file.exists()) {
      await file.delete();
    }
  }
}
