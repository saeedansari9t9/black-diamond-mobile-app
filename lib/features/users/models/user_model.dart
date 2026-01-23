class UserModel {
  String? id;
  String name;
  String email;
  String role;
  bool isActive;
  DateTime? createdAt;

  UserModel({
    this.id,
    required this.name,
    required this.email,
    required this.role,
    this.isActive = true,
    this.createdAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['_id'],
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      role: json['role'] ?? 'sales',
      isActive: json['isActive'] ?? true,
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) '_id': id,
      'name': name,
      'email': email,
      'role': role,
      'isActive': isActive,
    };
  }
}
