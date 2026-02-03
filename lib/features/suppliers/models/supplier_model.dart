class SupplierModel {
  String? id;
  String name;
  String phone;
  String address;
  String category;
  double walletBalance;
  bool isActive;

  SupplierModel({
    this.id,
    required this.name,
    this.phone = '',
    this.address = '',
    required this.category,
    this.walletBalance = 0.0,
    this.isActive = true,
  });

  factory SupplierModel.fromJson(Map<String, dynamic> json) {
    return SupplierModel(
      id: json['_id'],
      name: json['name'] ?? '',
      phone: json['phone'] ?? '',
      address: json['address'] ?? '',
      category: json['category'] ?? '',
      walletBalance: (json['walletBalance'] ?? 0).toDouble(),
      isActive: json['isActive'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) '_id': id,
      'name': name,
      'phone': phone,
      'address': address,
      'category': category,
      'walletBalance': walletBalance,
      'isActive': isActive,
    };
  }
}
