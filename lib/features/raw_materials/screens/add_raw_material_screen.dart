import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/constants/app_colors.dart';
import '../models/raw_material_model.dart';
import '../controllers/raw_material_controller.dart';

class AddRawMaterialScreen extends StatefulWidget {
  const AddRawMaterialScreen({super.key});

  @override
  State<AddRawMaterialScreen> createState() => _AddRawMaterialScreenState();
}

class _AddRawMaterialScreenState extends State<AddRawMaterialScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late List<AttributeModel> _attributes;
  RawMaterialModel? _editingMaterial;

  final controller = Get.find<RawMaterialController>();

  @override
  void initState() {
    super.initState();
    // Get arguments from Get.toNamed
    if (Get.arguments is RawMaterialModel) {
      _editingMaterial = Get.arguments as RawMaterialModel;
    }

    _nameController = TextEditingController(text: _editingMaterial?.name ?? '');

    // Deep copy attributes
    if (_editingMaterial != null) {
      _attributes = _editingMaterial!.attributes
          .map(
            (e) => AttributeModel(
              key: e.key,
              label: e.label,
              type: e.type,
              required: e.required,
              options: List<String>.from(e.options),
            ),
          )
          .toList();
    } else {
      _attributes = [];
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _addAttribute() {
    setState(() {
      _attributes.add(AttributeModel(key: '', label: ''));
    });
  }

  void _removeAttribute(int index) {
    setState(() {
      _attributes.removeAt(index);
    });
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      // Auto-generate keys
      for (var attr in _attributes) {
        if (attr.key.isEmpty) {
          attr.key = attr.label.toLowerCase().replaceAll(' ', '_');
        }
      }

      final material = RawMaterialModel(
        id: _editingMaterial?.id,
        name: _nameController.text,
        attributes: _attributes,
        isActive: _editingMaterial?.isActive ?? true,
      );

      if (_editingMaterial == null) {
        controller.createRawMaterial(material);
      } else {
        controller.updateRawMaterial(_editingMaterial!.id!, material);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = _editingMaterial != null;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Raw Material' : 'Add Raw Material'),
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
              // Basic Info
              const Text(
                'Basic Information',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Raw Material Name (e.g. Cotton)',
                ),
                validator: (v) => v!.isEmpty ? 'Required' : null,
              ),

              const SizedBox(height: 24),

              // Attributes Section
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Attributes',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  TextButton.icon(
                    onPressed: _addAttribute,
                    icon: const Icon(Icons.add),
                    label: const Text('Add Attribute'),
                  ),
                ],
              ),

              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _attributes.length,
                separatorBuilder: (_, __) => const SizedBox(height: 16),
                itemBuilder: (context, index) {
                  final attr = _attributes[index];

                  return Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                initialValue: attr.label,
                                decoration: const InputDecoration(
                                  labelText: 'Label',
                                ),
                                onChanged: (v) => attr.label = v,
                                validator: (v) =>
                                    v!.isEmpty ? 'Required' : null,
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () => _removeAttribute(index),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Expanded(
                              child: DropdownButtonFormField<String>(
                                value: attr.type,
                                decoration: const InputDecoration(
                                  labelText: 'Type',
                                ),
                                items: const [
                                  DropdownMenuItem(
                                    value: 'text',
                                    child: Text('Text'),
                                  ),
                                  DropdownMenuItem(
                                    value: 'number',
                                    child: Text('Number'),
                                  ),
                                  DropdownMenuItem(
                                    value: 'select',
                                    child: Text('Select'),
                                  ),
                                ],
                                onChanged: (v) =>
                                    setState(() => attr.type = v!),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: CheckboxListTile(
                                title: const Text('Required'),
                                value: attr.required,
                                onChanged: (v) =>
                                    setState(() => attr.required = v!),
                                contentPadding: EdgeInsets.zero,
                                controlAffinity:
                                    ListTileControlAffinity.leading,
                              ),
                            ),
                          ],
                        ),
                        if (attr.type == 'select')
                          Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: TextFormField(
                              initialValue: attr.options.join(','),
                              decoration: const InputDecoration(
                                labelText: 'Options (comma separated)',
                                hintText: 'Option 1, Option 2',
                              ),
                              onChanged: (v) {
                                attr.options = v
                                    .split(',')
                                    .map((e) => e.trim())
                                    .where((e) => e.isNotEmpty)
                                    .toList();
                              },
                            ),
                          ),
                      ],
                    ),
                  );
                },
              ),

              const SizedBox(height: 32),

              Obx(
                () => ElevatedButton(
                  onPressed: controller.isLoading.value ? null : _submit,
                  child: controller.isLoading.value
                      ? const CircularProgressIndicator(color: Colors.white)
                      : Text(
                          isEditing ? 'Save Changes' : 'Create Raw Material',
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
