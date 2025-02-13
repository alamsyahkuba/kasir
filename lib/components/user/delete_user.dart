import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class DeleteUserDialog extends StatefulWidget {
  final Map<String, dynamic> user;
  final VoidCallback onUserDeleted;

  const DeleteUserDialog(
      {super.key, required this.user, required this.onUserDeleted});

  @override
  State<DeleteUserDialog> createState() => _DeleteUserDialogState();
}

class _DeleteUserDialogState extends State<DeleteUserDialog> {
  final supabase = Supabase.instance.client;

  Future<void> _deleteUser() async {
    final response =
        await supabase.from('users').delete().match({'id': widget.user['id']});

    if (response != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Gagal menghapus pengguna")),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Pengguna berhasil dihapus")),
      );

      widget.onUserDeleted();
      Navigator.pop(context, true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text("Hapus Pengguna"),
      content: Text(
          "Anda yakin ingin menghapus pengguna ${widget.user['username']}?"),
      actions: [
        TextButton(
          child: Text("Batal"),
          onPressed: () => Navigator.of(context).pop(),
        ),
        TextButton(
          onPressed: _deleteUser,
          style: TextButton.styleFrom(foregroundColor: Colors.red),
          child: Text("Hapus"),
        ),
      ],
    );
  }
}
