import 'dart:io';
import 'dart:math';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:ue1_basisprojekt/db/authentication.dart';
import 'package:ue1_basisprojekt/screens/allCreatedRecipes.dart';
import 'package:ue1_basisprojekt/screens/create.dart';
import 'package:ue1_basisprojekt/screens/profilePage.dart';
import 'package:ue1_basisprojekt/screens/recipe.dart';
import 'package:ue1_basisprojekt/screens/search.dart';
import 'package:provider/provider.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:hive/hive.dart';
import 'package:ue1_basisprojekt/screens/ListOfFavorites.dart';
import 'package:ue1_basisprojekt/screens/signIn.dart';
import 'package:auto_size_text/auto_size_text.dart';

class homepage extends StatefulWidget {
  const homepage({Key key}) : super(key: key);

  _homeState createState() => _homeState();
}

class _homeState extends State<homepage> {
  final ref = FirebaseDatabase.instance.reference().child('recipes/');
  var boxPushkeyHome = Hive.box('pushkeyHome');
  var favoriteRecipecodes = Hive.box('favoriteRecipecodes');

  List<String> name = [];
  List<String> imageurl = [];
  List<String> protein = [];
  List<String> carbs = [];
  List<String> fat = [];
  List<String> calories = [];

  List<String> allRecipeCodes = [];
  List<String> randomRecipeCodes = []; //12 Stück

  @override
  void initState() {
    super.initState();
    getAllRecipeCodes();
  }

