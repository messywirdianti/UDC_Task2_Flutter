import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:test1/constant/constrantFile.dart';


class Register extends StatefulWidget {
  const Register({super.key});

  @override
  State<Register> createState() => _RegisterState();
}

class _RegisterState extends State<Register> {
  late String username, email, password;

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
      save();
    }
  }

  Future<void> save() async {
    final response = await http.post(
      Uri.parse(BaseUrl.register),
      body: {
        "username": username,
        "email": email,
        "password": password,
      },
    );

    final data = jsonDecode(response.body);

    // Mengakses nilai dari Map menggunakan bracket []
    int value = data['value'];
    String pesan = data['message'];

    if (value == 1) {
      setState(() {
        Navigator.pop(context);
      });
    } else {
      print(pesan);
    }
  }

  @override
  Widget build(BuildContext context) {
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
                  return "Please enter username";
                }
                return null;
              },
              onSaved: (e) => username = e!,
              decoration: const InputDecoration(labelText: 'Username'),
            ),
            TextFormField(
              validator: (e) {
                if (e!.isEmpty) {
                  return "Please enter email";
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
              onPressed: () {
                check();
              },
              child: const Text("Register"),
            ),
          ],
        ),
      ),
    );
  }
}
