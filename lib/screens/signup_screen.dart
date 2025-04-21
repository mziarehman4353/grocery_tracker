import """
package:flutter/material.dart"""
    show
        AppBar,
        BuildContext,
        DropdownButtonFormField,
        DropdownMenuItem,
        EdgeInsets,
        ElevatedButton,
        Form,
        FormState,
        GlobalKey,
        InputDecoration,
        ListView,
        Padding,
        Scaffold,
        ScaffoldMessenger,
        SizedBox,
        SnackBar,
        State,
        StatefulWidget,
        Text,
        TextEditingController,
        TextFormField,
        TextInputType,
        Widget;
// ignore: depend_on_referenced_packages
import "package:logger/logger.dart";

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _logger = Logger();

  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _groupCodeController = TextEditingController();

  String _selectedRole = 'Buyer';
  String _selectedCurrencyCode = 'USD';

  final List<String> _roles = ['Buyer', 'Viewer'];
  final List<String> _currencies = [
    'USD',
    'PKR',
    'IDR',
    'EUR',
    'INR',
  ]; // Add more as needed

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      // TODO: Send data to backend or Firebase

      _logger.i('Name: ${_nameController.text}');
      _logger.i('Email: ${_emailController.text}');
      _logger.i('Password: ${_passwordController.text}');
      _logger.i('Role: $_selectedRole');
      _logger.i('Group Code: ${_groupCodeController.text}');
      _logger.i('Currency: $_selectedCurrencyCode');

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("📝 Sign up info logged")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Sign Up")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Name'),
                validator: (value) => value!.isEmpty ? 'Required' : null,
              ),
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(labelText: 'Email'),
                keyboardType: TextInputType.emailAddress,
                validator: (value) => value!.isEmpty ? 'Required' : null,
              ),
              TextFormField(
                controller: _passwordController,
                decoration: const InputDecoration(labelText: 'Password'),
                obscureText: true,
                validator: (value) => value!.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _selectedRole,
                decoration: const InputDecoration(labelText: 'Role'),
                items:
                    _roles
                        .map(
                          (role) =>
                              DropdownMenuItem(value: role, child: Text(role)),
                        )
                        .toList(),
                onChanged: (value) => setState(() => _selectedRole = value!),
              ),
              if (_selectedRole == 'Viewer') ...[
                TextFormField(
                  controller: _groupCodeController,
                  decoration: const InputDecoration(
                    labelText: 'Enter Group Code',
                  ),
                  validator:
                      (value) =>
                          value!.isEmpty ? 'Group Code is required' : null,
                ),
              ],
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _selectedCurrencyCode,
                decoration: const InputDecoration(labelText: 'Currency'),
                items:
                    _currencies
                        .map(
                          (currency) => DropdownMenuItem(
                            value: currency,
                            child: Text(currency),
                          ),
                        )
                        .toList(),
                onChanged:
                    (value) => setState(() => _selectedCurrencyCode = value!),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _submitForm,
                child: const Text('Sign Up'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
