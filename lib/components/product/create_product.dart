import 'package:aplikasi_kasir/pages/home.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class CreateProduct extends StatefulWidget {
  final VoidCallback onProductAdded;

  const CreateProduct({super.key, required this.onProductAdded});

  @override
  // ignore: library_private_types_in_public_api
  _CreateProductState createState() => _CreateProductState();
}

class _CreateProductState extends State<CreateProduct> {
  final supabase = Supabase.instance.client;
  final _namaProdukController = TextEditingController();
  final _hargaProdukController = TextEditingController();
  final _stokProdukController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  Future _insertData() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final name = _namaProdukController.text;
    final priceText = _hargaProdukController.text;
    final stockText = _stokProdukController.text;

    final price = double.tryParse(priceText);
    final stock = int.tryParse(stockText);

    final response = await supabase.from('products').insert({
      'name': name,
      'price': price,
      'stock': stock,
    });

    if (response != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Kesalahan $response")),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Produk berhasil ditambahkan")),
      );
      _namaProdukController.clear();
      _hargaProdukController.clear();
      _stokProdukController.clear();

      widget.onProductAdded();

      Navigator.pop(context, true);
    }
    // Navigator.pushReplacement(
    //   context,
    //   MaterialPageRoute(builder: (context) => HomePage()),
    // );
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
            Padding(
              padding: EdgeInsets.symmetric(
                vertical: 8,
                horizontal: 10,
              ),
              child: TextFormField(
                controller: _namaProdukController,
                decoration: InputDecoration(labelText: "Nama Produk"),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Masukkan Nama Produk";
                  }
                  return null;
                },
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(
                vertical: 8,
                horizontal: 10,
              ),
              child: TextFormField(
                controller: _hargaProdukController,
                decoration: InputDecoration(labelText: "Harga (Rp)"),
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                ],
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Masukkan Harga Produk";
                  }
                  return null;
                },
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(
                vertical: 8,
                horizontal: 10,
              ),
              child: TextFormField(
                controller: _stokProdukController,
                decoration: InputDecoration(labelText: "Stok"),
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                ],
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Masukkan Stok Produk";
                  }
                  return null;
                },
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          child: Text("Batal"),
          onPressed: () => Navigator.of(context).pop(),
        ),
        TextButton(
          child: Text("Tambah"),
          onPressed: () async {
            final isSuccess = await _insertData();
            if (isSuccess) {
              Navigator.of(context).pop(true);
            }
          },
        ),
      ],
    );
  }
}
