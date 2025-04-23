import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class DeleteCustomerDialog extends StatefulWidget {
  final Map<String, dynamic> customer;
  final VoidCallback onCustomerDeleted;

  const DeleteCustomerDialog(
      {super.key, required this.customer, required this.onCustomerDeleted});

  @override
  State<DeleteCustomerDialog> createState() => _DeleteCustomerDialogState();
}

class _DeleteCustomerDialogState extends State<DeleteCustomerDialog> {
  final supabase = Supabase.instance.client;

  Future _deleteCustomer() async {
    final response = await supabase
        .from('customers')
        .delete()
        .match({'id': widget.customer['id']});

    if (response != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Gagal menghapus pelanggan")),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Pelanggan berhasil dihapus")),
      );
      widget.onCustomerDeleted();
      Navigator.pop(context, true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text("Hapus Pelanggan"),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
              "Anda yakin ingin menghapus pelanggan ${widget.customer['name']}?")
        ],
      ),
      actions: [
        ElevatedButton(
          onPressed: () => Navigator.of(context).pop(),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.grey,
            foregroundColor: Colors.black,
          ),
          child: Text("Batal"),
        ),
        ElevatedButton(
          onPressed: _deleteCustomer,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red,
            foregroundColor: Colors.white,
          ),
          child: Text("Hapus"),
        ),
      ],
    );
  }
}
