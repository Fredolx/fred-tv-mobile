import 'package:flutter/material.dart';

class Setup extends StatefulWidget {
  @override
  State<Setup> createState() => _SetupState();
}

class _SetupState extends State<Setup> {
  int _selectedIndex = 0;
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _urlController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            ToggleButtons(
              isSelected: List.generate(3, (index) => index == _selectedIndex),
              onPressed: (index) {
                setState(() {
                  _selectedIndex = index;
                });
              },
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Text('Xtream'),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Text('M3U URL'),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Text('M3U File'),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Padding(
              padding: EdgeInsets.symmetric(
                  horizontal: MediaQuery.of(context).size.width * 0.1),
              child: TextField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    labelText: 'Name', // Label inside the input
                    prefixIcon:
                        Icon(Icons.edit), // Icon inside the input (left side)
                    border: OutlineInputBorder(),
                  )),
            ),
            const SizedBox(height: 10),
            Padding(
                padding: EdgeInsets.symmetric(
                    horizontal: MediaQuery.of(context).size.width * 0.1),
                child: TextField(
                  controller: _urlController,
                  decoration: InputDecoration(
                    labelText: 'URL', // Label inside the input
                    prefixIcon:
                        Icon(Icons.link), // Icon inside the input (left side)
                    border: OutlineInputBorder(),
                  ),
                )),
            const SizedBox(height: 10),
            Padding(
                padding: EdgeInsets.symmetric(
                    horizontal: MediaQuery.of(context).size.width * 0.1),
                child: TextField(
                  controller: _usernameController,
                  decoration: InputDecoration(
                    labelText: 'Username', // Label inside the input
                    prefixIcon: Icon(Icons
                        .account_circle), // Icon inside the input (left side)
                    border: OutlineInputBorder(),
                  ),
                )),
            const SizedBox(height: 10),
            Padding(
                padding: EdgeInsets.symmetric(
                    horizontal: MediaQuery.of(context).size.width * 0.1),
                child: TextField(
                  controller: _passwordController,
                  decoration: InputDecoration(
                    labelText: 'Password', // Label inside the input
                    prefixIcon: Icon(
                        Icons.password), // Icon inside the input (left side)
                    border: OutlineInputBorder(),
                  ),
                )),
            const SizedBox(height: 20),
            ElevatedButton(onPressed: () => (), child: Text("Submit"))
          ]),
    );
  }
}
