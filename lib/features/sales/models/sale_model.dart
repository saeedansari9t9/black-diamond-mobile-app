class SaleItemModel {
  final String productId;
  final String? productName; // Optional for UI display if needed
  final double qty;
  final double price;
  final double lineTotal;

  SaleItemModel({
    required this.productId,
    this.productName,
    required this.qty,
    required this.price,
    required this.lineTotal,
  });

  Map<String, dynamic> toJson() {
    return {
      'productId': productId,
      'qty': qty,
      'price': price,
      // lineTotal is calculated on backend too, but sending it is fine or optional depending on validation
    };
  }

  factory SaleItemModel.fromJson(Map<String, dynamic> json) {
    return SaleItemModel(
      productId: json['productId'] is Map
          ? json['productId']['_id']
          : json['productId'],
      productName: json['productId'] is Map
          ? json['productId']['name']
          : null, // If populated
      qty: (json['qty'] as num).toDouble(),
      price: (json['price'] as num).toDouble(),
      lineTotal: (json['lineTotal'] as num).toDouble(),
    );
  }
}

class SaleModel {
  final String? id;
  final String? customerId;
  final String? customerName;
  final String saleType;
  final List<SaleItemModel> items;
  final double subTotal;
  final double discount;
  final double grandTotal;
  final String paymentMethod;
  final double paidAmount;
  final double dueAmount;
  final String? note;
  final String? invoiceNo;
  final DateTime? createdAt;

  SaleModel({
    this.id,
    this.customerId,
    this.customerName,
    this.saleType = 'retail',
    required this.items,
    this.subTotal = 0,
    this.discount = 0,
    this.grandTotal = 0,
    this.paymentMethod = 'cash',
    this.paidAmount = 0,
    this.dueAmount = 0,
    this.note,
    this.invoiceNo,
    this.createdAt,
  });

  Map<String, dynamic> toJson() {
    return {
      if (customerId != null) 'customerId': customerId,
      if (customerName != null) 'customerName': customerName,
      'saleType': saleType,
      'items': items.map((e) => e.toJson()).toList(),
      'discount': discount,
      'paymentMethod': paymentMethod,
      'paidAmount': paidAmount,
      'note': note,
    };
  }

  factory SaleModel.fromJson(Map<String, dynamic> json) {
    return SaleModel(
      id: json['_id'],
      customerId: json['customerId'] is Map
          ? json['customerId']['_id']
          : json['customerId'],
      customerName: json['customerName'],
      saleType: json['saleType'] ?? 'retail',
      items: (json['items'] as List)
          .map((e) => SaleItemModel.fromJson(e))
          .toList(),
      subTotal: (json['subTotal'] as num).toDouble(),
      discount: (json['discount'] as num).toDouble(),
      grandTotal: (json['grandTotal'] as num).toDouble(),
      paymentMethod: json['paymentMethod'] ?? 'cash',
      paidAmount: (json['paidAmount'] as num).toDouble(),
      dueAmount: (json['dueAmount'] as num).toDouble(),
      note: json['note'],
      invoiceNo: json['invoiceNo'],
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : null,
    );
  }
}
