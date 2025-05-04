class UserModel {
  String? id;
  String? name;
  String? email;
  String? avatar;

  UserModel({
    this.id,
    this.name,
    this.email,
    this.avatar,
  });

  // Factory constructor để tạo `UserModel` từ JSON
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String?,
      name: json['name'] as String?,
      email: json['email'] as String?,
      avatar: json['avatar'] as String?,
    );
  }

  // Phương thức chuyển đổi `UserModel` thành JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'avatar': avatar,
    };
  }
}
