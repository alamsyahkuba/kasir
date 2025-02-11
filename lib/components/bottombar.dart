import 'package:aplikasi_kasir/pages/customers.dart';
import 'package:aplikasi_kasir/pages/history.dart';
import 'package:aplikasi_kasir/pages/home.dart';
import 'package:aplikasi_kasir/pages/profile.dart';
import 'package:aplikasi_kasir/pages/transactions.dart';
import 'package:aplikasi_kasir/pages/users.dart';
import 'package:flutter/material.dart';
import 'package:aplikasi_kasir/services/get_user_info.dart';

class BottomNavBar extends StatefulWidget {
  @override
  _BottomNavBarState createState() => _BottomNavBarState();
}

class _BottomNavBarState extends State<BottomNavBar> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: getUserInfo(),
        builder: (context, snapshot) {
          final userInfo = snapshot.data;
          final role = userInfo?['role'];

          if (snapshot.connectionState == ConnectionState.waiting) {
            return Scaffold(
              body: Center(
                child: CircularProgressIndicator(),
              ),
            );
          }

          final List<Widget> pages = role == 'admin'
              ? [HomePage(), CustomersPage(), UsersPage(), ProfilePage()]
              : [HomePage(), TransactionsPage(), HistoryPage(), ProfilePage()];

          final List<BottomNavigationBarItem> icons = role == 'admin'
              ? [
                  BottomNavigationBarItem(
                      icon: Icon(Icons.home), label: 'Home'),
                  BottomNavigationBarItem(
                      icon: Icon(Icons.people), label: 'Pelanggan'),
                  BottomNavigationBarItem(
                      icon: Icon(Icons.admin_panel_settings),
                      label: 'Pengguna'),
                  BottomNavigationBarItem(
                      icon: Icon(Icons.person), label: 'Profil'),
                ]
              : [
                  BottomNavigationBarItem(
                      icon: Icon(Icons.home), label: 'Home'),
                  BottomNavigationBarItem(
                      icon: Icon(Icons.shopping_cart), label: 'Transaksi'),
                  BottomNavigationBarItem(
                      icon: Icon(Icons.history_edu), label: 'Riwayat'),
                  BottomNavigationBarItem(
                      icon: Icon(Icons.person), label: 'Profil'),
                ];

          return Scaffold(
            body: pages[_selectedIndex],
            bottomNavigationBar: BottomNavigationBar(
              currentIndex: _selectedIndex,
              onTap: (index) {
                setState(() {
                  _selectedIndex = index;
                });
              },
              selectedItemColor: Colors.blue,
              unselectedItemColor: Colors.grey,
              showUnselectedLabels: true,
              items: icons,
            ),
            // items: icons,
          );
        });
  }
}
