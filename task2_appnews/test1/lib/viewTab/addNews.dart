import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:path/path.dart' as path;

import '../constant/constrantFile.dart';

class Addnews extends StatefulWidget {
  const Addnews({super.key});

  @override
  State<Addnews> createState() => _AddnewsState();
}

class _AddnewsState extends State<Addnews> {
  XFile? _imageFile;
  String? title, content, description, id_user;
  final _key = GlobalKey<FormState>();
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    getPref(); // Memanggil fungsi untuk mengambil ID user dari SharedPreferences
  }

  Future<void> _pilihKamera() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1000,
        maxHeight: 1920,
      );

      if (image == null) {
        print("No image selected");
        return;
      }

      setState(() {
        _imageFile = image;
      });
    } catch (e) {
      print("Error picking image: $e");
    }
  }

  void check() {
    final form = _key.currentState;
    if (form!.validate()) {
      form.save();
      submit();
    }
  }

  submit() async {
    if (_imageFile == null) {
      print("No image selected");
      return;
    }

    try {
      var uri = Uri.parse(BaseUrl.addNews);
      var request = http.MultipartRequest("POST", uri);

      // Menggunakan fromPath untuk mempermudah
      request.files.add(
        await http.MultipartFile.fromPath(
          'image',
          _imageFile!.path,
        ),
      );

      // Pastikan semua field terisi dengan validasi
      if (title != null && content != null && description != null && id_user != null) {
        request.fields['title'] = title!;
        request.fields['content'] = content!;
        request.fields['description'] = description!;
        request.fields['id_users'] = id_user!;

        var response = await request.send();

        if (response.statusCode == 200) {
          print("Image Uploaded Successfully");
          setState(() {
            Navigator.pop(context);
          });
        } else {
          print("Image upload failed with status: ${response.statusCode}");
        }
      } else {
        print("Some fields are null");
      }
    } catch (e) {
      debugPrint("Error $e");
    }
  }

  getPref() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    setState(() {
      id_user = preferences.getString("id_users");
      print("ID User fetched from SharedPreferences: $id_user");
    });
  }

  @override
  Widget build(BuildContext context) {
    var placeholder = Container(
      width: double.infinity,
      height: 150,
      child: Image.asset('image/icon image.jpg'), // Pastikan path file benar
    );

    return Scaffold(
      appBar: AppBar(title: Text('Add News')),
      body: Form(
        key: _key,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: <Widget>[
            Container(
              width: double.infinity,
              child: InkWell(
                onTap: () {
                  _pilihKamera();
                },
                child: _imageFile == null
                    ? placeholder
                    : Image.file(File(_imageFile!.path), fit: BoxFit.fill),
              ),
            ),
            TextFormField(
              onSaved: (e) => title = e,
              decoration: const InputDecoration(labelText: 'Title'),
              validator: (value) => value == null || value.isEmpty ? 'Please enter title' : null,
            ),
            TextFormField(
              onSaved: (e) => content = e,
              decoration: const InputDecoration(labelText: 'Content'),
              validator: (value) => value == null || value.isEmpty ? 'Please enter content' : null,
            ),
            TextFormField(
              onSaved: (e) => description = e,
              decoration: const InputDecoration(labelText: 'Description'),
              validator: (value) => value == null || value.isEmpty ? 'Please enter description' : null,
            ),
            MaterialButton(
              onPressed: id_user == null // Nonaktifkan tombol jika id_user null
                  ? null
                  : () {
                print("Submit button pressed");
                check();
              },
              child: const Text('Submit'),
              color: id_user == null ? Colors.grey : Colors.blue,
              disabledColor: Colors.grey,
            ),
          ],
        ),
      ),
    );
  }
}
