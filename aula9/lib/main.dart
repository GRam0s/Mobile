import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
void main() {
  runApp(const MaterialApp(
    debugShowCheckedModeBanner: false,
    home: AppBanco(),
  ));
}

class AppBanco extends StatefulWidget {
  const AppBanco({super.key});

  @override
  State<AppBanco> createState() => _AppBancoState();
}