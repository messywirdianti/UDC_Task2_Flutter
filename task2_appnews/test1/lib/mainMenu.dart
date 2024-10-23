import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:test1/viewTab/category.dart';
import 'package:test1/viewTab/home.dart';
import 'package:test1/viewTab/news.dart';
import 'package:test1/viewTab/profil.dart';

class MainMenu extends StatefulWidget {
  const MainMenu({super.key, required this.signOut});

  final VoidCallback signOut;


  @override
  State<MainMenu> createState() => _MainMenuState();
}

class _MainMenuState extends State<MainMenu> {
  signOut() {
    setState(() {
      widget.signOut();
    });
  }

  String username = "", email = "";

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getPref();
  }

  Future<void> getPref() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    setState(() {
      username = preferences.getString("username") ?? "";
      email = preferences.getString("email") ?? "";
    });
  }


  @override

  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        appBar: AppBar(
          actions: <Widget>[
            IconButton(
              onPressed: (){
                signOut();
                },
              icon: const Icon(Icons.lock_open),
            )
          ],
        ),
        body: const TabBarView(
          children: <Widget>[
            Home(),
            News(),
            CategoryPage(),
            Profil(),
          ],
          // child: Text("Username: $username, \n Email : $email"),
        ),

        bottomNavigationBar: const TabBar(
          labelColor: Colors.blue,
          unselectedLabelColor: Colors.grey,
          tabs: <Widget>[
            Tab(
              icon: Icon(Icons.home),
              text: "Home",
            ),
            Tab(
              icon: Icon(Icons.new_releases),
              text: "News",
            ),
            Tab(
              icon: Icon(Icons.category),
              text: "Category",
            ),
            Tab(
              icon: Icon(Icons.perm_contact_calendar),
              text: "Profile",
            ),
          ],
        ),
      ),
    );
  }
}
