class CustomerModel {
  final String? id; // _id
  final String name;
  final String? phone;
  final String? address;
  final String? notes;
  final bool isActive;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  CustomerModel({
    this.id,
    required this.name,
    this.phone,
    this.address,
    this.notes,
    this.isActive = true,
    this.createdAt,
    this.updatedAt,
  });

  factory CustomerModel.fromJson(Map<String, dynamic> json) {
    return CustomerModel(
      id: json['_id'],
      name: json['name'],
      phone: json['phone'],
      address: json['address'],
      notes: json['notes'],
      isActive: json['isActive'] ?? true,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) '_id': id,
      'name': name,
      'phone': phone ?? '',
      'address': address ?? '',
      'notes': notes ?? '',
      'isActive': isActive,
    };
  }
}
