import '../../materials/models/material_model.dart';

class ProductModel {
  String? id;
  String? productId;
  String? sku;
  // keeping materialId flexible: usually a String ID, but can be populated object
  dynamic materialId;
  Map<String, dynamic> attributes;
  double retailPrice;
  double wholesalePrice;
  bool isActive;

  String get materialName {
    if (materialId is Map) {
      return materialId['name'] ?? 'Unknown';
    } else if (materialId is MaterialModel) {
      return (materialId as MaterialModel).name;
    }
    return 'Unknown Material';
  }

  String get name => attributes['prodName'] ?? sku ?? 'Unknown Product';

  ProductModel({
    this.id,
    this.productId,
    this.sku,
    required this.materialId,
    this.attributes = const {},
    this.retailPrice = 0.0,
    this.wholesalePrice = 0.0,
    this.isActive = true,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      id: json['_id'],
      productId: json['productId'],
      sku: json['sku'],
      materialId: json['materialId'],
      attributes: Map<String, dynamic>.from(json['attributes'] ?? {}),
      retailPrice: (json['retailPrice'] ?? 0).toDouble(),
      wholesalePrice: (json['wholesalePrice'] ?? 0).toDouble(),
      isActive: json['isActive'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) '_id': id,
      'materialId': materialId is String
          ? materialId
          : (materialId is Map
                ? materialId['_id']
                : (materialId is MaterialModel
                      ? (materialId as MaterialModel).id
                      : materialId)),
      'attributes': attributes,
      'retailPrice': retailPrice,
      'wholesalePrice': wholesalePrice,
      'isActive': isActive,
    };
  }
}
