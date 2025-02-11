import 'package:flutter/material.dart';

class ProductForm extends StatefulWidget {
  final Function onProductAdded;

  ProductForm({required this.onProductAdded});

  @override
  _ProductFormState createState() => _ProductFormState();
}

class _ProductFormState extends State<ProductForm> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController priceController = TextEditingController();
  final TextEditingController stockController = TextEditingController();

  void _saveProduct() {
    if (_formKey.currentState!.validate()) {
      // Save to Supabase or backend
      widget.onProductAdded();
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text("Tambah Produk"),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: nameController,
              decoration: InputDecoration(labelText: "Nama Produk"),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Masukkan nama produk';
                }
                return null;
              },
            ),
            TextFormField(
              controller: priceController,
              decoration: InputDecoration(labelText: "Harga (Rp)"),
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Masukkan harga produk';
                }
                return null;
              },
            ),
            TextFormField(
              controller: stockController,
              decoration: InputDecoration(labelText: "Stok"),
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Masukkan stok produk';
                }
                return null;
              },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          child: Text("Batal"),
          onPressed: () => Navigator.pop(context),
        ),
        TextButton(
          child: Text("Simpan"),
          onPressed: _saveProduct,
        ),
      ],
    );
  }
}
