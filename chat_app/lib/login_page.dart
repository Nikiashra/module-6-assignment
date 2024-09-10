import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'home_page.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final GoogleSignIn _googleSignIn = GoogleSignIn(scopes: ['email']);

  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  // Check if the user is already logged in
  Future<void> _checkLoginStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? name = prefs.getString('displayName');
    String? email = prefs.getString('email');
    String? photoUrl = prefs.getString('photoUrl');

    if (name != null && email != null) {
      // User already logged in, navigate to HomeScreen
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => HomeScreen(
            displayName: name,
            email: email,
            photoUrl: photoUrl,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    var _mediaQuery = MediaQuery.of(context);
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Colors.lightBlueAccent,
        title: const Text(
          "Let's Chat",
          style: TextStyle(fontSize: 20.0),
        ),
      ),
      body: Stack(
        children: [
          Positioned(
              top: _mediaQuery.size.height * 0.10,
              width: _mediaQuery.size.width * 0.5,
              left: _mediaQuery.size.width * 0.25,
              child: Image.asset('assets/images/wechat.png')),
          Positioned(
            bottom: _mediaQuery.size.height * 0.15,
            height: _mediaQuery.size.height * 0.07,
            width: _mediaQuery.size.width * 0.9,
            left: _mediaQuery.size.width * 0.05,
            child: ElevatedButton.icon(
              onPressed: () {
                _handleSignIn(context);
              },
              icon: Image.asset('assets/images/glogo.png'),
              label: const Text("Sign in with Google"),
            ),
          )
        ],
      ),
    );
  }

  Future<void> _handleSignIn(BuildContext context) async {
    try {
      GoogleSignInAccount? googleAccount = await _googleSignIn.signIn();

      if (googleAccount != null) {
        final GoogleSignInAuthentication googleAuth =
        await googleAccount.authentication;

        final accessToken = googleAuth.accessToken;
        final idToken = googleAuth.idToken;

        print('Access Token: $accessToken');
        print('Id Token : $idToken');

        if (accessToken != null) {
          print('Name: ${googleAccount.displayName}');
          print('Email: ${googleAccount.email}');

          // Save user data in SharedPreferences
          SharedPreferences prefs = await SharedPreferences.getInstance();
          await prefs.setString('displayName', googleAccount.displayName ?? '');
          await prefs.setString('email', googleAccount.email);
          await prefs.setString('photoUrl', googleAccount.photoUrl ?? '');

          // Navigate to the HomeScreen after successful sign-in
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => HomeScreen(
                displayName: googleAccount.displayName,
                email: googleAccount.email,
                photoUrl: googleAccount.photoUrl,
              ),
            ),
          );
        }
      }
    } catch (e) {
      print(e);
    }
  }
}

