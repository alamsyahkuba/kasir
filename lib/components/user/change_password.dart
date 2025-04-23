import 'package:flutter/material.dart';
import 'package:bcrypt/bcrypt.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ChangePasswordDialog extends StatefulWidget {
  final Map<String, dynamic> user;
  const ChangePasswordDialog({super.key, required this.user});

  @override
  State<ChangePasswordDialog> createState() => _ChangePasswordDialogState();
}

class _ChangePasswordDialogState extends State<ChangePasswordDialog> {
  final supabase = Supabase.instance.client;
  final _formKey = GlobalKey<FormState>();
  final newPasswordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  Future _changePassword() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final newPassword = newPasswordController.text;

    String hashedPassword = BCrypt.hashpw(newPassword, BCrypt.gensalt());

    final response = await supabase.from('users').update({
      'password': hashedPassword, // password terenkripsi
      'plain_password': newPassword, // password plain
    }).eq('id', widget.user['id']);

    if (response != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Gagal mengubah password")),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Password berhasil diubah")),
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text("Ubah Password"),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildTextField(newPasswordController, "Password Baru",
                obscureText: true),
            SizedBox(height: 10),
            _buildTextField(confirmPasswordController, "Konfirmasi Password",
                obscureText: true),
          ],
        ),
      ),
      actions: [
        ElevatedButton(
          onPressed: () => Navigator.pop(context),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.grey,
            foregroundColor: Colors.black,
          ),
          child: Text("Batal"),
        ),
        TextButton(
          onPressed: _changePassword,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green,
            foregroundColor: Colors.white,
          ),
          child: Text("Simpan"),
        ),
      ],
    );
  }

  Widget _buildTextField(TextEditingController controller, String label,
      {bool obscureText = false}) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return "$label tidak boleh kosong";
        }
        if (obscureText && value.length < 6) {
          return "Password harus lebih dari 6 karakter";
        }
        if (label == "Konfirmasi Password" &&
            value != newPasswordController.text) {
          return "Password tidak cocok";
        }
        return null;
      },
    );
  }
}
