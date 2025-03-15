import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBar(),
      body: Column(
        children: [
          //splitmates will be here
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          print('Add SplitMate');
        },
        backgroundColor: const Color(0xFF1E1E1E),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  AppBar appBar() {
    return AppBar(
      title: Text(
        'SplitMate',
        style: TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      centerTitle: true,
      backgroundColor: Color(0xFF121212),
      elevation: 0,
      actions: [
        GestureDetector(
          onTap: () {
            print('Settings');
          },
          child: Container(
            margin: EdgeInsets.all(10),
            alignment: Alignment.center,
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Color(0xFF1E1E1E),
              borderRadius: BorderRadius.circular(20),
            ),
            child: SvgPicture.asset(
              'assets/icons/settings.svg',
              color: Colors.white,
              width: 24,
              height: 24,
            ),
          ),
        ),
      ],
    );
  }
}
