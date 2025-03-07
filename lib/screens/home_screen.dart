// home_screen.dart
import 'package:flutter/material.dart';
import 'package:guidera_app/Widgets/header.dart';



//import 'guidera_header.dart'; // Import the header widget file

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Option 1: Use header as part of the body
      body: Column(
        children: [
          const GuideraHeader(), // This is your static header at the top
          // Rest of your screen widgets go here...
          Expanded(
            child: Center(child: Text('Home Screen Content')),
          ),
        ],
      ),

      // Option 2: If you want it in an AppBar, you might consider using a PreferredSize widget:
      // appBar: PreferredSize(
      //   preferredSize: Size.fromHeight(150),
      //   child: const GuideraHeader(),
      // ),
    );
  }
}
