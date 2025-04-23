import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class UpdateProductDialog extends StatefulWidget {
  final Map<String, dynamic> product;
  final VoidCallback onProductUpdated;

  const UpdateProductDialog(
      {super.key, required this.product, required this.onProductUpdated});

  @override
  State<UpdateProductDialog> createState() => _UpdateProductDialogState();
}

class _UpdateProductDialogState extends State<UpdateProductDialog> {
  final supabase = Supabase.instance.client;
  final _formKey = GlobalKey<FormState>();
  late TextEditingController nameProductController;
  late TextEditingController priceProductController;
  late TextEditingController stockProductController;

  @override
  void initState() {
    super.initState();
    nameProductController = TextEditingController(text: widget.product['name']);
    priceProductController =
        TextEditingController(text: widget.product['price'].toString());
    stockProductController =
        TextEditingController(text: widget.product['stock'].toString());
  }

  Future _updateProduct() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final name = nameProductController.text;
    final price = double.tryParse(priceProductController.text);
    final stock = int.tryParse(stockProductController.text);

    final response = await supabase
        .from('products')
        .update({
          'name': name,
          'price': price,
          'stock': stock,
        })
        .eq('id', widget.product['id'])
        .select()
        .maybeSingle();

    if (response == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Gagal memperbarui produk")),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Produk berhasil diperbarui")),
      );
      nameProductController.clear();
      priceProductController.clear();
      stockProductController.clear();

      widget.onProductUpdated();
      Navigator.pop(context, true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: AlertDialog(
        title: Text("Edit Produk"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildTextField(nameProductController, "Nama Produk"),
            SizedBox(height: 10),
            _buildTextField(priceProductController, "Harga Produk (Rp)", isNumber: true),
            SizedBox(height: 10),
            _buildTextField(stockProductController, "Stok Produk", isNumber: true),
            SizedBox(height: 10),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            style: ElevatedButton.styleFrom(
            backgroundColor: Colors.grey,
            foregroundColor: Colors.black,
          ),
            child: Text("Batal"),
          ),
          TextButton(
            onPressed: _updateProduct,
            style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green,
            foregroundColor: Colors.white,
          ),
            child: Text("Simpan"),
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
