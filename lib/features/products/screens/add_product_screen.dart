import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/constants/app_colors.dart';
import '../../materials/models/material_model.dart';
import '../../materials/services/material_service.dart';
import '../models/product_model.dart';
import '../controllers/product_controller.dart';

class AddProductScreen extends StatefulWidget {
  const AddProductScreen({super.key});

  @override
  State<AddProductScreen> createState() => _AddProductScreenState();
}

class _AddProductScreenState extends State<AddProductScreen> {
  final _formKey = GlobalKey<FormState>();

  // GetX Controller
  final controller = Get.find<ProductController>();

  // State
  List<MaterialModel> _materials = [];
  MaterialModel? _selectedMaterial;

  // Controllers
  final TextEditingController _retailPriceController = TextEditingController();
  final TextEditingController _wholesalePriceController =
      TextEditingController();
  final TextEditingController _stockController =
      TextEditingController(); // Only for creation

  // Dynamic Form State
  final Map<String, dynamic> _attributeValues = {};
  ProductModel? _editingProduct;

  @override
  void initState() {
    super.initState();
    _loadMaterials();

    if (Get.arguments is ProductModel) {
      _editingProduct = Get.arguments as ProductModel;
      _retailPriceController.text = _editingProduct!.retailPrice.toString();
      _wholesalePriceController.text = _editingProduct!.wholesalePrice
          .toString();
      _attributeValues.addAll(_editingProduct!.attributes);
    }
  }

  Future<void> _loadMaterials() async {
    try {
      final list = await MaterialService().getMaterials();
      setState(() {
        _materials = list;

        if (_editingProduct != null) {
          try {
            String matId = '';
            if (_editingProduct!.materialId is Map) {
              matId = _editingProduct!.materialId['_id'];
            } else if (_editingProduct!.materialId is String) {
              matId = _editingProduct!.materialId;
            }

            if (matId.isNotEmpty) {
              _selectedMaterial = _materials.firstWhere((m) => m.id == matId);
            }
          } catch (_) {
            // Material might have been deleted
          }
        }
      });
    } catch (e) {
      Get.snackbar('Error', 'Failed to load materials');
    }
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      if (_selectedMaterial == null) {
        Get.snackbar('Required', 'Please select a material');
        return;
      }

      // Collect attributes
      final Map<String, dynamic> finalAttributes = {};
      for (var attr in _selectedMaterial!.attributes) {
        final val = _attributeValues[attr.key];
        if (val != null) {
          finalAttributes[attr.key] = val;
        }
      }

      final product = ProductModel(
        id: _editingProduct?.id,
        materialId: _selectedMaterial!.id,
        retailPrice: double.tryParse(_retailPriceController.text) ?? 0,
        wholesalePrice: double.tryParse(_wholesalePriceController.text) ?? 0,
        attributes: finalAttributes,
        isActive: true,
      );

      if (_editingProduct == null) {
        int? stock;
        if (_stockController.text.isNotEmpty) {
          stock = int.tryParse(_stockController.text);
        }
        controller.createProduct(product, initialStock: stock);
      } else {
        controller.updateProduct(_editingProduct!.id!, product);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = _editingProduct != null;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Product' : 'Add Product'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Material Selection
              Text('Material', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              DropdownButtonFormField<MaterialModel>(
                value: _selectedMaterial,
                decoration: const InputDecoration(
                  hintText: 'Select Material Source',
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 12,
                  ),
                ),
                items: _materials.map((m) {
                  return DropdownMenuItem(value: m, child: Text(m.name));
                }).toList(),
                onChanged: isEditing
                    ? null
                    : (val) {
                        setState(() {
                          _selectedMaterial = val;
                          _attributeValues.clear();
                        });
                      },
                validator: (val) => val == null ? 'Required' : null,
              ),

              const SizedBox(height: 24),

              // Dynamic Attributes
              if (_selectedMaterial != null) ...[
                Text(
                  'Attributes',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: Column(
                    children: _selectedMaterial!.attributes.map((attr) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 16.0),
                        child: _buildDynamicField(attr),
                      );
                    }).toList(),
                  ),
                ),
                const SizedBox(height: 24),
              ],

              // Pricing & Stock
              Text(
                'Pricing & Stock',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _retailPriceController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Retail Price',
                      ),
                      validator: (v) => v!.isEmpty ? 'Required' : null,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextFormField(
                      controller: _wholesalePriceController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Wholesale Price',
                      ),
                      validator: (v) => v!.isEmpty ? 'Required' : null,
                    ),
                  ),
                ],
              ),
              if (!isEditing) ...[
                const SizedBox(height: 16),
                TextFormField(
                  controller: _stockController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Initial Stock (Opening Qty)',
                  ),
                ),
              ],

              const SizedBox(height: 32),
              Obx(
                () => ElevatedButton(
                  onPressed: controller.isLoading.value ? null : _submit,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                  ),
                  child: controller.isLoading.value
                      ? const CircularProgressIndicator(color: Colors.white)
                      : Text(isEditing ? 'Update Product' : 'Create Product'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDynamicField(AttributeModel attr) {
    if (attr.type == 'select') {
      return DropdownButtonFormField<String>(
        value: _attributeValues[attr.key]?.toString(),
        decoration: InputDecoration(
          labelText: attr.label,
          border: const OutlineInputBorder(),
        ),
        items: attr.options.map((opt) {
          return DropdownMenuItem(value: opt, child: Text(opt));
        }).toList(),
        onChanged: (val) {
          setState(() => _attributeValues[attr.key] = val);
        },
        validator: (val) => (attr.required && val == null) ? 'Required' : null,
      );
    }

    return TextFormField(
      initialValue: _attributeValues[attr.key]?.toString(),
      decoration: InputDecoration(
        labelText: attr.label,
        border: const OutlineInputBorder(),
      ),
      keyboardType: attr.type == 'number'
          ? TextInputType.number
          : TextInputType.text,
      onChanged: (val) {
        _attributeValues[attr.key] = val;
      },
      validator: (val) {
        if (attr.required && (val == null || val.isEmpty)) return 'Required';
        return null;
      },
    );
  }
}
