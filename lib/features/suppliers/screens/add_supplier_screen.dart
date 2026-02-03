import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/constants/app_colors.dart';
import '../models/supplier_model.dart';
import '../controllers/supplier_controller.dart';

class AddSupplierScreen extends StatefulWidget {
  const AddSupplierScreen({super.key});

  @override
  State<AddSupplierScreen> createState() => _AddSupplierScreenState();
}

class _AddSupplierScreenState extends State<AddSupplierScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _categoryController = TextEditingController();

  final controller = Get.find<SupplierController>();
  SupplierModel? _editingSupplier;

  @override
  void initState() {
    super.initState();
    if (Get.arguments is SupplierModel) {
      _editingSupplier = Get.arguments as SupplierModel;
      _nameController.text = _editingSupplier!.name;
      _phoneController.text = _editingSupplier!.phone;
      _addressController.text = _editingSupplier!.address;
      _categoryController.text = _editingSupplier!.category;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _categoryController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      final supplier = SupplierModel(
        id: _editingSupplier?.id,
        name: _nameController.text.trim(),
        phone: _phoneController.text.trim(),
        address: _addressController.text.trim(),
        category: _categoryController.text.trim(),
        isActive: _editingSupplier?.isActive ?? true,
      );

      if (_editingSupplier == null) {
        controller.createSupplier(supplier);
      } else {
        controller.updateSupplier(_editingSupplier!.id!, supplier);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = _editingSupplier != null;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Supplier' : 'Add Supplier'),
        backgroundColor: AppColors.secondary,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Supplier Name *'),
                validator: (v) => v!.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _phoneController,
                decoration: const InputDecoration(labelText: 'Phone'),
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _addressController,
                decoration: const InputDecoration(labelText: 'Address'),
                maxLines: 2,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _categoryController,
                decoration: const InputDecoration(labelText: 'Category *'),
                validator: (v) => v!.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 32),
              Obx(
                () => ElevatedButton(
                  onPressed: controller.isLoading.value ? null : _submit,
                  child: controller.isLoading.value
                      ? const CircularProgressIndicator(color: Colors.white)
                      : Text(isEditing ? 'Save Changes' : 'Create Supplier'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
