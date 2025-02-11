import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class DeleteProductDialog extends StatefulWidget {
  final Map<String, dynamic> product;
  final VoidCallback onProductDeleted;

  const DeleteProductDialog({super.key, required this.product, required this.onProductDeleted});

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

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Produk berhasil dihapus")),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text("Hapus Produk"),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [Text("Anda yakin ingin mengahups produk ini?")],
      ),
      actions: [
        TextButton(
          child: Text("Batal"),
          onPressed: () => Navigator.of(context).pop(),
        ),
        TextButton(
          child: Text("Hapus"),
          onPressed: () => _deleteProduct,
        ),
      ],
    );
  }
}
