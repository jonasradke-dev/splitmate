import 'package:flutter/material.dart';
import 'package:splitmate/pages/login_page.dart';
import 'package:splitmate/pages/register_page.dart';
import 'package:splitmate/pages/home.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'SplitMate',
      theme: ThemeData.dark(),
      initialRoute: "/login", // Starts at the login page
      routes: {
        "/login": (context) => const LoginPage(),
        "/register": (context) => const RegisterPage(),
        "/home": (context) => const HomePage(),
      },
    );
  }
}
