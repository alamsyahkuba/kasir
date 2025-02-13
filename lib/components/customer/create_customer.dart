import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class CreateCustomerDialog extends StatefulWidget {
  final VoidCallback onCustomerAdded;

  const CreateCustomerDialog({super.key, required this.onCustomerAdded});

  @override
  State<CreateCustomerDialog> createState() => _CreateCustomerDialogState();
}

class _CreateCustomerDialogState extends State<CreateCustomerDialog> {
  final supabase = Supabase.instance.client;
  final _formKey = GlobalKey<FormState>();
  final nameCustomerController = TextEditingController();
  final addressCustomerController = TextEditingController();
  final phoneCustomerController = TextEditingController();

  Future _insertCustomer() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final name = nameCustomerController.text;
    final address = addressCustomerController.text;
    final phone = phoneCustomerController.text;

    final response = await supabase.from('customers').insert({
      'name': name,
      'address': address,
      'phone_num': phone,
    });

    if (response != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Gagal menambahkan pelanggan")),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Pelanggan berhasil ditambahkan")),
      );
      nameCustomerController.clear();
      addressCustomerController.clear();
      phoneCustomerController.clear();

      widget.onCustomerAdded();
      Navigator.pop(context, true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: AlertDialog(
        title: Text("Tambah Pelanggan"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildTextField(nameCustomerController, "Nama Pelanggan"),
            SizedBox(height: 10),
            _buildTextField(addressCustomerController, "Alamat"),
            SizedBox(height: 10),
            _buildTextField(phoneCustomerController, "No. Telp",
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
            onPressed: _insertCustomer,
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
    decoration: InputDecoration(
      labelText: label,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
    ),
    validator: (value) => value!.isEmpty ? "$label tidak boleh kosong" : null,
  );
}
