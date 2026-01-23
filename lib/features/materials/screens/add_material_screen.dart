import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/constants/app_colors.dart';
import '../models/material_model.dart';
import '../controllers/material_controller.dart';

class AddMaterialScreen extends StatefulWidget {
  const AddMaterialScreen({super.key});

  @override
  State<AddMaterialScreen> createState() => _AddMaterialScreenState();
}

class _AddMaterialScreenState extends State<AddMaterialScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late List<AttributeModel> _attributes;
  MaterialModel? _editingMaterial;

  final controller = Get.find<MaterialController>();

  @override
  void initState() {
    super.initState();
    // Get arguments from Get.toNamed
    if (Get.arguments is MaterialModel) {
      _editingMaterial = Get.arguments as MaterialModel;
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

    _ensureDefaultAttributes();
  }

  void _ensureDefaultAttributes() {
    // Enforce default required field "Product Name"
    final hasProdName = _attributes.any((a) => a.key == 'prodName');
    if (!hasProdName) {
      _attributes.insert(
        0,
        AttributeModel(
          key: 'prodName',
          label: 'Product Name',
          type: 'text',
          required: true,
        ),
      );
    }

    // Ensure at least one open editable attribute exists for new entries
    if (_attributes.length == 1 && _attributes[0].key == 'prodName') {
      _attributes.add(AttributeModel(key: '', label: ''));
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

      final material = MaterialModel(
        id: _editingMaterial?.id,
        name: _nameController.text,
        attributes: _attributes,
        isActive: _editingMaterial?.isActive ?? true,
      );

      if (_editingMaterial == null) {
        controller.createMaterial(material);
      } else {
        controller.updateMaterial(_editingMaterial!.id!, material);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = _editingMaterial != null;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Material' : 'Add Material'),
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
              // Basic Info
              const Text(
                'Basic Information',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Material Name (e.g. Cotton)',
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
                  final isDefault = attr.key == 'prodName';

                  return Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isDefault ? Colors.grey.shade50 : Colors.white,
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
                                readOnly: isDefault,
                                enabled: !isDefault,
                              ),
                            ),
                            IconButton(
                              icon: Icon(
                                Icons.delete,
                                color: isDefault ? Colors.grey : Colors.red,
                              ),
                              onPressed: isDefault
                                  ? null
                                  : () => _removeAttribute(index),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Expanded(
                              child: IgnorePointer(
                                ignoring: isDefault,
                                child: DropdownButtonFormField<String>(
                                  value: attr.type,
                                  decoration: InputDecoration(
                                    labelText: 'Type',
                                    enabled: !isDefault,
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
                                  onChanged: isDefault
                                      ? null
                                      : (v) => setState(() => attr.type = v!),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: IgnorePointer(
                                ignoring: isDefault,
                                child: CheckboxListTile(
                                  title: const Text('Required'),
                                  value: attr.required,
                                  onChanged: isDefault
                                      ? null
                                      : (v) =>
                                            setState(() => attr.required = v!),
                                  contentPadding: EdgeInsets.zero,
                                  controlAffinity:
                                      ListTileControlAffinity.leading,
                                ),
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
                      : Text(isEditing ? 'Save Changes' : 'Create Material'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
