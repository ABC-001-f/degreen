import 'dart:convert';
import 'dart:io';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'content.dart';


class StorageHelper {
  static Box<Content>? _contentBox;

  static Future<void> init() async {
    await Hive.initFlutter();
    Hive.registerAdapter(ContentAdapter());
    _contentBox = await Hive.openBox<Content>('contentBox');
  }

  static List<Content> getAllContent() {
    return _contentBox?.values.toList() ?? [];
  }

  static void addContent(Content content) {
    _contentBox?.add(content);
  }

  static void updateContent(int index, Content content) {
    _contentBox?.putAt(index, content);
  }

  static void deleteContent(int index) {
    _contentBox?.deleteAt(index);
  }

  static void saveContentToFile(Content content) async {
    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/content_${content.datetime.toIso8601String()}.json');
    final jsonString = jsonEncode(content.toJson());
    await file.writeAsString(jsonString);
  }

  static void deleteContentFromFile(DateTime dateTime) async {
    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/content_${dateTime.toIso8601String()}.json');
    if (await file.exists()) {
      await file.delete();
    }
  }
}
