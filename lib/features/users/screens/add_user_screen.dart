import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/constants/app_colors.dart';
import '../models/user_model.dart';
import '../controllers/user_controller.dart';

class AddUserScreen extends StatefulWidget {
  const AddUserScreen({super.key});

  @override
  State<AddUserScreen> createState() => _AddUserScreenState();
}

class _AddUserScreenState extends State<AddUserScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  String _role = 'sales';

  final controller = Get.find<UserController>();

  final List<String> _roles = [
    'admin',
    'manager',
    'accountant',
    'sales',
    'inventory',
  ];

  void _submit() {
    if (_formKey.currentState!.validate()) {
      final user = UserModel(
        name: _nameController.text,
        email: _emailController.text,
        role: _role,
        isActive: true,
      );

      controller.createUser(user, _passwordController.text);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Add User'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Name'),
                validator: (v) => v!.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(labelText: 'Email'),
                keyboardType: TextInputType.emailAddress,
                validator: (v) => v!.contains('@') ? null : 'Invalid email',
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _passwordController,
                decoration: const InputDecoration(labelText: 'Password'),
                obscureText: true,
                validator: (v) => v!.length < 6 ? 'Min 6 chars' : null,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _role,
                decoration: const InputDecoration(labelText: 'Role'),
                items: _roles
                    .map(
                      (r) => DropdownMenuItem(
                        value: r,
                        child: Text(r.toUpperCase()),
                      ),
                    )
                    .toList(),
                onChanged: (v) => setState(() => _role = v!),
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: Obx(
                  () => ElevatedButton(
                    onPressed: controller.isLoading.value ? null : _submit,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                    ),
                    child: controller.isLoading.value
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text('Create User'),
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