  @override
  Widget build(BuildContext context) {
    final firebaseUser = context.watch<User>();

    if (firebaseUser == null) {
      return login();
    }
    Size size = MediaQuery.of(context).size;

    return WillPopScope(
      onWillPop: _onBackPress,
      child: Scaffold(
        drawer: NavigationDrawerWidget(),
        appBar: AppBar(
          title: const Text('FoodGenius'),
          actions: <Widget>[
            IconButton(
              icon: Icon(
                Icons.search,
              ),
              onPressed: () {
                Navigator.push(
                    context, MaterialPageRoute(builder: (context) => search()));
              },
            ),
            IconButton(
              icon: Icon(
                Icons.add,
              ),
              onPressed: () {
                Navigator.push(
                    context, MaterialPageRoute(builder: (context) => create()));
              },
            ),
          ],
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              children: <Widget>[
                InkWell(
                  onTap: () {
                    boxPushkeyHome.put('pushkeyHome', randomRecipeCodes[0]);
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) => recipe()));
                  },
                  child: Container(
                    height: 415,
                    child: Stack(
                        clipBehavior: Clip.none,
                        alignment: Alignment.center,
                        children: <Widget>[
                          Positioned(
                            //top: 0,
                            child: Container(
                              child: Column(
                                children: <Widget>[
                                  if (imageurl.length > 0) ...[
                                    Container(
                                      width: MediaQuery.of(context).size.width,
                                      height:
                                          MediaQuery.of(context).size.height *
                                              .40,
                                      child: Image.network(
                                        imageurl[0],
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
                          ),
                          Positioned(
                            top: MediaQuery.of(context).size.height * .37,
                            left: 15,
                            right: 15,
                            child: Card(
                              shadowColor: Color.fromRGBO(235, 222, 207, 1),
                              elevation: 8,
                              color: Color.fromRGBO(225, 212, 197, 1),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(15)),
                              child: Container(
                                width: MediaQuery.of(context).size.height * .90,
                                height: 100,
                                child: Padding(
                                  padding: EdgeInsets.all(20.0),
                                  child: Center(
                                    child: Text(
                                      (() {
                                        if (name.length > 0) {
                                          return name[0];
                                        } else {
                                          return "";
                                        }
                                      })(),
                                      style: TextStyle(fontSize: 20),
                                      maxLines: 3,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ]),
                  ),
                ),
                SizedBox(
                  height: 30.0,
                ),
                Padding(
                  padding: EdgeInsets.all(20.0),
                  child: Column(
                    children: <Widget>[
                      SingleChildScrollView(
                        child: Container(
                          height: size.height * 0.35,
                          child: ListView.builder(
                            shrinkWrap: true,
                            scrollDirection: Axis.horizontal,
                            itemCount: 5, // da nur 5 in Slider
                            itemBuilder: (context, index) {
                              return InkWell(
                                onTap: () {
                                  boxPushkeyHome.put('pushkeyHome',
                                      randomRecipeCodes[index + 1]);
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => recipe()));
                                },
                                child: Container(
                                  width: size.width * 0.3,
                                  margin: const EdgeInsets.all(10.0),
                                  child: Column(
                                    children: <Widget>[
                                      if (imageurl.length > 5) ...[
                                        Container(
                                          height: 200,
                                          width: 200,
                                          child: ClipRRect(
                                            borderRadius:
                                                BorderRadius.circular(15.0),
                                            child: Image.network(
                                              imageurl[index + 1],
                                              fit: BoxFit.cover,
                                            ),
                                          ),
                                        ),
                                      ] else ...[
                                        Container(),
                                      ],
                                      Padding(
                                        padding:
                                            const EdgeInsets.only(top: 10.0),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceEvenly,
                                          children: <Widget>[
                                            Expanded(
                                              child: Text(
                                                (() {
                                                  if (name.length > 5) {
                                                    return name[index + 1];
                                                  } else {
                                                    return "";
                                                  }
                                                })(),
                                                maxLines: 3,
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
                      ),
                      SizedBox(
                        height: 30.0,
                      ),
                      InkWell(
                        onTap: () {
                          boxPushkeyHome.put(
                              'pushkeyHome', randomRecipeCodes[6]);
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => recipe()));
                        },
                        child: Container(
                          child: Column(
                            children: [
                              Row(
                                children: <Widget>[
                                  if (imageurl.length > 6) ...[
                                    Expanded(
                                      flex: 5,
                                      child: Padding(
                                        padding: EdgeInsets.only(right: 20.0),
                                        child: Container(
                                          height: 200,
                                          width: size.width,
                                          child: ClipRRect(
                                            borderRadius:
                                                BorderRadius.circular(15.0),
                                            child: Image.network(
                                              imageurl[6],
                                              fit: BoxFit.cover,
                                              alignment: Alignment.center,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ] else ...[
                                    Container(),
                                  ],
                                  Expanded(
                                    flex: 5,
                                    child: Column(
                                      children: <Widget>[
                                              Text(
                                                (() {
                                                  if (name.length > 6) {
                                                    return name[6];
                                                  } else {
                                                    return "";
                                                  }
                                                })(),
                                                style: TextStyle(
                                                    fontWeight:
                                                    FontWeight.bold),
                                                maxLines: 5,
                                              ),
                                        SizedBox(
                                          height: 20.0,
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
                                                    if (protein.length > 6) {
                                                      return protein[6] + ' g';
                                                    } else {
                                                      return "";
                                                    }
                                                  })(),
                                                  style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold),
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
                                                    if (carbs.length > 6) {
                                                      return carbs[6] + ' g';
                                                    } else {
                                                      return "";
                                                    }
                                                  })(),
                                                  style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold),
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
                                                    if (fat.length > 6) {
                                                      return fat[6] + ' g';
                                                    } else {
                                                      return "";
                                                    }
                                                  })(),
                                                  style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold),
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
                                                    if (calories.length > 6) {
                                                      return calories[6] +
                                                          ' kcal';
                                                    } else {
                                                      return "";
                                                    }
                                                  })(),
                                                  style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold),
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
                            ],
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 30.0,
                      ),
                      Row(
                        children: <Widget>[
                          Text(
                            "Make This Today",
                            textAlign: TextAlign.left,
                            style: TextStyle(fontSize: 20),
                          ),
                          Spacer()
                        ],
                      ),
                      SizedBox(
                        height: 20.0,
                      ),
                      SingleChildScrollView(
                        child: Container(
                          height: size.height * 0.45,
                          child: ListView.builder(
                            shrinkWrap: true,
                            scrollDirection: Axis.horizontal,
                            itemCount: 5,
                            itemBuilder: (context, index) {
                              return InkWell(
                                onTap: () {
                                  boxPushkeyHome.put('pushkeyHome',
                                      randomRecipeCodes[index + 7]);
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => recipe()));
                                },
                                child: Container(
                                  width: size.width * 0.5,
                                  margin: const EdgeInsets.only(right: 20.0),
                                  child: Column(
                                    children: <Widget>[
                                      if (imageurl.length == 12) ...[
                                        Container(
                                          height: 300,
                                          width: size.width,
                                          child: ClipRRect(
                                            borderRadius:
                                                BorderRadius.circular(15.0),
                                            child: Image.network(
                                              imageurl[index + 7],
                                              fit: BoxFit.cover,
                                              alignment: Alignment.center,
                                            ),
                                          ),
                                        ),
                                      ] else ...[
                                        Container(),
                                      ],
                                      Padding(
                                        padding:
                                            const EdgeInsets.only(top: 20.0),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceEvenly,
                                          children: <Widget>[
                                            Expanded(
                                              child: Text(
                                                (() {
                                                  if (name.length == 12) {
                                                    return name[index + 7];
                                                  } else {
                                                    return "";
                                                  }
                                                })(),
                                                maxLines: 2,
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
                      ),


                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future getAllRecipeCodes() async {
    //Auslesen der Datenbankinhalte für die einzelnen Variablen(Textfelder)
    await ref.once().then((DataSnapshot snapshot) {
      snapshot.value.forEach((key, values) {
        setState(() {
          allRecipeCodes.add(key);
        });
      });
    });

    final random = new Random();
    for (int i = 0; i < 12; i++) {
      String randomRecipeCode =
          allRecipeCodes[random.nextInt(allRecipeCodes.length)];
      setState(() {
        randomRecipeCodes.add(randomRecipeCode);
      });
    }
    print('RANDOM RECIPE CODES');
    print(randomRecipeCodes);

    for (int i = 0; i < randomRecipeCodes.length; i++) {
      await ref
          .child(randomRecipeCodes[i])
          .once()
          .then((DataSnapshot snapshot) async {
        await ref
            .child(randomRecipeCodes[i])
            .child('name')
            .once()
            .then((DataSnapshot snapshot) {
          setState(() {
            name.add('${snapshot.value}');
          });
        });
        await ref
            .child(randomRecipeCodes[i])
            .child('imageurl')
            .once()
            .then((DataSnapshot snapshot) {
          setState(() {
            imageurl.add('${snapshot.value}');
          });
        });
        await ref
            .child(randomRecipeCodes[i])
            .child('protein')
            .once()
            .then((DataSnapshot snapshot) {
          setState(() {
            protein.add('${snapshot.value}');
          });
        });
        await ref
            .child(randomRecipeCodes[i])
            .child('carbs')
            .once()
            .then((DataSnapshot snapshot) {
          setState(() {
            carbs.add('${snapshot.value}');
          });
        });
        await ref
            .child(randomRecipeCodes[i])
            .child('fat')
            .once()
            .then((DataSnapshot snapshot) {
          setState(() {
            fat.add('${snapshot.value}');
          });
        });
        await ref
            .child(randomRecipeCodes[i])
            .child('calories')
            .once()
            .then((DataSnapshot snapshot) {
          setState(() {
            calories.add('${snapshot.value}');
          });
        });
      });
    }
  }

  Future<bool> _onBackPress() {
    return showDialog(
        context: context,
        builder: (context) => AlertDialog(
              title: Text("Do you really want to exit the app?"),
              actions: <Widget>[
                TextButton(
                    onPressed: () => Navigator.pop(context, false),
                    child: Text('No')),
                TextButton(
                    onPressed: () => exit(0),
                    // Navigator.pop(context, true),
                    child: Text('Yes')),
              ],
            ));
  }
}

class NavigationDrawerWidget extends StatelessWidget {
  final padding = EdgeInsets.symmetric(horizontal: 20);
  var favoriteRecipecodes = Hive.box('favoriteRecipecodes');
  var currentEmail = Hive.box('currentEmail');
  String userEmail = '';

  @override
  Widget build(BuildContext context) {
    return Drawer(
        child: Material(
          color: Color.fromRGBO(255, 242, 227, 1),
      child: ListView(
        children: <Widget>[
          const SizedBox(
            height: 28,
          ),
          Container(
            padding: padding.add(EdgeInsets.symmetric(vertical: 40)),
            child: Row(
              children: <Widget>[
                Icon(Icons.face_unlock_outlined, size: 40),
                SizedBox(
                  width: 20,
                ),
                Expanded(
                  child: AutoSizeText(
                    (() {
                      userEmail = currentEmail.get('currentEmail');
                      return '$userEmail';
                    })(), maxLines: 2, minFontSize: 17,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          ListTile(
            leading: Icon(Icons.favorite_border),
            title: Text('Favorites'),
            onTap: () => Navigator.push(
                context, MaterialPageRoute(builder: (context) => favorite())),
          ),
          const SizedBox(height: 16),
          ListTile(
            leading: Icon(Icons.search),
            title: Text('Search'),
            onTap: () => Navigator.push(
                context, MaterialPageRoute(builder: (context) => search())),
          ),
          const SizedBox(height: 16),
          ListTile(
            leading: Icon(Icons.add),
            title: Text('New recipe'),
            onTap: () => Navigator.push(
                context, MaterialPageRoute(builder: (context) => create())),
          ),
          const SizedBox(height: 16),
          ListTile(
            leading: Icon(Icons.article_outlined),
            title: Text('Created recipes'),
            onTap: () => Navigator.push(
                context, MaterialPageRoute(builder: (context) => allCreatedRecipes())),
          ),
          const SizedBox(height: 24),
          Divider(),
          const SizedBox(height: 24),
          const SizedBox(height: 16),
          ListTile(
            leading: Icon(
              Icons.logout,
            ),
            title: Text('Logout'),
            onTap: () async {
              //favoriteRecipecodes.clear();
              context.read<authentication>().signOut();
            },
          ),
        ],
      ),
    ));
  }
}
