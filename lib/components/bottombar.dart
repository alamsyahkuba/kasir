import 'package:flutter/material.dart';

BottomNavigationBar buildBottomBar(BuildContext context) {
  return BottomNavigationBar(
    elevation: 10,
    selectedItemColor: Colors.blue,
    unselectedItemColor: Colors.grey,
    showUnselectedLabels: true,
    items: [
      BottomNavigationBarItem(
        icon: Icon(Icons.home),
        label: "Home",
      ),
      BottomNavigationBarItem(
        icon: Icon(Icons.shopping_cart),
        label: "Jual",
      ),
      BottomNavigationBarItem(
        icon: Icon(Icons.history),
        label: "Riwayat Penjualan",
      ),
      BottomNavigationBarItem(
        icon: Icon(Icons.people),
        label: "Petugas",
      ),
      BottomNavigationBarItem(
        icon: Icon(Icons.person),
        label: "Profil",
      ),
    ],
  );
}
