class SaleItemModel {
  final String productId;
  final String? productName; // Optional for UI display if needed
  final String? sku;
  final double qty;
  final double price;
  final double lineTotal;

  SaleItemModel({
    required this.productId,
    this.productName,
    this.sku,
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
    String pId = '';
    String? pName;

    // Check if productId is populated
    if (json['productId'] is Map) {
      pId = json['productId']['_id']?.toString() ?? '';
      pName = json['productId']['name']?.toString();
    } else {
      pId = json['productId']?.toString() ?? '';
    }

    // Fallback: Check for productSnapshot (common in invoices for frozen data)
    // Or sometimes just 'name' if flatten
    if (pName == null && json['productSnapshot'] != null) {
      pName = json['productSnapshot']['name'];
    }
    // Fallback: Check top-level 'name' if backend structure differs
    if (pName == null && json['name'] != null) {
      pName = json['name'];
    }

    return SaleItemModel(
      productId: pId,
      productName: pName, // Can be null, will default to 'Product' in UI
      qty: (json['qty'] as num?)?.toDouble() ?? 0.0,
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      lineTotal: (json['lineTotal'] as num?)?.toDouble() ?? 0.0,
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
      customerName:
          json['customerName'] ??
          (json['customerSnapshot'] != null
              ? json['customerSnapshot']['name']
              : null),
      saleType: json['saleType'] ?? 'retail',
      items:
          (json['items'] as List?)
              ?.map((e) => SaleItemModel.fromJson(e))
              .toList() ??
          [],
      subTotal: (json['subTotal'] as num?)?.toDouble() ?? 0.0,
      discount: (json['discount'] as num?)?.toDouble() ?? 0.0,
      grandTotal: (json['grandTotal'] as num?)?.toDouble() ?? 0.0,
      paymentMethod: json['paymentMethod'] ?? 'cash',
      paidAmount: (json['paidAmount'] as num?)?.toDouble() ?? 0.0,
      dueAmount: (json['dueAmount'] as num?)?.toDouble() ?? 0.0,
      note: json['note'],
      invoiceNo: json['invoiceNo'],
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'])
          : null,
    );
  }
}
