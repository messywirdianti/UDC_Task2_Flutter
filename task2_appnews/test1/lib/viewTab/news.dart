import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:test1/constant/constrantFile.dart';
import 'package:test1/viewTab/editNews.dart';
import '../constant/newsModel.dart';
import 'addNews.dart';

class News extends StatefulWidget {
  const News({super.key});

  @override
  State<News> createState() => _NewsState();
}

class _NewsState extends State<News> {
  final List<NewsModel> list = [];
  var loading = false;

  Future _lihatData() async {
    list.clear();
    setState(() {
      loading = true;
    });

    final response = await http.get(Uri.parse(BaseUrl.detailNews));

    if (response.contentLength == 2) {
      // Data kosong
    } else {
      final data = jsonDecode(response.body);
      data.forEach((api) {
        final ab = NewsModel(
          id_news: api['id_news'],
          image: api['image'],
          title: api['title'],
          content: api['content'],
          description: api['description'],
          date_news: api['date_news'],
          id_users: api['id_users'],
          username: api['username'],
        );
        list.add(ab);
      });
    }

    setState(() {
      loading = false;
    });
  }

  _delete(String id_news) async {
    final response = await http.post(
      Uri.parse(BaseUrl.deleteNews),
      body: {
        "id_news": id_news,
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['value'] == 1) {
        // Successfully deleted
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('News deleted successfully')),
        );
        await _lihatData(); // Refresh the list
      } else {
        // Deletion failed
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to delete news: ${data['message']}')),
        );
      }
    } else {
      // Handle other status codes
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${response.statusCode}')),
      );
    }
  }


  @override
  void initState() {
    super.initState();
    _lihatData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context)
              .push(MaterialPageRoute(builder: (context) => Addnews()));
        },
        child: const Icon(Icons.add),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await _lihatData();
        },
        child: loading
            ? const Center(child: CircularProgressIndicator())
            : ListView.builder(
          itemCount: list.length,
          itemBuilder: (context, i) {
            final x = list[i];
            return Container(
              margin: const EdgeInsets.all(8.0),
              padding: const EdgeInsets.all(8.0),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 5.0,
                    spreadRadius: 2.0,
                  )
                ],
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Flexible(
                    child: Image.network(
                      BaseUrl.insertImage + x.image,
                      width: 120,
                      height: 130,
                      fit: BoxFit.fill,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          x.title,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          x.date_news,
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          x.description,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Colors.black54,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: (){
                      Navigator.of(context).push(MaterialPageRoute(builder: (context) => Editnews(model: x, relead: () { _lihatData(); },)));
                    },
                    icon: Icon(Icons.edit),
                  ),
                  IconButton(
                    onPressed: (){
                      _delete(x.id_news);
                    },
                    icon: Icon(Icons.delete),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
