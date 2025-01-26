import 'package:flutter/material.dart';

class Setup extends StatefulWidget {
  @override
  State<Setup> createState() => _SetupState();
}

class _SetupState extends State<Setup> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text('This is the setup!'),
      ),
    );
  }
}
