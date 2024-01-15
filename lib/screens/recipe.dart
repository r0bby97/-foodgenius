import 'dart:async';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:ue1_basisprojekt/screens/allCreatedRecipes.dart';
import 'package:ue1_basisprojekt/screens/home.dart';
import 'package:ue1_basisprojekt/screens/ListOfFavorites.dart';
import 'package:ue1_basisprojekt/screens/searchResult.dart';

class recipe extends StatefulWidget {
  recipe({Key key}) : super(key: key);

  _recipeState createState() => _recipeState();
}

class _recipeState extends State<recipe> {
  final ref = FirebaseDatabase.instance.reference().child('recipes/');

  String recipeCode = "";
  var boxPushKey = Hive.box('pushkey');
  var boxPushkeySearchResult = Hive.box('pushkeySearchResult');
  var boxPushkeyHome = Hive.box('pushkeyHome');
  var favoriteRecipecodes = Hive.box('favoriteRecipecodes');
  var boxFavoritesToRecipe = Hive.box('pushkeyFavorites');
  var boxCurrentEmail = Hive.box('currentEmail');
  var boxAllCreatedRecipes = Hive.box('allCreatedRecipes');
  var boxPushkeyAllCreatedRecipes = Hive.box('pushkeyAllCreatedRecipes');

  String name;
  String protein;
  String carbs;
  String fat;
  String calories;
  String steps;
  String meat;
  String vegan;
  String vegetarian;
  String glutenfree;
  String lactosefree;
  String ingredients;
  String imageurl;
  String email;
  String currentLoggedInUserEmail;

  String buttonchoice;
  bool backToHame = false;
  bool backToFavorites = false;
  bool backToAllCreatedRecipes = false;
  bool backToResult = false;

  bool favoriteClicked = false;
  List<String> favoriteList = [];
  List<String> allCreatedRecipesList = [];

  @override
  void initState() {
    super.initState();
    getDataFromFirebase();
    fillFavoriteClicked();
  }

