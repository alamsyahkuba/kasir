import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class UpdateCustomerDialog extends StatefulWidget {
  final Map<String, dynamic> customer;
  final VoidCallback onCustomerUpdated;

  const UpdateCustomerDialog(
      {super.key, required this.customer, required this.onCustomerUpdated});

  @override
  State<UpdateCustomerDialog> createState() => _UpdateCustomerDialogState();
}

class _UpdateCustomerDialogState extends State<UpdateCustomerDialog> {
  final supabase = Supabase.instance.client;
  final _formKey = GlobalKey<FormState>();
  late TextEditingController nameCustomerController;
  late TextEditingController addressCustomerController;
  late TextEditingController phoneCustomerController;

  @override
  void initState() {
    super.initState();
    nameCustomerController =
        TextEditingController(text: widget.customer['name']);
    addressCustomerController =
        TextEditingController(text: widget.customer['address'].toString());
    phoneCustomerController =
        TextEditingController(text: widget.customer['phone_num'].toString());
  }

  Future _updateCustomer() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final name = nameCustomerController.text;
    final address = addressCustomerController.text;
    final phone = phoneCustomerController.text;

    final response = await supabase
        .from('customers')
        .update({
          'name': name,
          'address': address,
          'phone_num': phone,
        })
        .eq('id', widget.customer['id'])
        .select()
        .maybeSingle();

    if (response == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Gagal memperbarui pelanggan")),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Pelanggan berhasil diperbarui")),
      );
      nameCustomerController.clear();
      addressCustomerController.clear();
      phoneCustomerController.clear();

      widget.onCustomerUpdated();
      Navigator.pop(context, true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text("Edit Pelanggan"),
      content: Form(
        key: _formKey,
        child: Column(
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
          onPressed: _updateCustomer,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green,
            foregroundColor: Colors.white,
          ),
          child: Text("Simpan"),
        ),
      ],
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
    validator: (value) => value == null || value.trim().isEmpty
        ? "$label tidak boleh kosong"
        : null,
  );
}
