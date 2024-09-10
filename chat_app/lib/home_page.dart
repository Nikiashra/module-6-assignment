import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'login_page.dart';

class HomeScreen extends StatefulWidget {
  final String? displayName;
  final String? email;
  final String? photoUrl;

  const HomeScreen({super.key, this.displayName, this.email, this.photoUrl});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<dynamic> _fetchedData = [];

  @override
  void initState() {
    super.initState();
    _fetchAndSaveData();
  }

  // Function to fetch data from a dummy API
  Future<void> _fetchAndSaveData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    // Check if data is already saved in SharedPreferences
    String? savedData = prefs.getString('fetchedData');

    if (savedData != null) {
      // Data found in SharedPreferences, load it
      setState(() {
        _fetchedData = json.decode(savedData);
      });
    } else {
      // Fetch data from API
      final response =
      await http.get(Uri.parse('https:https://nikiiashra.000webhostapp.com/API/login.php'));

      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);

        // Save the fetched data in SharedPreferences
        await prefs.setString('fetchedData', json.encode(data));

        setState(() {
          _fetchedData = data;
        });
      } else {
        throw Exception('Failed to load data');
      }
    }
  }

  Future<void> _logout(BuildContext context) async {
    // Clear SharedPreferences
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.clear();

    // Navigate back to LoginScreen
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const LoginScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Home"),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              _logout(context);
            },
          ),
        ],
      ),
      body: Center(
        child: _fetchedData.isEmpty
            ? const CircularProgressIndicator() // Show loading while fetching data
            : ListView.builder(
             itemCount: _fetchedData.length,
             itemBuilder: (context, index) {
            return ListTile(
              title: Text(_fetchedData[index]['title']),
              subtitle: Text(_fetchedData[index]['body']),
            );
          },
        ),
      ),
    );
  }
}
