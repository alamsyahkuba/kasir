import 'package:aplikasi_kasir/components/customer/create_customer.dart';
import 'package:aplikasi_kasir/components/customer/delete_customer.dart';
import 'package:aplikasi_kasir/components/customer/edit_customer.dart';
import 'package:aplikasi_kasir/components/appbar.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final supabase = Supabase.instance.client;

class CustomersPage extends StatefulWidget {
  const CustomersPage({super.key});

  @override
  State<CustomersPage> createState() => _CustomersPageState();
}

class _CustomersPageState extends State<CustomersPage> {
  List<Map<String, dynamic>> customers = [];
  String searchQuery = "";
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchCustomers();
  }

  Future<void> fetchCustomers() async {
    setState(() {
      _isLoading = true;
    });

    final response = await supabase
        .from('customers')
        .select()
        .order('created_at', ascending: false);

    setState(() {
      customers = List<Map<String, dynamic>>.from(response);
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final String header = "Daftar Pelanggan";

    final filteredCustomers = customers.where((customer) {
      final customerName = customer['name'].toLowerCase() ?? '';
      return customerName.contains(searchQuery);
    }).toList();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: buildAppBar(title: header),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Padding(
                  padding: EdgeInsets.all(16),
                  child: TextField(
                    decoration: InputDecoration(
                      labelText: "Cari Pelanggan",
                      prefixIcon: Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(50),
                      ),
                    ),
                    onChanged: (value) => setState(() {
                      searchQuery = value.toLowerCase();
                    }),
                  ),
                ),
                Expanded(
                  child: filteredCustomers.isEmpty
                      ? Center(
                          child: Text(
                            "Tidak ada pelanggan.",
                            style: TextStyle(fontSize: 18),
                          ),
                        )
                      : ListView.builder(
                          padding: EdgeInsets.all(10),
                          itemCount: filteredCustomers.length,
                          itemBuilder: (context, index) {
                            final customer = filteredCustomers[index];
                            return Card(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              margin: EdgeInsets.symmetric(
                                  vertical: 8, horizontal: 16),
                              child: ListTile(
                                contentPadding: EdgeInsets.all(16),
                                title: Text(
                                  customer['name'],
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    SizedBox(height: 5),
                                    Text("Alamat: ${customer['address']}",
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis),
                                    Text("No. Telp: ${customer['phone_num']}",
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis),
                                  ],
                                ),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      icon: Icon(Icons.edit),
                                      tooltip: "Edit Pelanggan",
                                      onPressed: () => showDialog(
                                        context: context,
                                        builder: (context) =>
                                            UpdateCustomerDialog(
                                          customer: customer,
                                          onCustomerUpdated: fetchCustomers,
                                        ),
                                      ),
                                    ),
                                    IconButton(
                                      icon:
                                          Icon(Icons.delete, color: Colors.red),
                                      tooltip: "Hapus Pelanggan",
                                      onPressed: () => showDialog(
                                        context: context,
                                        builder: (context) =>
                                            DeleteCustomerDialog(
                                          customer: customer,
                                          onCustomerDeleted: fetchCustomers,
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
            builder: (context) => CreateCustomerDialog(
              onCustomerAdded: fetchCustomers,
            ),
          );
        },
        child: Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
