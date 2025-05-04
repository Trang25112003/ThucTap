import 'package:json_annotation/json_annotation.dart';
import 'business_model.dart';

part 'job_model.g.dart';

@JsonSerializable(explicitToJson: true)
class Job {
  final String? id;

  @JsonKey(name: 'business_id')
  final String? business_id;

  final String? position;
  final String? levels;
  final int? salary;
  final String? content;
  final String? skills;
  final String? types;
  final String? requirement;
  final int? quantity;
  final String? benefit;
  final String? startDay;
  final String? endDay;
  final int? view_count;
  final bool? isApprove;
  final bool? isHidden;
  final String? createAt;
  final String? status;
  final List<String>? tags;
  final String? city;

  @JsonKey(name: 'created_at')
  final DateTime? createdAt;
@JsonKey(name: 'business')
final Business? business;


  /// Trường này dùng để đánh dấu job đã được yêu thích hay chưa
  /// Không nên map vào JSON backend, chỉ dùng nội bộ
  @JsonKey(ignore: true)
  bool isFavorite;

  Job({
    this.id,
    this.business_id,
    this.position,
    this.levels,
    this.salary,
    this.content,
    this.skills,
    this.types,
    this.requirement,
    this.quantity,
    this.benefit,
    this.startDay,
    this.endDay,
    this.view_count,
    this.isApprove,
    this.isHidden,
    this.createAt,
    this.createdAt,
    this.business,
    this.status,
    this.tags,
    this.city,
    this.isFavorite = false,
  });

  factory Job.fromJson(Map<String, dynamic> json) => _$JobFromJson(json);

  Map<String, dynamic> toJson() => _$JobToJson(this);

  String? get avatar => business?.avatar;
  String? get name => business?.name;
  String? get posterName => business?.account?.name;
String? get posterAvatar => business?.account?.avatar;
String get safePosition => position ?? 'Vị trí chưa được cung cấp';


}
