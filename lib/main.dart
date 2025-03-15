import 'package:flutter/material.dart';
import 'package:splitmate/pages/home.dart';

void main() {
  runApp(const SplitMate());
}

class SplitMate extends StatelessWidget {
  const SplitMate({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SplitMate',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.blue, fontFamily: 'Roboto'),
      home: const HomePage(),
    );
  }
}
