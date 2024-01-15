import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:hive/hive.dart';
import 'package:ue1_basisprojekt/screens/home.dart';
import 'package:ue1_basisprojekt/screens/recipe.dart';
import 'package:ue1_basisprojekt/screens/search.dart';

class searchResult extends StatefulWidget {
  const searchResult({Key key}) : super(key: key);

  _resultState createState() => _resultState();
}

class _resultState extends State<searchResult> {
  final ref = FirebaseDatabase.instance.reference().child('recipes/');

  var boxSearchResult = Hive.box('searchResults');
  var boxPushkeySearchResult = Hive.box('pushkeySearchResult');

  List<String> name = [];
  List<String> protein = [];
  List<String> carbs = [];
  List<String> fat = [];
  List<String> calories = [];
  List<String> imageurl = [];

  List<String> recipeCode = [];

  @override
  void initState() {
    super.initState();
    getDataFromFirebase();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onBackPress,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Search'),
          leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.push(
                  context, MaterialPageRoute(builder: (context) => search()));
            },
          ),
          actions: <Widget>[
            IconButton(
              icon: Icon(
                Icons.home,
              ),
              onPressed: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => homepage()));
              },
            ),
          ],
        ),
        body: SafeArea(
            child: SingleChildScrollView(
              child: Column(
                children: <Widget>[
                  if (recipeCode.length != 0) ...[
                    //Anzeigen der Liste (Suchergebnisse)
                    SingleChildScrollView(
                      child: ListView.builder(
                        physics: NeverScrollableScrollPhysics(),
                        shrinkWrap: true,
                        scrollDirection: Axis.vertical,
                        itemCount: recipeCode.length,
                        itemBuilder: (context, index) {
                          return InkWell(
                            onTap: () {
                              boxPushkeySearchResult.put(
                                  'pushkeySearchResult', recipeCode[index]);
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => recipe()));
                            },
                            child: Container(
                              child: Column(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(left: 30.0, right: 30, bottom: 20, top: 20),
                                    child: Row(
                                      children: <Widget>[
                                        Expanded(
                                          flex: 5,
                                          child: Padding(
                                            padding: const EdgeInsets.only(
                                                right: 10.0),
                                            child: Column(
                                              children: <Widget>[
                                                if (recipeCode.length ==
                                                    imageurl.length) ...[
                                                  ClipRRect(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            15.0),
                                                    child: Container(
                                                      height: 200,
                                                      width: 200,
                                                      child: Image.network(
                                                        imageurl[index],
                                                        fit: BoxFit.cover,
                                                        alignment:
                                                            Alignment.center,
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ],
                                            ),
                                          ),
                                        ),
                                        Expanded(
                                          flex: 5,
                                          child: Column(
                                            children: <Widget>[
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceEvenly,
                                                children: <Widget>[
                                                  Expanded(
                                                    child: Text(
                                                      (() {
                                                        if (recipeCode.length ==
                                                            name.length) {
                                                          return name[index];
                                                        } else {
                                                          return "";
                                                        }
                                                      })(),
                                                      style: TextStyle(
                                                          fontWeight:
                                                              FontWeight.bold),
                                                      maxLines: 4,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              SizedBox(
                                                height: 10,
                                              ),
                                              Row(
                                                children: [
                                                  Expanded(
                                                    // flex: 5,
                                                    child: Container(
                                                      height: 24,
                                                      child: Text('Protein'),
                                                    ),
                                                  ),
                                                  Expanded(
                                                    // flex: 5,
                                                    child: Container(
                                                      height: 24,
                                                      child: Text(
                                                        (() {
                                                          if (recipeCode
                                                                  .length ==
                                                              protein.length) {
                                                            return protein[
                                                                    index] +
                                                                ' g';
                                                          } else {
                                                            return "";
                                                          }
                                                        })(),
                                                        style: TextStyle(
                                                            fontWeight:
                                                                FontWeight
                                                                    .bold),
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              Row(
                                                children: [
                                                  Expanded(
                                                    //flex: 5,
                                                    child: Container(
                                                        height: 24,
                                                        child: Text(
                                                          'Carbs',
                                                        )),
                                                  ),
                                                  Expanded(
                                                    //flex: 5,
                                                    child: Container(
                                                      height: 24,
                                                      child: Text(
                                                        (() {
                                                          if (recipeCode
                                                                  .length ==
                                                              carbs.length) {
                                                            return carbs[
                                                                    index] +
                                                                ' g';
                                                          } else {
                                                            return "";
                                                          }
                                                        })(),
                                                        style: TextStyle(
                                                            fontWeight:
                                                                FontWeight
                                                                    .bold),
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              Row(
                                                children: [
                                                  Expanded(
                                                    //flex: 5,
                                                    child: Container(
                                                        height: 24,
                                                        child: Text(
                                                          'Fat',
                                                        )),
                                                  ),
                                                  Expanded(
                                                    //flex: 5,
                                                    child: Container(
                                                      height: 24,
                                                      child: Text(
                                                        (() {
                                                          if (recipeCode
                                                                  .length ==
                                                              fat.length) {
                                                            return fat[index] +
                                                                ' g';
                                                          } else {
                                                            return "";
                                                          }
                                                        })(),
                                                        style: TextStyle(
                                                            fontWeight:
                                                                FontWeight
                                                                    .bold),
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              Row(
                                                children: [
                                                  Expanded(
                                                    //flex: 5,
                                                    child: Container(
                                                        height: 24,
                                                        child: Text(
                                                          'Calories',
                                                        )),
                                                  ),
                                                  Expanded(
                                                    //flex: 5,
                                                    child: Container(
                                                      height: 24,
                                                      child: Text(
                                                        (() {
                                                          if (recipeCode
                                                                  .length ==
                                                              calories.length) {
                                                            return calories[
                                                                    index] +
                                                                ' kcal';
                                                          } else {
                                                            return "";
                                                          }
                                                        })(),
                                                        style: TextStyle(
                                                            fontWeight:
                                                                FontWeight
                                                                    .bold),
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ] else ...[
                    Padding(
                      padding: EdgeInsets.all(20.0),
                      child: Card(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            ListTile(
                              title: Padding(
                                padding: const EdgeInsets.only(
                                    bottom: 15.0, top: 15.0),
                                child: Text("No Search Results."),
                              ),
                              subtitle: Text(
                                  "Go back to the homepage and and get inspired."),
                            ),
                            TextButton(
                              child: const Text('Homepage'),
                              onPressed: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => homepage()));
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
    );
  }

  Future getDataFromFirebase() {
    recipeCode = boxSearchResult.get('searchResults');

    if (recipeCode.length != 0) {
      for (int i = 0; i < recipeCode.length; i++) {
        //Auslesen der Datenbankinhalte für die einzelnen Variablen(Textfelder)
        ref
            .child(recipeCode[i])
            .child('imageurl')
            .once()
            .then((DataSnapshot snapshot) {
          setState(() {
            imageurl.add('${snapshot.value}');
          });
        });
        ref
            .child(recipeCode[i])
            .child('name')
            .once()
            .then((DataSnapshot snapshot) {
          setState(() {
            name.add('${snapshot.value}');
          });
        });
        ref
            .child(recipeCode[i])
            .child('protein')
            .once()
            .then((DataSnapshot snapshot) {
          setState(() {
            protein.add('${snapshot.value}');
          });
        });
        ref
            .child(recipeCode[i])
            .child('carbs')
            .once()
            .then((DataSnapshot snapshot) {
          setState(() {
            carbs.add('${snapshot.value}');
          });
        });
        ref
            .child(recipeCode[i])
            .child('fat')
            .once()
            .then((DataSnapshot snapshot) {
          setState(() {
            fat.add('${snapshot.value}');
          });
        });
        ref
            .child(recipeCode[i])
            .child('calories')
            .once()
            .then((DataSnapshot snapshot) {
          setState(() {
            calories.add('${snapshot.value}');
          });
        });
      }
    }
  }

  Future<bool> _onBackPress() {
    Navigator.push(context, MaterialPageRoute(builder: (context) => search()));
  }
}
