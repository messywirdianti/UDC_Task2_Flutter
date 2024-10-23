import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:test1/constant/constrantFile.dart';
import 'package:http/http.dart' as http;
import '../constant/newsModel.dart';
import 'package:path/path.dart' as path;

class Editnews extends StatefulWidget {
  final NewsModel model;
  final VoidCallback relead;
  const Editnews({super.key, required this.model, required this.relead});

  @override
  State<Editnews> createState() => _EditnewsState();
}

class _EditnewsState extends State<Editnews> {
  final _key = GlobalKey<FormState>();
  File? _imageFile;
  String? title, content, description, id_users;
  TextEditingController? txtTitle, txtContent, txtDescription;

  // Setup function to load data from SharedPreferences and populate form fields
  setup() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    setState(() {
      id_users = preferences.getString("id_users");
    });

    txtTitle = TextEditingController(text: widget.model.title);
    txtContent = TextEditingController(text: widget.model.content);
    txtDescription = TextEditingController(text: widget.model.description);
  }

  // Check if the form is valid, and then submit if valid
  check() {
    final form = _key.currentState;
    if (form!.validate()) {
      form.save();
      submit();
    }
  }

  // Submit function to send data to the server
  submit() async {
    try {
      var uri = Uri.parse(BaseUrl.editNews);
      var request = http.MultipartRequest("POST", uri);

      // Ambil nilai langsung dari TextEditingController
      request.fields['title'] = txtTitle!.text;   // Menggunakan text dari controller
      request.fields['content'] = txtContent!.text;
      request.fields['description'] = txtDescription!.text;
      request.fields['id_users'] = id_users ?? '';
      request.fields['id_news'] = widget.model.id_news;

      if (_imageFile != null) {
        var stream = http.ByteStream(_imageFile!.openRead());
        var length = await _imageFile!.length();
        var multipartFile = http.MultipartFile(
          "image", stream, length, filename: path.basename(_imageFile!.path),
        );
        request.files.add(multipartFile);
      }

      var response = await request.send();
      var responseData = await response.stream.bytesToString();
      print("Response Data: $responseData");
      if (response.statusCode > 2) {
        print("Data berhasil diperbarui");
        setState(() {
          widget.relead();
          Navigator.pop(context);
        });
      } else {
        print("Gagal memperbarui data");
      }
    } catch (e) {
      debugPrint("Error: $e");
    }
  }




  // Function to select image from gallery
  _pilihGallery() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1000,
      maxHeight: 1920,
    );

    setState(() {
      if (image != null) {
        _imageFile = File(image.path);
      } else {
        print('Tidak ada gambar yang dipilih.');
      }
    });
  }

  @override
  void initState() {
    super.initState();
    setup();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: ListView(
        padding: EdgeInsets.all(15),
        children: <Widget>[
          Container(
            width: double.infinity,
            child: InkWell(
              onTap: () {
                _pilihGallery();
              },
              child: _imageFile == null
                  ? Image.network(BaseUrl.insertImage + widget.model.image)
                  : Image.file(_imageFile!, fit: BoxFit.fill),
            ),
          ),
          Form(
            key: _key,
            child: Column(
              children: <Widget>[
                TextFormField(
                  controller: txtTitle,
                  onSaved: (e) => title = e ?? '',
                  decoration: InputDecoration(labelText: 'Title'),
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Title cannot be empty';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: txtContent,
                  onSaved: (e) => content = e ?? '',
                  decoration: InputDecoration(labelText: 'Content'),
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Content cannot be empty';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: txtDescription,
                  onSaved: (e) => description = e ?? '',
                  decoration: InputDecoration(labelText: 'Description'),
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Description cannot be empty';
                    }
                    return null;
                  },
                ),
                MaterialButton(
                  onPressed: () {
                    check();
                  },
                  child: Text('Submit'),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}
