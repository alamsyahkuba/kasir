import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class DeleteProductDialog extends StatefulWidget {
  final Map<String, dynamic> product;
  final VoidCallback onProductDeleted;

  const DeleteProductDialog(
      {super.key, required this.product, required this.onProductDeleted});

  @override
  State<DeleteProductDialog> createState() => _DeleteProductDialogState();
}

class _DeleteProductDialogState extends State<DeleteProductDialog> {
  final supabase = Supabase.instance.client;

  Future _deleteProduct() async {
    final response = await supabase
        .from('products')
        .delete()
        .match({'id': widget.product['id']});

    if (response != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Gagal menghapus produk")),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Produk berhasil dihapus")),
      );
      widget.onProductDeleted();
      Navigator.pop(context, true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text("Hapus Produk"),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text("Anda yakin ingin menghapus produk ${widget.product['name']}?")
        ],
      ),
      actions: [
        TextButton(
          child: Text("Batal"),
          onPressed: () => Navigator.of(context).pop(),
        ),
        TextButton(
          onPressed: _deleteProduct,
          style: TextButton.styleFrom(foregroundColor: Colors.red),
          child: Text("Hapus"),
        ),
      ],
    );
  }
}
