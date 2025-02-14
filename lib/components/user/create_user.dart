import 'package:bcrypt/bcrypt.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class CreateUserDialog extends StatefulWidget {
  final VoidCallback onUserAdded;

  const CreateUserDialog({super.key, required this.onUserAdded});

  @override
  State<CreateUserDialog> createState() => _CreateUserDialogState();
}

class _CreateUserDialogState extends State<CreateUserDialog> {
  final supabase = Supabase.instance.client;
  final _formKey = GlobalKey<FormState>();
  final usernameUserController = TextEditingController();
  final emailUserController = TextEditingController();
  final passwordUserController = TextEditingController();
  String? selectedRole;

  Future _insertUser() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final username = usernameUserController.text;
    final email = emailUserController.text;
    final password = passwordUserController.text;
    final role = selectedRole;

    final hashedPassword = BCrypt.hashpw(password, BCrypt.gensalt());

    final response = await supabase.from('users').insert({
      'username': username,
      'email': email,
      'password': hashedPassword,
      'role': role,
      'plain_password': password,
    });

    if (response != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Gagal menambahkan pengguna")),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Pengguna berhasil ditambahkan")),
      );
      usernameUserController.clear();
      emailUserController.clear();
      passwordUserController.clear();
      setState(() {
        selectedRole = null;
      });

      widget.onUserAdded();
      Navigator.pop(context, true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: AlertDialog(
        title: Text("Tambah Pengguna"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildTextField(usernameUserController, "Nama Pengguna"),
            SizedBox(height: 10),
            _buildTextField(emailUserController, "Email"),
            SizedBox(height: 10),
            _buildTextField(passwordUserController, "Password"),
            SizedBox(height: 10),
            DropdownButtonFormField<String>(
              value: selectedRole,
              decoration: InputDecoration(
                labelText: "Role",
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              ),
              items: ["Admin", "Petugas"].map((role) {
                return DropdownMenuItem(
                  value: role,
                  child: Text(role),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  selectedRole = value;
                });
              },
              validator: (value) => value == null ? "Role harus dipilih" : null,
            ),
            SizedBox(height: 10),
          ],
        ),
        actions: [
          TextButton(
            child: Text("Batal"),
            onPressed: () => Navigator.of(context).pop(),
          ),
          TextButton(
            onPressed: _insertUser,
            child: Text("Tambah"),
          ),
        ],
      ),
    );
  }
}

Widget _buildTextField(TextEditingController controller, String label) {
  return TextFormField(
    controller: controller,
    decoration: InputDecoration(
      labelText: label,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
    ),
    validator: (value) => value == null || value.trim().isEmpty ? "$label tidak boleh kosong" : null,
  );
}
