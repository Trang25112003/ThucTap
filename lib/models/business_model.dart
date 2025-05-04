import 'package:json_annotation/json_annotation.dart';
import 'account_model.dart'; 

part 'business_model.g.dart';

@JsonSerializable(explicitToJson: true)
class Business {
  final String? id;
  final String? name;
  final String? avatar;

  @JsonKey(name: 'account_id')
  final String? accountId;
@JsonKey(name: 'account')
final Account? account;
  
  @JsonKey(name: 'is_active') // Giả sử là trường is_active từ DB
  final bool isActive;
  Business({
    this.id,
    this.name,
    this.avatar,
    this.accountId,
    this.account,
    this.isActive = false,
  });

  factory Business.fromJson(Map<String, dynamic> json) =>
      _$BusinessFromJson(json);

  Map<String, dynamic> toJson() => _$BusinessToJson(this);
}
