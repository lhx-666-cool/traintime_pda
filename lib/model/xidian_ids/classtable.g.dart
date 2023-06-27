// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'classtable.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ClassDetail _$ClassDetailFromJson(Map<String, dynamic> json) => ClassDetail(
      name: json['name'] as String,
      teacher: json['teacher'] as String?,
      code: json['code'] as String?,
      number: json['number'] as String?,
    );

Map<String, dynamic> _$ClassDetailToJson(ClassDetail instance) =>
    <String, dynamic>{
      'name': instance.name,
      'teacher': instance.teacher,
      'code': instance.code,
      'number': instance.number,
    };

TimeArrangement _$TimeArrangementFromJson(Map<String, dynamic> json) =>
    TimeArrangement(
      index: json['index'] as int,
      weekList: json['week_list'] as String,
      classroom: json['classroom'] as String?,
      day: json['day'] as int,
      start: json['start'] as int,
      stop: json['stop'] as int,
    );

Map<String, dynamic> _$TimeArrangementToJson(TimeArrangement instance) {
  final val = <String, dynamic>{
    'index': instance.index,
    'week_list': instance.weekList,
    'day': instance.day,
    'start': instance.start,
    'stop': instance.stop,
  };

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('classroom', instance.classroom);
  return val;
}

ClassTableData _$ClassTableDataFromJson(Map<String, dynamic> json) =>
    ClassTableData(
      semesterLength: json['semesterLength'] as int? ?? 1,
      semesterCode: json['semesterCode'] as String? ?? "",
      termStartDay: json['termStartDay'] as String? ?? "",
      classDetail: (json['classDetail'] as List<dynamic>?)
          ?.map((e) => ClassDetail.fromJson(e as Map<String, dynamic>))
          .toList(),
      notArranged: (json['notArranged'] as List<dynamic>?)
          ?.map((e) => ClassDetail.fromJson(e as Map<String, dynamic>))
          .toList(),
      timeArrangement: (json['timeArrangement'] as List<dynamic>?)
          ?.map((e) => TimeArrangement.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$ClassTableDataToJson(ClassTableData instance) =>
    <String, dynamic>{
      'semesterLength': instance.semesterLength,
      'semesterCode': instance.semesterCode,
      'termStartDay': instance.termStartDay,
      'classDetail': instance.classDetail.map((e) => e.toJson()).toList(),
      'notArranged': instance.notArranged.map((e) => e.toJson()).toList(),
      'timeArrangement':
          instance.timeArrangement.map((e) => e.toJson()).toList(),
    };
