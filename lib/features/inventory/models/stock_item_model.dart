class StockItemModel {
  final String materialId;
  final String materialName;
  final String? size;
  final String? qualityType;
  final String? sku;
  final double retailPrice;
  final double wholesalePrice;
  final double stock;
  final Map<String, dynamic>? attributes;

  StockItemModel({
    required this.materialId,
    required this.materialName,
    this.size,
    this.qualityType,
    this.sku,
    this.retailPrice = 0.0,
    this.wholesalePrice = 0.0,
    this.stock = 0.0,
    this.attributes,
  });

  factory StockItemModel.fromJson(Map<String, dynamic> json) {
    return StockItemModel(
      materialId: json['materialId'] ?? '',
      materialName: json['materialName'] ?? 'Unknown',
      size: json['size'],
      qualityType: json['qualityType'],
      sku: json['sku'],
      retailPrice: (json['retailPrice'] as num?)?.toDouble() ?? 0.0,
      wholesalePrice: (json['wholesalePrice'] as num?)?.toDouble() ?? 0.0,
      stock: (json['stock'] as num?)?.toDouble() ?? 0.0,
      attributes: json['attributes'],
    );
  }
}
