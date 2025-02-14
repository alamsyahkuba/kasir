import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class CreateProductDialog extends StatefulWidget {
  final VoidCallback onProductAdded;

  const CreateProductDialog({super.key, required this.onProductAdded});

  @override
  State<CreateProductDialog> createState() => _CreateProductDialogState();
}

class _CreateProductDialogState extends State<CreateProductDialog> {
  final supabase = Supabase.instance.client;
  final _formKey = GlobalKey<FormState>();
  final nameProductController = TextEditingController();
  final priceProductController = TextEditingController();
  final stockProductController = TextEditingController();

  Future _insertProduct() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final name = nameProductController.text;
    final price = double.tryParse(priceProductController.text);
    final stock = int.tryParse(stockProductController.text);

    final response = await supabase.from('products').insert({
      'name': name,
      'price': price,
      'stock': stock,
    });

    if (response != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Gagal menambahkan produk")),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Produk berhasil ditambahkan")),
      );
      nameProductController.clear();
      priceProductController.clear();
      stockProductController.clear();

      widget.onProductAdded();
      Navigator.pop(context, true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: AlertDialog(
        title: Text("Tambah Produk"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildTextField(nameProductController, "Nama Produk"),
            SizedBox(height: 10),
            _buildTextField(priceProductController, "Harga Produk (Rp)",
                isNumber: true),
            SizedBox(height: 10),
            _buildTextField(stockProductController, "Stok Produk",
                isNumber: true),
            SizedBox(height: 10),
          ],
        ),
        actions: [
          TextButton(
            child: Text("Batal"),
            onPressed: () => Navigator.of(context).pop(),
          ),
          TextButton(
            onPressed: _insertProduct,
            child: Text("Tambah"),
          ),
        ],
      ),
    );
  }
}

Widget _buildTextField(TextEditingController controller, String label,
    {bool isNumber = false}) {
  return TextFormField(
    controller: controller,
    keyboardType: isNumber ? TextInputType.number : TextInputType.text,
    inputFormatters: isNumber ? [FilteringTextInputFormatter.digitsOnly] : [],
    decoration: InputDecoration(
      labelText: label,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
    ),
    validator: (value) => value == null || value.trim().isEmpty ? "$label tidak boleh kosong" : null,
  );
}
