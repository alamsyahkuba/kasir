import 'package:aplikasi_kasir/components/product/delete_product.dart';
import 'package:aplikasi_kasir/components/product/edit_product.dart';
import 'package:aplikasi_kasir/components/product/create_product.dart';
import 'package:aplikasi_kasir/components/appbar.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';

final supabase = Supabase.instance.client;

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Map<String, dynamic>> products = [];
  String searchQuery = "";
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchProducts();
  }

  String formatRupiah(num number) {
    final formatCurrency =
        NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);
    return formatCurrency.format(number);
  }

  Future<void> fetchProducts() async {
    setState(() {
      _isLoading = true;
    });

    final response = await supabase
        .from('products')
        .select()
        .order('created_at', ascending: false);

    setState(() {
      products = List<Map<String, dynamic>>.from(response);
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final filteredProducts = products.where((product) {
      final productName = product['name'].toLowerCase() ?? '';
      return productName.contains(searchQuery);
    }).toList();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: buildAppBar(title: "Daftar Produk"),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Padding(
                  padding: EdgeInsets.all(16),
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: "Cari Produk",
                      prefixIcon: Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(50),
                      ),
                    ),
                    onChanged: (value) {
                      setState(() {
                        searchQuery = value.toLowerCase();
                      });
                    },
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    padding: EdgeInsets.all(16),
                    itemCount: filteredProducts.length,
                    itemBuilder: (context, index) {
                      final product = filteredProducts[index];

                      return Card(
                        margin: EdgeInsets.symmetric(vertical: 8),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: ListTile(
                          title: Text(product['name'],
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 16)),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("Stok: ${product['stock']}",
                                  style: TextStyle(fontSize: 14)),
                              Text("Harga: ${formatRupiah(product['price'])}",
                                  style: TextStyle(fontSize: 14)),
                            ],
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: Icon(Icons.edit),
                                tooltip: "Perbarui Produk",
                                onPressed: () => showDialog(
                                  context: context,
                                  builder: (context) => UpdateProductDialog(
                                    product: product,
                                    onProductUpdated: fetchProducts,
                                  ),
                                ),
                              ),
                              IconButton(
                                icon: Icon(Icons.delete, color: Colors.red),
                                tooltip: "Hapus Produk",
                                onPressed: () => showDialog(
                                  context: context,
                                  builder: (context) => DeleteProductDialog(
                                    product: product,
                                    onProductDeleted: fetchProducts,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Color(0xff3a57e8),
        onPressed: () {
          showDialog(
            context: context,
            builder: (context) => CreateProductDialog(
              onProductAdded: fetchProducts,
            ),
          );
        },
        child: Icon(Icons.add, color: Colors.white,),
      ),
    );
  }
}
