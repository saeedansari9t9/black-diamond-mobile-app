class AttributeModel {
  String key;
  String label;
  String type; // "text", "select", "number"
  bool required;
  List<String> options;

  AttributeModel({
    required this.key,
    required this.label,
    this.type = "text",
    this.required = false,
    this.options = const [],
  });

  factory AttributeModel.fromJson(Map<String, dynamic> json) {
    return AttributeModel(
      key: json['key'] ?? '',
      label: json['label'] ?? '',
      type: json['type'] ?? 'text',
      required: json['required'] ?? false,
      options: List<String>.from(json['options'] ?? []),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'key': key,
      'label': label,
      'type': type,
      'required': required,
      'options': options,
    };
  }
}

class RawMaterialModel {
  String? id;
  String name;
  List<AttributeModel> attributes;
  bool isActive;

  RawMaterialModel({
    this.id,
    required this.name,
    this.attributes = const [],
    this.isActive = true,
  });

  factory RawMaterialModel.fromJson(Map<String, dynamic> json) {
    var rawAttrs = json['attributes'] as List? ?? [];
    List<AttributeModel> attrs = rawAttrs
        .map((i) => AttributeModel.fromJson(i as Map<String, dynamic>))
        .toList();

    return RawMaterialModel(
      id: json['_id'],
      name: json['name'] ?? '',
      attributes: attrs,
      isActive: json['isActive'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) '_id': id,
      'name': name,
      'attributes': attributes.map((e) => e.toJson()).toList(),
      'isActive': isActive,
    };
  }
}
