// import 'package:aplikasi_kasir/components/bottombar.dart';
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
  // ignore: library_private_types_in_public_api
  _HomePageState createState() => _HomePageState();
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

  WidgetStateProperty<Color> stateColor(Color color) {
    return WidgetStatePropertyAll<Color>(color);
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final String header = "Home";

    final filteredProducts = products.where((product) {
      final productName = product['name'].toLowerCase() ?? '';
      return productName.contains(searchQuery);
    }).toList();

    return Scaffold(
      backgroundColor: Color(0xffffffff),
      appBar: buildAppBar(title: header),
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(),
            )
          : SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.max,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      Padding(
                        padding: EdgeInsets.all(16),
                        child: Text(
                          "Daftar Produk",
                          overflow: TextOverflow.clip,
                          style: TextStyle(
                            fontWeight: FontWeight.w400,
                            fontStyle: FontStyle.normal,
                            fontSize: 20,
                            color: Color(0xff000000),
                          ),
                        ),
                      ),
                      Expanded(
                        child: Padding(
                          padding: EdgeInsets.all(16),
                          child: TextFormField(
                            autofocus: false,
                            obscureText: false,
                            textAlign: TextAlign.start,
                            maxLines: 1,
                            style: TextStyle(
                              fontWeight: FontWeight.w400,
                              fontStyle: FontStyle.normal,
                              fontSize: 14,
                              color: Color(0xff000000),
                            ),
                            decoration: InputDecoration(
                              disabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(50),
                                borderSide: BorderSide(
                                    color: Color(0xff9e9e9e), width: 1),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(50),
                                borderSide: BorderSide(
                                    color: Color(0xff9e9e9e), width: 1),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(50),
                                borderSide: BorderSide(
                                    color: Color(0xff9e9e9e), width: 1),
                              ),
                              filled: true,
                              fillColor: Color(0x00ffffff),
                              isDense: false,
                              contentPadding: EdgeInsets.symmetric(
                                  vertical: 1, horizontal: 40),
                              prefixIcon: Icon(Icons.search),
                              prefixStyle: TextStyle(
                                fontSize: 8,
                              ),
                              hintText: "Cari Produk",
                            ),
                            onChanged: (value) => setState(() {
                              searchQuery = value.toLowerCase();
                            }),
                          ),
                        ),
                      ),
                      Flexible(
                        child: Padding(
                          padding: EdgeInsets.all(16),
                          child: TextButton.icon(
                            label: Text("Tambah Produk"),
                            icon: Icon(Icons.add),
                            style: ButtonStyle(
                              backgroundColor: stateColor(Color(0xff3a57e8)),
                              foregroundColor: stateColor(Colors.white),
                              iconColor: stateColor(Colors.white),
                              padding:
                                  WidgetStatePropertyAll<EdgeInsetsGeometry>(
                                      EdgeInsets.all(14)),
                              shape: WidgetStatePropertyAll<OutlinedBorder>(
                                RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8)),
                              ),
                              textStyle: WidgetStatePropertyAll<TextStyle>(
                                TextStyle(
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ),
                            onPressed: () {
                              showDialog(
                                context: context,
                                builder: (context) => CreateProduct(
                                  onProductAdded: fetchProducts,
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                  GridView.builder(
                    shrinkWrap: true,
                    padding: EdgeInsets.all(50),
                    itemCount: filteredProducts.length,
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: (screenWidth / 200).floor(),
                      crossAxisSpacing: 8,
                      mainAxisSpacing: 8,
                      childAspectRatio: 1,
                    ),
                    itemBuilder: (context, index) {
                      final product = filteredProducts[index];

                      return GridTile(
                        footer: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Padding(
                              padding: EdgeInsets.only(right: 4, bottom: 10),
                              child: IconButton(
                                tooltip: "Edit Produk",
                                icon: Icon(Icons.edit),
                                onPressed: () => showDialog(
                                  context: context,
                                  builder: (context) => UpdateProductDialog(
                                      product: product,
                                      onProductUpdated: fetchProducts),
                                ),
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.only(right: 16, bottom: 10),
                              child: IconButton(
                                tooltip: "Hapus Produk",
                                icon: Icon(Icons.delete),
                                color: Color.fromARGB(255, 240, 75, 75),
                                onPressed: () => showDialog(
                                  context: context,
                                  builder: (context) => DeleteProductDialog(
                                    product: product,
                                    onProductDeleted: fetchProducts,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        child: Card(
                          margin:
                              EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                          color: Color(0xfff7f7f7),
                          shape: RoundedRectangleBorder(
                            side:
                                BorderSide(color: Color(0xff9e9e9e), width: 1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Padding(
                            padding: EdgeInsets.all(16),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  "Stok: ${product['stock']}",
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1,
                                  style: TextStyle(
                                    fontSize: 14,
                                  ),
                                ),
                                SizedBox(height: 8),
                                Text(
                                  product['name'],
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1,
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontStyle: FontStyle.normal,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                SizedBox(height: 8),
                                Text(
                                  "Harga: ${formatRupiah(product['price'])}",
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1,
                                  style: TextStyle(
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
    );
  }
}
