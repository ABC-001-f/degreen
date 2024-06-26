// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'settings_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Settings _$SettingsFromJson(Map<String, dynamic> json) => Settings(
      dark: json['dark'] as bool,
      fast: json['fast'] as bool,
      language: json['language'] as String,
    );

Map<String, dynamic> _$SettingsToJson(Settings instance) => <String, dynamic>{
      'dark': instance.dark,
      'fast': instance.fast,
      'language': instance.language,
    };
