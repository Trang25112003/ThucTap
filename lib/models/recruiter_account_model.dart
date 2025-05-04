class RecruiterAccount {
  final String id;
  final String? name;
  final String email;
  final String? avatar;
  final bool isApproved;
  final bool isActive;

  RecruiterAccount({
    required this.id,
    required this.email,
    this.name,
    this.avatar,
    required this.isApproved,
    required this.isActive,
  });

  factory RecruiterAccount.fromMap(Map<String, dynamic> map) {
    final bool isBlocked = map['is_blocked'] as bool? ?? false;

    return RecruiterAccount(
      id: map['id'] as String? ?? '',
      email: map['email'] as String? ?? '',
      name: map['name'] as String?,
      avatar: map['avatar'] as String?,
      isApproved: map['is_approved'] as bool? ?? false,
      isActive: !isBlocked, // true nếu chưa bị block
    );
  }
}