  @override
  Widget build(BuildContext context) {
    var stepsTile = new ListTile(
      title: new Text('$steps'),
    );
    var ingredientsTile = new ListTile(
      title: new Text('$ingredients'),
    );

    return WillPopScope(
      onWillPop: _onBackPress,
      child: Scaffold(
        appBar: AppBar(
          title: Text('$name'),
          leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () {
              if (backToHame == true) {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => homepage()));
              } else if (backToResult == true) {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => searchResult()));
              } else if (backToFavorites == true) {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => favorite()));
              } else if (backToAllCreatedRecipes == true) {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => allCreatedRecipes()));
              }
            },
          ),
          actions: [
            if (favoriteClicked == false) ...[
              IconButton(
                icon: Icon(
                  Icons.favorite_border,
                ),
                onPressed: () {
                  setState(() {
                    favoriteClicked = true;
                    if (recipeCode != null) {
                      if (favoriteRecipecodes
                              .get("$currentLoggedInUserEmail") !=
                          null) {
                        favoriteList = favoriteRecipecodes
                            .get("$currentLoggedInUserEmail");
                      }
                      favoriteList.add(recipeCode);
                      favoriteRecipecodes.put(
                          "$currentLoggedInUserEmail", favoriteList);
                      print(
                          '--------------Favorite Recipecode add______________');
                      print(favoriteList);
                    }
                  });
                },
              ),
            ] else ...[
              IconButton(
                icon: Icon(
                  Icons.favorite,
                ),
                onPressed: () {
                  setState(() {
                    favoriteClicked = false;
                    if (recipeCode != null) {
                      if (favoriteRecipecodes
                              .get("$currentLoggedInUserEmail") !=
                          null) {
                        favoriteList = favoriteRecipecodes
                            .get("$currentLoggedInUserEmail");
                      }
                      for (int i = 0; i < favoriteList.length; i++) {
                        if (favoriteList[i] == recipeCode) {
                          favoriteList.removeAt(i);
                          i--;
                        }
                      }
                      favoriteRecipecodes.put(
                          "$currentLoggedInUserEmail", favoriteList);
                      print(
                          '--------------Favorite Recipecode delete______________');
                      print(favoriteList);
                    }
                  });
                },
              ),
            ],
            IconButton(
              icon: Icon(
                Icons.home,
              ),
              onPressed: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => homepage()));
              },
            ),
            if (currentLoggedInUserEmail == email) ...[
              IconButton(
                icon: Icon(
                  Icons.delete,
                ),
                onPressed: () {
                  // Gelöschtes Element muss auch aus der Favoritenliste gelöscht werden.
                  if (favoriteRecipecodes.get("$currentLoggedInUserEmail") !=
                      null) {
                    favoriteList =
                        favoriteRecipecodes.get("$currentLoggedInUserEmail");
                  }
                  for (int i = 0; i < favoriteList.length; i++) {
                    if (favoriteList[i] == recipeCode) {
                      favoriteList.removeAt(i);
                      i--;
                    }
                  }
                  favoriteRecipecodes.put(
                      "$currentLoggedInUserEmail", favoriteList);

                  // Gelöschtes Element muss auch aus allCreatedRecipes entfernt werden.
                  if (boxAllCreatedRecipes.get("$currentLoggedInUserEmail") !=
                      null) {
                    allCreatedRecipesList =
                        boxAllCreatedRecipes.get("$currentLoggedInUserEmail");
                  }
                  for (int i = 0; i < allCreatedRecipesList.length; i++) {
                    if (allCreatedRecipesList[i] == recipeCode) {
                      allCreatedRecipesList.removeAt(i);
                      i--;
                    }
                  }
                  boxAllCreatedRecipes.put(
                      "$currentLoggedInUserEmail", allCreatedRecipesList);

                  // Lösche Datensatz aus Rezeptliste
                  ref.child(recipeCode).remove();

                  // Anschließend kehrt er zur Hompage zurück (mit ToastMessage)
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) => homepage()));

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      backgroundColor: Colors.green,
                      content: Text(
                        'Successfully deleted the recipe.',
                        style: TextStyle(
                          color: Colors.white,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ]
          ],
        ),
        body: SafeArea(
          child: new SingleChildScrollView(
            child: Column(
              children: <Widget>[
                Stack(
                  alignment: Alignment.center,
                  children: <Widget>[
                    Container(
                      child: Column(
                        children: <Widget>[
                          if (imageurl != null) ...[
                            Container(
                              width: MediaQuery.of(context).size.width,
                              height: MediaQuery.of(context).size.height * .40,
                              child: Image.network(
                                imageurl.replaceAll('////', '//'),
                                fit: BoxFit.fitWidth,
                                alignment: Alignment.center,
                              ),
                            )
                          ] else ...[
                            Container(),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: SingleChildScrollView(
                    child: Center(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: <Widget>[
                          if (meat == 'true') ...[
                            Card(
                              color: Color.fromRGBO(225, 212, 197, 1),
                              child: Padding(
                                padding: const EdgeInsets.all(15.0),
                                child: Text('Meat'),
                              ),
                            ),
                          ],
                          if (vegan == 'true') ...[
                            Card(
                              color: Color.fromRGBO(225, 212, 197, 1),
                              child: Padding(
                                padding: const EdgeInsets.all(15.0),
                                child: Text('Vegan'),
                              ),
                            ),
                          ],
                          if (vegetarian == 'true') ...[
                            Card(
                              color: Color.fromRGBO(225, 212, 197, 1),
                              child: Padding(
                                padding: const EdgeInsets.all(15.0),
                                child: Text('Vegetarian'),
                              ),
                            ),
                          ],
                          if (glutenfree == 'true') ...[
                            Card(
                              color: Color.fromRGBO(225, 212, 197, 1),
                              child: Padding(
                                padding: const EdgeInsets.all(15.0),
                                child: Text('Glutenfree'),
                              ),
                            ),
                          ],
                          if (lactosefree == 'true') ...[
                            Card(
                              color: Color.fromRGBO(225, 212, 197, 1),
                              child: Padding(
                                padding: const EdgeInsets.all(15.0),
                                child: Text('Lactosefree'),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ),
                Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(15.0),
                      child: Text(
                        'Nutrition',
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(
                          left: 15.0, right: 15, bottom: 8),
                      child: Card(
                        color: Color.fromRGBO(225, 212, 197, 1),
                        child: Padding(
                          padding: const EdgeInsets.all(15.0),
                          child: Row(
                            children: [
                              Expanded(
                                flex: 5,
                                child: Container(
                                  height: 24,
                                  child: Stack(
                                      children: <Widget>[Text('Protein')]),
                                ),
                              ),
                              Expanded(
                                flex: 5,
                                child: Container(
                                  height: 24,
                                  child: Stack(children: <Widget>[
                                    Text(
                                      '$protein' + ' g',
                                    )
                                  ]),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding:
                          const EdgeInsets.only(left: 15, right: 15, bottom: 8),
                      child: Card(
                        color: Color.fromRGBO(225, 212, 197, 1),
                        child: Padding(
                          padding: const EdgeInsets.all(15.0),
                          child: Row(
                            children: [
                              Expanded(
                                flex: 5,
                                child: Container(
                                  height: 24,
                                  child: Stack(children: <Widget>[
                                    Text(
                                      'Carbs',
                                    )
                                  ]),
                                ),
                              ),
                              Expanded(
                                flex: 5,
                                child: Container(
                                  height: 24,
                                  child: Stack(children: <Widget>[
                                    Text(
                                      '$carbs' + ' g',
                                    )
                                  ]),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding:
                          const EdgeInsets.only(left: 15, right: 15, bottom: 8),
                      child: Card(
                        color: Color.fromRGBO(225, 212, 197, 1),
                        child: Padding(
                          padding: const EdgeInsets.all(15.0),
                          child: Row(
                            children: [
                              Expanded(
                                flex: 5,
                                child: Container(
                                  height: 24,
                                  child: Stack(children: <Widget>[
                                    Text(
                                      'Fat',
                                    )
                                  ]),
                                ),
                              ),
                              Expanded(
                                flex: 5,
                                child: Container(
                                  height: 24,
                                  child: Stack(children: <Widget>[
                                    Text(
                                      '$fat' + ' g',
                                    )
                                  ]),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(
                          left: 15, right: 15, bottom: 15),
                      child: Card(
                        color: Color.fromRGBO(225, 212, 197, 1),
                        child: Padding(
                          padding: const EdgeInsets.all(15.0),
                          child: Row(
                            children: [
                              Expanded(
                                flex: 5,
                                child: Container(
                                  height: 24,
                                  child: Stack(children: <Widget>[
                                    Text(
                                      'Calories',
                                    )
                                  ]),
                                ),
                              ),
                              Expanded(
                                flex: 5,
                                child: Container(
                                  height: 24,
                                  child: Stack(children: <Widget>[
                                    Text(
                                      '$calories' + ' kcal',
                                    )
                                  ]),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(15.0),
                      child: Text(
                        'Ingredients',
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                    ),
                    Row(
                      children: [
                        Expanded(
                          flex: 9,
                          child: Padding(
                            padding: const EdgeInsets.only(
                                left: 15, right: 15, bottom: 15),
                            child: Card(
                              color: Color.fromRGBO(225, 212, 197, 1),
                              child: Padding(
                                  padding: const EdgeInsets.all(20.0),
                                  child: Text('$ingredients')),
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 0,
                          child: Text(' '),
                        ),
                      ],
                    ),
                  ],
                ),
                Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(15.0),
                      child: Text(
                        'Steps',
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                    ),
                    Row(
                      children: [
                        Expanded(
                          flex: 9,
                          child: Padding(
                            padding: const EdgeInsets.only(
                                left: 15, right: 15, bottom: 15),
                            child: Card(
                              color: Color.fromRGBO(225, 212, 197, 1),
                              child: Padding(
                                  padding: const EdgeInsets.all(20.0),
                                  child: Text('$steps')),
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 0,
                          child: Text(' '),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  getDataFromFirebase() {
    if (boxPushKey.get('pushkey') != null) {
      print('CREATE PUSHKEY USED');
      recipeCode = boxPushKey.get('pushkey');
      backToHame = true;
    } else if (boxPushkeySearchResult.get('pushkeySearchResult') != null) {
      print('SEARCH RESULT PUSHKEY USED');
      recipeCode = boxPushkeySearchResult.get('pushkeySearchResult');
      backToResult = true;
    } else if (boxPushkeyHome.get('pushkeyHome') != null) {
      print('HOME PUSHKEY USED');
      recipeCode = boxPushkeyHome.get('pushkeyHome');
      backToHame = true;
    } else if (boxFavoritesToRecipe.get('pushkeyFavorites') != null) {
      recipeCode = boxFavoritesToRecipe.get('pushkeyFavorites');
      backToFavorites = true;
    } else if (boxPushkeyAllCreatedRecipes.get('pushkeyAllCreatedRecipes') !=
        null) {
      recipeCode = boxPushkeyAllCreatedRecipes.get('pushkeyAllCreatedRecipes');
      backToAllCreatedRecipes = true;
    }

    print('RECIPEPUSHKEYYYY');
    print(recipeCode);

    setState(() {
      currentLoggedInUserEmail = boxCurrentEmail.get(('currentEmail'));
    });

    //Auslesen der Datenbankinhalte für die einzelnen Variablen(Textfelder)
    ref.child(recipeCode).child('name').once().then((DataSnapshot snapshot) {
      setState(() {
        name = '${snapshot.value}';
      });
    });
    ref
        .child(recipeCode)
        .child('imageurl')
        .once()
        .then((DataSnapshot snapshot) {
      setState(() {
        imageurl = '${snapshot.value}';
      });
    });
    ref.child(recipeCode).child('protein').once().then((DataSnapshot snapshot) {
      setState(() {
        protein = '${snapshot.value}';
      });
    });
    ref.child(recipeCode).child('carbs').once().then((DataSnapshot snapshot) {
      setState(() {
        carbs = '${snapshot.value}';
      });
    });
    ref.child(recipeCode).child('fat').once().then((DataSnapshot snapshot) {
      setState(() {
        fat = '${snapshot.value}';
      });
    });
    ref
        .child(recipeCode)
        .child('calories')
        .once()
        .then((DataSnapshot snapshot) {
      setState(() {
        calories = '${snapshot.value}';
      });
    });
    ref.child(recipeCode).child('steps').once().then((DataSnapshot snapshot) {
      setState(() {
        steps = '${snapshot.value}';
      });
    });
    ref.child(recipeCode).child('meat').once().then((DataSnapshot snapshot) {
      setState(() {
        meat = '${snapshot.value}';
      });
    });
    ref.child(recipeCode).child('vegan').once().then((DataSnapshot snapshot) {
      setState(() {
        vegan = '${snapshot.value}';
      });
    });
    ref
        .child(recipeCode)
        .child('vegetarian')
        .once()
        .then((DataSnapshot snapshot) {
      setState(() {
        vegetarian = '${snapshot.value}';
      });
    });
    ref
        .child(recipeCode)
        .child('glutenfree')
        .once()
        .then((DataSnapshot snapshot) {
      setState(() {
        glutenfree = '${snapshot.value}';
      });
    });
    ref
        .child(recipeCode)
        .child('lactosefree')
        .once()
        .then((DataSnapshot snapshot) {
      setState(() {
        lactosefree = '${snapshot.value}';
      });
    });
    ref
        .child(recipeCode)
        .child('ingredients')
        .once()
        .then((DataSnapshot snapshot) {
      setState(() {
        ingredients = '${snapshot.value}';
      });
    });
    ref.child(recipeCode).child('email').once().then((DataSnapshot snapshot) {
      setState(() {
        email = '${snapshot.value}';
      });
    });
    boxPushKey.clear();
    boxPushkeySearchResult.clear();
    boxPushkeyHome.clear();
    boxFavoritesToRecipe.clear();
  }

  Future<bool> _onBackPress() {
    if (backToHame == true) {
      Navigator.push(
          context, MaterialPageRoute(builder: (context) => homepage()));
    } else if (backToResult == true) {
      Navigator.push(
          context, MaterialPageRoute(builder: (context) => searchResult()));
    } else if (backToFavorites == true) {
      Navigator.push(
          context, MaterialPageRoute(builder: (context) => favorite()));
    } else if (backToAllCreatedRecipes == true) {
      Navigator.push(context,
          MaterialPageRoute(builder: (context) => allCreatedRecipes()));
    }
  }

  fillFavoriteClicked() {
    if (favoriteRecipecodes.get("$currentLoggedInUserEmail") != null) {
      favoriteList = favoriteRecipecodes.get("$currentLoggedInUserEmail");
      for (int i = 0; i < favoriteList.length; i++) {
        if (favoriteList[i] == recipeCode) {
          setState(() {
            favoriteClicked = true;
          });
        }
      }
    }
  }
}
