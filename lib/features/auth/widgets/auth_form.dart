import 'package:flutter/material.dart';

import '../../../core/utils/validators.dart';
import '../../../core/widgets/custom_button.dart';

class AuthForm extends StatefulWidget {
  const AuthForm({
    super.key,
    required this.onSubmit,
    this.showName = false,
    this.submitLabel = 'Continue',
    this.isLoading = false,
  });

  final Future<void> Function({required String email, required String password, String? name}) onSubmit;
  final bool showName;
  final String submitLabel;
  final bool isLoading;

  @override
  State<AuthForm> createState() => _AuthFormState();
}

class _AuthFormState extends State<AuthForm> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _nameCtrl = TextEditingController();

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    _nameCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    await widget.onSubmit(
      email: _emailCtrl.text.trim(),
      password: _passwordCtrl.text,
      name: widget.showName ? _nameCtrl.text.trim() : null,
    );
  }

  @override
  Widget build(BuildContext context) {
    _emailCtrl.text = 'donvovo2@gmail.com';
    _passwordCtrl.text = 'qwerty';
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (widget.showName) ...[
            TextFormField(
              controller: _nameCtrl,
              decoration: const InputDecoration(labelText: 'Display name'),
              validator: (v) => Validators.minLength(v, 2, fieldName: 'Name'),
            ),
            const SizedBox(height: 12),
          ],
          TextFormField(
            controller: _emailCtrl,
            decoration: const InputDecoration(labelText: 'Email'),
            keyboardType: TextInputType.emailAddress,
            validator: Validators.email,
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _passwordCtrl,
            decoration: const InputDecoration(labelText: 'Password'),
            obscureText: true,
            validator: (v) => Validators.minLength(v, 6, fieldName: 'Password'),
          ),
          const SizedBox(height: 16),
          CustomButton(
            label: widget.submitLabel,
            isLoading: widget.isLoading,
            onPressed: widget.isLoading ? null : _submit,
          ),
        ],
      ),
    );
  }
}


