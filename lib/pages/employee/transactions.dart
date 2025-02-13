import 'package:aplikasi_kasir/components/appbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class TransactionsPage extends StatefulWidget {
  const TransactionsPage({super.key});

  @override
  State<TransactionsPage> createState() => _TransactionsPageState();
}

class _TransactionsPageState extends State<TransactionsPage> {
  final supabase = Supabase.instance.client;
  final _formKey = GlobalKey<FormState>();

  String? selectedCustomer;
  String? selectedProduct;
  double? paymentAmount;
  List<Map<String, dynamic>> cart = [];
  List<Map<String, dynamic>> customers = [];
  List<Map<String, dynamic>> products = [];
  late TextEditingController _paymentController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchCustomers();
    _fetchProducts();
  }

  Future<void> _fetchCustomers() async {
    final response = await supabase.from('customers').select();
    setState(() {
      customers = response;
    });
  }

  Future<void> _fetchProducts() async {
    final response = await supabase.from('products').select();
    setState(() {
      products = response;
    });
  }

  String formatRupiah(num number) {
    final formatCurrency =
        NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);
    return formatCurrency.format(number);
  }

  String formatDate(DateTime date) {
    final dateFormat = DateFormat('dd MMMM yyyy');
    return dateFormat.format(date);
  }

  void _addProductToCart() {
    if (selectedProduct != null) {
      final product = products
          .firstWhere((prod) => prod['id'].toString() == selectedProduct);
      int existingIndex =
          cart.indexWhere((item) => item['id'] == product['id']);

      setState(() {
        if (existingIndex != -1) {
          cart[existingIndex]['quantity'] += 1;
        } else {
          cart.add({
            'id': product['id'],
            'name': product['name'],
            'price': product['price'],
            'quantity': 1,
          });
        }
      });
    }
  }

  void _updateQuantity(int index, int change) {
    setState(() {
      cart[index]['quantity'] =
          (cart[index]['quantity'] + change).clamp(1, 100);
    });
  }

  void _removeProduct(int index) {
    setState(() {
      cart.removeAt(index);
    });
  }

  double _calculateTotal() {
    return cart.fold(
        0, (total, item) => total + (item['price'] * item['quantity']));
  }

  void _processTransaction() async {
    if (!_formKey.currentState!.validate()) return;
    if (selectedCustomer == null ||
        cart.isEmpty ||
        paymentAmount! < _calculateTotal()) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(
                "Pastikan semua data sudah lengkap dan pembayaran cukup!")),
      );
      return;
    }

    double change = paymentAmount! - _calculateTotal();

    // Simpan data cart ke variabel agar tidak hilang
    List<Map<String, dynamic>> cartItems = List.from(cart);

    final transaction = {
      'customer_id': selectedCustomer,
      'total_price': _calculateTotal(),
      'date': DateTime.now().toIso8601String(),
      'payment': paymentAmount,
      'change': change,
    };

    final response = await supabase
        .from('transactions')
        .insert(transaction)
        .select()
        .single();

    if (response != null) {
      final transactionId = response['id'];

      List<Map<String, dynamic>> detailTransactions = cartItems.map((item) {
        return {
          'transaction_id': transactionId,
          'product_id': item['id'],
          'product_qty': item['quantity'], // Sesuaikan dengan nama di database
          'sub_total': item['quantity'] * item['price'],
        };
      }).toList();

      await supabase.from('detail_transactions').upsert(detailTransactions);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Transaksi berhasil!")),
      );

      // Pastikan data `items` berasal dari `cartItems`
      response['items'] = cartItems;
      _showReceipt(response);
    }
  }

  void _showReceipt(Map<String, dynamic> transaction) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Struk Transaksi"),
          content: SingleChildScrollView(
            child: SizedBox(
              width: double.maxFinite,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                      "Tanggal: ${formatDate(DateTime.parse(transaction['date']))}"),
                  SizedBox(height: 5),
                  Divider(),
                  Text(
                    "Detail Pembelian",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 5),
                  ListView.builder(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    itemCount: transaction['items']?.length ?? 0,
                    itemBuilder: (context, index) {
                      final item = transaction['items'][index];
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 2),
                        child: Text(
                          "${item['name']} x${item['quantity']} = ${formatRupiah(item['quantity'] * item['price'])}",
                        ),
                      );
                    },
                  ),
                  Divider(),
                  SizedBox(height: 5),
                  Text("Total: ${formatRupiah(transaction['total_price'])}",
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  Text("Bayar: ${formatRupiah(transaction['payment'])}"),
                  Text("Kembalian: ${formatRupiah(transaction['change'])}",
                      style: TextStyle(color: Colors.green)),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              child: Text("OK"),
              onPressed: () => Navigator.pop(context),
            ),
          ],
        );
      },
    );

    setState(() {
      selectedCustomer = null;
      selectedProduct = null;
      paymentAmount = null;
      _paymentController.clear();
      cart.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: buildAppBar(title: "Transaksi"),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Form(
          key: _formKey,
          // autovalidateMode: AutovalidateMode.,
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField(
                      value: selectedCustomer,
                      decoration: InputDecoration(
                        labelText: "Pilih Pelanggan",
                        border: OutlineInputBorder(),
                        contentPadding:
                            EdgeInsets.symmetric(vertical: 8, horizontal: 10),
                      ),
                      validator: (value) =>
                          value == null ? 'Mohon pilih pelanggan' : null,
                      onChanged: (value) {
                        setState(() => selectedCustomer = value);
                      },
                      items: customers.map((customer) {
                        return DropdownMenuItem(
                          value: customer['id'].toString(),
                          child: Text(customer['name']),
                        );
                      }).toList(),
                    ),
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: DropdownButtonFormField(
                      value: selectedProduct,
                      decoration: InputDecoration(
                        labelText: "Pilih Produk",
                        border: OutlineInputBorder(),
                        contentPadding:
                            EdgeInsets.symmetric(vertical: 8, horizontal: 10),
                      ),
                      validator: (value) =>
                          value == null ? 'Mohon pilih produk' : null,
                      onChanged: (value) {
                        setState(() => selectedProduct = value);
                      },
                      items: products.map((product) {
                        return DropdownMenuItem(
                          value: product['id'].toString(),
                          child: Text(product['name']),
                        );
                      }).toList(),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 8),
              ElevatedButton(
                onPressed: _addProductToCart,
                child: Text("Tambah Produk"),
              ),
              SizedBox(height: 8),
              Text("Daftar Barang",
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
              Expanded(
                child: ListView.builder(
                  itemCount: cart.length,
                  itemBuilder: (context, index) {
                    final item = cart[index];
                    double subTotal = item['quantity'] * item['price'];
                    return Card(
                      margin: EdgeInsets.symmetric(vertical: 3),
                      child: ListTile(
                        title: Text(item['name'],
                            style: TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text(
                          "Qty: ${item['quantity']} x ${formatRupiah(item['price'])} = ${formatRupiah(subTotal)}",
                          style: TextStyle(color: Colors.grey[700]),
                        ),
                        trailing: Wrap(
                          spacing: 8,
                          children: [
                            IconButton(
                              icon: Icon(Icons.remove, color: Colors.red),
                              onPressed: () => _updateQuantity(index, -1),
                            ),
                            IconButton(
                              icon: Icon(Icons.add, color: Colors.green),
                              onPressed: () => _updateQuantity(index, 1),
                            ),
                            IconButton(
                              icon: Icon(Icons.delete, color: Colors.grey),
                              onPressed: () => _removeProduct(index),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              Divider(),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Total Harga: ${formatRupiah(_calculateTotal())}",
                      style:
                          TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                    ),
                    Text(
                      formatDate(DateTime.now()),
                      style:
                          TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),
              TextFormField(
                controller: _paymentController,
                decoration: InputDecoration(
                  labelText: "Uang Pembayaran",
                  border: OutlineInputBorder(),
                  contentPadding:
                      EdgeInsets.symmetric(vertical: 8, horizontal: 10),
                ),
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Masukkan jumlah pembayaran';
                  }
                  if (double.tryParse(value) == null ||
                      double.parse(value) < _calculateTotal()) {
                    return 'Pembayaran tidak cukup';
                  }
                  return null;
                },
                onChanged: (value) {
                  setState(() => paymentAmount = double.tryParse(value) ?? 0);
                },
              ),
              SizedBox(height: 10),
              ElevatedButton(
                onPressed: _processTransaction,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  padding: EdgeInsets.symmetric(vertical: 12),
                  minimumSize: Size(double.infinity, 45),
                ),
                child: Text(
                  "Lakukan Transaksi",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
