import 'package:aplikasi_kasir/components/customer/create_customer.dart';
import 'package:aplikasi_kasir/components/customer/delete_customer.dart';
import 'package:aplikasi_kasir/components/customer/edit_customer.dart';
import 'package:aplikasi_kasir/components/appbar.dart';
import 'package:aplikasi_kasir/components/user/create_user.dart';
import 'package:aplikasi_kasir/components/user/delete_user.dart';
import 'package:aplikasi_kasir/components/user/edit_user.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final supabase = Supabase.instance.client;

class UsersPage extends StatefulWidget {
  const UsersPage({super.key});

  @override
  State<UsersPage> createState() => _UsersPageState();
}

class _UsersPageState extends State<UsersPage> {
  List<Map<String, dynamic>> users = [];
  String searchQuery = "";
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchUsers();
  }

  Future<void> fetchUsers() async {
    setState(() {
      _isLoading = true;
    });

    final response = await supabase
        .from('users')
        .select()
        .order('created_at', ascending: false);

    setState(() {
      users = List<Map<String, dynamic>>.from(response);
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final String header = "Daftar Pengguna";

    final filteredUsers = users.where((user) {
      final userName = user['username'].toLowerCase() ?? '';
      return userName.contains(searchQuery);
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
                      labelText: "Cari Pengguna",
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
                  child: filteredUsers.isEmpty
                      ? Center(
                          child: Text(
                            "Tidak ada pengguna.",
                            style: TextStyle(fontSize: 18),
                          ),
                        )
                      : ListView.builder(
                          padding: EdgeInsets.all(10),
                          itemCount: filteredUsers.length,
                          itemBuilder: (context, index) {
                            final user = filteredUsers[index];
                            return Card(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              margin: EdgeInsets.symmetric(
                                  vertical: 8, horizontal: 16),
                              child: ListTile(
                                contentPadding: EdgeInsets.all(16),
                                title: Text(
                                  user['username'],
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    SizedBox(height: 5),
                                    Text("Email: ${user['email']}",
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis),
                                    Text("Role: ${user['role']}",
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis),
                                  ],
                                ),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      icon: Icon(Icons.edit),
                                      tooltip: "Edit Pengguna",
                                      onPressed: () => showDialog(
                                        context: context,
                                        builder: (context) => UpdateUserDialog(
                                          user: user,
                                          onUserUpdated: fetchUsers,
                                        ),
                                      ),
                                    ),
                                    IconButton(
                                      icon:
                                          Icon(Icons.delete, color: Colors.red),
                                      tooltip: "Hapus Pengguna",
                                      onPressed: () => showDialog(
                                        context: context,
                                        builder: (context) => DeleteUserDialog(
                                          user: user,
                                          onUserDeleted: fetchUsers,
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
            builder: (context) => CreateUserDialog(
              onUserAdded: fetchUsers,
            ),
          );
        },
        child: Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
