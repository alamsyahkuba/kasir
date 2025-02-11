import 'package:aplikasi_kasir/services/get_user_info.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final supabase = Supabase.instance.client;

AppBar buildAppBar({String title = ''}) {
  return AppBar(
    elevation: 4,
    centerTitle: false,
    backgroundColor: Color(0xff3a57e8),
    foregroundColor: Colors.white,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.zero,
    ),
    title: Text(
      title,
      style: TextStyle(
        fontWeight: FontWeight.w700,
        fontStyle: FontStyle.normal,
        fontSize: 20,
        color: Color(0xfff9f9f9),
      ),
    ),
    actions: [
      FutureBuilder(
        future: getUserInfo(),
        builder: (context, snapshot) {
          final userInfo = snapshot.data;
          final username = userInfo?['username'] ?? "Tamu";

          if (snapshot.connectionState == ConnectionState.waiting) {
            return Padding(
              padding: EdgeInsets.only(right: 16),
              child: Center(
                child: SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2,
                  ),
                ),
              ),
            );
          }

          return Padding(
            padding: EdgeInsets.only(right: 16),
            child: Center(
              child: Text(
                username,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                ),
              ),
            ),
          );
        },
      )
    ],
  );
}
