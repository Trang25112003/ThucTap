// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'job_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Job _$JobFromJson(Map<String, dynamic> json) => Job(
      id: json['id'] as String?,
      business_id: json['business_id'] as String?,
      position: json['position'] as String?,
      levels: json['levels'] as String?,
      salary: (json['salary'] as num?)?.toInt(),
      content: json['content'] as String?,
      skills: json['skills'] as String?,
      types: json['types'] as String?,
      requirement: json['requirement'] as String?,
      quantity: (json['quantity'] as num?)?.toInt(),
      benefit: json['benefit'] as String?,
      startDay: json['startDay'] as String?,
      endDay: json['endDay'] as String?,
      view_count: (json['view_count'] as num?)?.toInt(),
      isApprove: json['isApprove'] as bool?,
      isHidden: json['isHidden'] as bool?,
      createAt: json['createAt'] as String?,
      createdAt: json['created_at'] == null
          ? null
          : DateTime.parse(json['created_at'] as String),
      business: json['business'] == null
          ? null
          : Business.fromJson(json['business'] as Map<String, dynamic>),
      status: json['status'] as String?,
      tags: (json['tags'] as List<dynamic>?)?.map((e) => e as String).toList(),
      city: json['city'] as String?,
    );

Map<String, dynamic> _$JobToJson(Job instance) => <String, dynamic>{
      'id': instance.id,
      'business_id': instance.business_id,
      'position': instance.position,
      'levels': instance.levels,
      'salary': instance.salary,
      'content': instance.content,
      'skills': instance.skills,
      'types': instance.types,
      'requirement': instance.requirement,
      'quantity': instance.quantity,
      'benefit': instance.benefit,
      'startDay': instance.startDay,
      'endDay': instance.endDay,
      'view_count': instance.view_count,
      'isApprove': instance.isApprove,
      'isHidden': instance.isHidden,
      'createAt': instance.createAt,
      'status': instance.status,
      'tags': instance.tags,
      'city': instance.city,
      'created_at': instance.createdAt?.toIso8601String(),
      'business': instance.business?.toJson(),
    };
