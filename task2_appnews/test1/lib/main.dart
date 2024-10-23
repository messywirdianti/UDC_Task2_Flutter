import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:test1/constant/constrantFile.dart';
import 'package:test1/register.dart';
import 'mainMenu.dart';

void main() {
  runApp(const MaterialApp(
    home: Login(),
    debugShowCheckedModeBanner: false,
  ));
}

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

enum LoginStatus { notSignIn, signIn }

class _LoginState extends State<Login> {
  LoginStatus _loginStatus = LoginStatus.notSignIn;
  late String email, password;
  final _key = GlobalKey<FormState>();

  bool _secureText = true;

  void showhide() {
    setState(() {
      _secureText = !_secureText;
    });
  }

  void check() {
    final form = _key.currentState;
    if (form!.validate()) {
      form.save();
      login();
    }
  }

  Future<void> login() async {
    try {
      final response = await http.post(
        Uri.parse(BaseUrl.login),
        body: {
          "email": email,
          "password": password,
        },
      );

      print("Response status: ${response.statusCode}");
      print("Response body: ${response.body}");

      final data = jsonDecode(response.body);

      int value = data['value'];
      String pesan = data['message'];

      if (value == 1) {
        String? usernameAPI = data['username'];
        String? emailAPI = data['email'];
        // String? id_users = data['id_users']; // Uncomment if `id_users` is part of response

        if (usernameAPI != null && emailAPI != null /* && id_users != null */) {
          setState(() {
            _loginStatus = LoginStatus.signIn;
            savePref(value, usernameAPI, emailAPI /*, id_users */);
          });

          // Navigate to MainMenu after setting the login status
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (context) => MainMenu(signOut: signOut),
            ),
          );
        } else {
          print("Username, Email, atau ID Users tidak tersedia dalam response");
        }
        print(pesan);
      } else {
        print(pesan);
      }
    } catch (e) {
      print("Error: $e");
    }
  }

  Future<void> savePref(int value, String username, String email /*, String id_users */) async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    setState(() {
      preferences.setInt("value", value);
      preferences.setString("username", username);
      preferences.setString("email", email);
      // preferences.setString("id_users", id_users); // Uncomment if `id_users` is part of response
    });
  }

  Future<void> getPref() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    setState(() {
      int? value = preferences.getInt("value");
      _loginStatus = value == 1 ? LoginStatus.signIn : LoginStatus.notSignIn;
    });
  }

  @override
  void initState() {
    super.initState();
    getPref();
  }

  Future<void> signOut() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    setState(() {
      preferences.remove("value");
      preferences.remove("username");
      preferences.remove("email");
      preferences.remove("id_users");
      _loginStatus = LoginStatus.notSignIn;
    });
  }

  @override
  Widget build(BuildContext context) {
    switch (_loginStatus) {
      case LoginStatus.notSignIn:
        return Scaffold(
          appBar: AppBar(),
          body: Form(
            key: _key,
            child: ListView(
              padding: const EdgeInsets.all(15),
              children: <Widget>[
                TextFormField(
                  validator: (e) {
                    if (e!.isEmpty) {
                      return "Please insert email";
                    }
                    return null;
                  },
                  onSaved: (e) => email = e!,
                  decoration: const InputDecoration(labelText: 'Email'),
                ),
                TextFormField(
                  obscureText: _secureText,
                  onSaved: (e) => password = e!,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    suffixIcon: IconButton(
                      onPressed: showhide,
                      icon: Icon(
                        _secureText ? Icons.visibility_off : Icons.visibility,
                      ),
                    ),
                  ),
                ),
                MaterialButton(
                  onPressed: check,
                  child: const Text("Login"),
                ),
                InkWell(
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const Register(),
                      ),
                    );
                  },
                  child: const Text(
                    "Create New Account",
                    textAlign: TextAlign.center,
                  ),
                )
              ],
            ),
          ),
        );
      case LoginStatus.signIn:
        return MainMenu(signOut: signOut);
    }
  }
}
