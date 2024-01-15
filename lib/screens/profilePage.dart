import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:ue1_basisprojekt/screens/home.dart';
import 'package:ue1_basisprojekt/screens/recipe.dart';
import 'package:ue1_basisprojekt/screens/search.dart';

class profil extends StatefulWidget {
  const profil({Key key}) : super(key: key);

  profilState createState() => profilState();
}

class profilState extends State<profil> {

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      //onWillPop: _onBackPress,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('My Account'),
          leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.push(
                  context, MaterialPageRoute(builder: (context) => homepage()));
            },
          ),
        ),
        body: SafeArea(
          child: Padding(
            padding: EdgeInsets.all(20.0),
            child: SingleChildScrollView(
child: Text ('hallo'),
            ),
          ),
        ),),
    );
  }
}

