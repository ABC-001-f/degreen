import 'package:hive/hive.dart';
import 'package:json_annotation/json_annotation.dart';

part 'content.g.dart';

@JsonSerializable()
@HiveType(typeId: 0)
class Content {
  @HiveField(0)
  final String title;

  @HiveField(1)
  final DateTime datetime;

  @HiveField(2)
  final String content;

  Content({required this.title, required this.datetime, required this.content});

  factory Content.fromJson(Map<String, dynamic> json) => _$ContentFromJson(json);

  Map<String, dynamic> toJson() => _$ContentToJson(this);
}
