import 'package:camera/screen/home.dart';
import 'package:camera/screen/sqflite.dart';
import 'package:flutter/material.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDatabase();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: HomeScrn(),
      debugShowCheckedModeBanner: false,
    );
  }
}
