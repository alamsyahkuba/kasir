import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class UpdateUserDialog extends StatefulWidget {
  final Map<String, dynamic> user;
  final VoidCallback onUserUpdated;

  const UpdateUserDialog(
      {super.key, required this.user, required this.onUserUpdated});

  @override
  State<UpdateUserDialog> createState() => _UpdateUserDialogState();
}

class _UpdateUserDialogState extends State<UpdateUserDialog> {
  final supabase = Supabase.instance.client;
  final _formKey = GlobalKey<FormState>();
  late TextEditingController usernameUserController;
  late TextEditingController emailUserController;
  String? selectedRole;

  @override
  void initState() {
    super.initState();
    usernameUserController =
        TextEditingController(text: widget.user['username']);
    emailUserController =
        TextEditingController(text: widget.user['email'].toString());
    selectedRole = widget.user['role'];
  }

  Future _updateUser() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final username = usernameUserController.text;
    final email = emailUserController.text;

    final response = await supabase
        .from('users')
        .update({'username': username, 'email': email, 'role': selectedRole})
        .eq('id', widget.user['id'])
        .select()
        .maybeSingle();

    if (response == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Gagal memperbarui pengguna")),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Pengguna berhasil diperbarui")),
      );
      widget.onUserUpdated();
      Navigator.pop(context, true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: AlertDialog(
        title: Text("Edit Pengguna"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildTextField(usernameUserController, "Nama Pengguna"),
            SizedBox(height: 10),
            _buildTextField(emailUserController, "Email"),
            SizedBox(height: 10),
            DropdownButtonFormField<String>(
              value: selectedRole,
              decoration: InputDecoration(
                labelText: "Role",
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              ),
              items: ["Admin", "Petugas"].map((role) {
                return DropdownMenuItem(value: role, child: Text(role));
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
            onPressed: () => Navigator.of(context).pop(),
            child: Text("Batal"),
          ),
          TextButton(
            onPressed: _updateUser,
            child: Text("Simpan"),
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
    validator: (value) => value!.isEmpty ? "$label tidak boleh kosong" : null,
  );
}
