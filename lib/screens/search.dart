import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:ue1_basisprojekt/screens/home.dart';
import 'package:ue1_basisprojekt/screens/searchResult.dart';

class search extends StatefulWidget {
  const search({Key key}) : super(key: key);

  @override
  State createState() => _searchState();
}

class _searchState extends State<search> {
  final ref = FirebaseDatabase.instance.reference().child('recipes/');

  var boxSearchResult = Hive.box('searchResults');
  var boxLastButtonClicked = Hive.box('lastButtonClicked');

  List<String> databaseKeys = [];
  List<String> databaseValues = [];
  List<String> comparedData = [];

  //Listen zur Ermittlung der RecipeCode Schnittmengen
  List<String> nameList = [];
  List<String> meatList = [];
  List<String> meatGlutenList = [];
  List<String> meatLactoseList = [];
  List<String> meatGlutenLactoseList = [];
  List<String> veganList = [];
  List<String> veganGlutenList = [];
  List<String> vegetarianList = [];
  List<String> vegetarianGlutenList = [];
  List<String> vegetarianLactoseList = [];
  List<String> vegetarianGlutenLactoseList = [];
  List<String> glutenList = [];
  List<String> glutenLactoseList = [];
  List<String> lactoseList = [];
  List<String> caloriesLessList = [];
  List<String> caloriesGreaterList = [];
  List<String> proteinLessList = [];
  List<String> proteinGreaterList = [];
  List<String> carbsLessList = [];
  List<String> carbsGreaterList = [];
  List<String> fatLessList = [];
  List<String> fatGreaterList = [];

  List<List<String>> databaseSearchResult = [];

  List<bool> _selections = List.generate(
      3, (_) => false); //Liste für Auswahl: Meat, Vegan, Vegetarian
  List<bool> _selectionsfree = List.generate(
      2, (_) => false); //Liste für Auswahl: Glutenfree, Lactosefree
  List<bool> _selectionsAmountCalories = List.generate(2, (_) => false);
  List<bool> _selectionsAmountCarbs = List.generate(2, (_) => false);
  List<bool> _selectionsAmountProtein = List.generate(2, (_) => false);
  List<bool> _selectionsAmountFat = List.generate(2, (_) => false);

  TextEditingController _name = TextEditingController();
  TextEditingController _calories = TextEditingController();
  TextEditingController _protein = TextEditingController();
  TextEditingController _carbs = TextEditingController();
  TextEditingController _fat = TextEditingController();

  bool caloriesLess;
  bool caloriesGreater;
  bool proteinLess;
  bool proteinGreater;
  bool carbsLess;
  bool carbsGreater;
  bool fatLess;
  bool fatGreater;

  String name;
  bool meat;
  bool vegan;
  bool vegetarian;
  bool glutenfree;
  bool lactosefree;
  int calories;
  int protein;
  int carbs;
  int fat;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onBackPress,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Search for a recipe'),
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
            padding: const EdgeInsets.all(20.0),
            child: new SingleChildScrollView(
              child: new Column(
                children: <Widget>[
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 15, vertical: 16),
                    child: TextFormField(
                      controller: _name,
                      decoration: const InputDecoration(
                        border: UnderlineInputBorder(),
                        labelText: 'Search for the name',
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(top: 16),
                    child: ToggleButtons(
                      selectedColor: Colors.black,
                      fillColor: Colors.black12,
                      renderBorder: false,
                      //borderRadius: BorderRadius.circular(10.0),
                      children: <Widget>[
                        Padding(
                          padding: const EdgeInsets.only(right: 25,left: 25,top: 15, bottom: 15,),
                          child: Text('Meat'),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(right: 25,left: 25,top: 15, bottom: 15,),
                          child: Text('Vegan'),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(right: 25,left: 25,top: 15, bottom: 15,),
                          child: Text('Vegetarian'),
                        ),
                      ],
                      isSelected: _selections,
                      onPressed: (int index) {

                        setState(() {

                          _selections[0] = false;
                          _selections[1] = false;
                          _selections[2] = false;

                          if(boxLastButtonClicked.get('lastButtonClicked') != null) {
                            int oldIndex = boxLastButtonClicked.get(
                                'lastButtonClicked');
                            if(oldIndex == index) {
                              if (oldIndex == 1) {
                                _selectionsfree[1] = false;
                                _selections[oldIndex] = true;
                                _selectionsfree[1] = true;
                              } else {
                                _selections[oldIndex] = true;
                              }
                            }
                            boxLastButtonClicked.clear();
                          }
                          //Sorgt für Statusänderung des geklickten Buttons
                          _selections[index] = !_selections[index];

                          boxLastButtonClicked.put('lastButtonClicked', index);

                          //Meat
                          if (_selections[0] == true) {
                            _selections[1] = false; //Vegan
                            _selections[2] = false; //Vegetarian
                          }
                          //Vegan
                          if (_selections[1] == true) {
                            _selections[0] = false; //Meat
                            _selectionsfree[1] = true; //Lactose (andere Liste)
                            _selections[2] = false; //Vegetarian
                          }
                          //Vegetarisch
                          if (_selections[2] == true) {
                            _selections[0] = false; //Meat
                            _selections[1] = false; //Vegan
                          }
                        });
                      },
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(top: 10, bottom: 16),
                    child: ToggleButtons(
                      selectedColor: Colors.black,
                      fillColor: Colors.black12,
                      renderBorder: false,
                      children: <Widget>[
                        Padding(
                          padding: const EdgeInsets.only(right: 25,left: 25,top: 15, bottom: 15,),
                          child: Text('Gluten free'),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(right: 25,left: 25,top: 15, bottom: 15,),
                          child: Text('Lactose free'),
                        ),
                      ],
                      isSelected: _selectionsfree,
                      onPressed: (int index) {
                        setState(() {
                          //Sorgt für Statusänderung des geklickten Buttons
                          _selectionsfree[index] = !_selectionsfree[index];

                          if (_selectionsfree[1] == false) {
                            _selections[1] = false;
                          }
                        });
                      },
                    ),
                  ),
                  new Container(
                    child: new Column(
                      children: <Widget>[
                        Card(
                          color: Color.fromRGBO(225, 212, 197, 1),
                          child: Padding(
                            padding:
                                EdgeInsets.symmetric(horizontal: 20, vertical: 6),
                            child: Center(
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                children: <Widget>[
                                  Expanded(
                                    flex: 3,
                                    child: Text(
                                      'Calories',
                                      style: TextStyle(fontSize: 15),
                                    ),
                                  ),
                                  Expanded(
                                    flex: 3,
                                    child: ToggleButtons(
                                      selectedColor: Colors.black,
                                      fillColor: Colors.black12,
                                      renderBorder: false,
                                      children: <Widget>[
                                        Padding(
                                          padding: const EdgeInsets.all(1),
                                          child: Text('<'),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.all(1),
                                          child: Text('>'),
                                        ),
                                      ],
                                      isSelected: _selectionsAmountCalories,
                                      onPressed: (int index) {
                                        setState(() {
                                          //Sorgt für Statusänderung des geklickten Buttons
                                          _selectionsAmountCalories[index] =
                                              !_selectionsAmountCalories[index];

                                          if (_selectionsAmountCalories[0] ==
                                              true) {
                                            _selectionsAmountCalories[1] = false;
                                          }
                                          if (_selectionsAmountCalories[1] ==
                                              true) {
                                            _selectionsAmountCalories[0] = false;
                                          }
                                        });
                                      },
                                    ),
                                  ),
                                  Expanded(
                                    flex: 3,
                                    child: TextField(
                                      keyboardType: TextInputType.number,
                                      controller: _calories,
                                      style: TextStyle(fontSize: 15),
                                      decoration: InputDecoration(
                                          labelText: 'Amount',
                                          suffixText: 'kcal',
                                          counter: Offstage()),
                                      maxLength: 6,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        Card(
                          color: Color.fromRGBO(225, 212, 197, 1),
                          child: Padding(
                            padding:
                                EdgeInsets.symmetric(horizontal: 20, vertical: 6),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: <Widget>[
                                Expanded(
                                  flex: 3,
                                  child: Text(
                                    'Protein',
                                    style: TextStyle(fontSize: 15),
                                  ),
                                ),
                                Expanded(
                                  flex: 3,
                                  child: ToggleButtons(
                                    selectedColor: Colors.black,
                                    fillColor: Colors.black12,
                                    renderBorder: false,
                                    children: <Widget>[
                                      Padding(
                                        padding: const EdgeInsets.all(1),
                                        child: Text('<'),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.all(1),
                                        child: Text('>'),
                                      ),
                                    ],
                                    isSelected: _selectionsAmountProtein,
                                    onPressed: (int index) {
                                      setState(() {
                                        //Sorgt für Statusänderung des geklickten Buttons
                                        _selectionsAmountProtein[index] =
                                            !_selectionsAmountProtein[index];

                                        if (_selectionsAmountProtein[0] == true) {
                                          _selectionsAmountProtein[1] = false;
                                        }
                                        if (_selectionsAmountProtein[1] == true) {
                                          _selectionsAmountProtein[0] = false;
                                        }
                                      });
                                    },
                                  ),
                                ),
                                Expanded(
                                  flex: 3,
                                  child: TextField(
                                    keyboardType: TextInputType.number,
                                    controller: _protein,
                                    style: TextStyle(fontSize: 15),
                                    decoration: InputDecoration(
                                        labelText: 'Amount',
                                        suffixText: 'g',
                                        counter: Offstage()),
                                    maxLength: 6,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        Card(
                          color: Color.fromRGBO(225, 212, 197, 1),
                          child: Padding(
                            padding:
                                EdgeInsets.symmetric(horizontal: 20, vertical: 6),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: <Widget>[
                                Expanded(
                                  flex: 3,
                                  child: Text(
                                    'Carbs',
                                    style: TextStyle(fontSize: 15),
                                  ),
                                ),
                                Expanded(
                                  flex: 3,
                                  child: ToggleButtons(
                                    selectedColor: Colors.black,
                                    renderBorder: false,
                                    fillColor: Colors.black12,
                                    children: <Widget>[
                                      Padding(
                                        padding: const EdgeInsets.all(1),
                                        child: Text('<'),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.all(1),
                                        child: Text('>'),
                                      ),
                                    ],
                                    isSelected: _selectionsAmountCarbs,
                                    onPressed: (int index) {
                                      setState(() {
                                        //Sorgt für Statusänderung des geklickten Buttons
                                        _selectionsAmountCarbs[index] =
                                            !_selectionsAmountCarbs[index];

                                        if (_selectionsAmountCarbs[0] == true) {
                                          _selectionsAmountCarbs[1] = false;
                                        }
                                        if (_selectionsAmountCarbs[1] == true) {
                                          _selectionsAmountCarbs[0] = false;
                                        }
                                      });
                                    },
                                  ),
                                ),
                                Expanded(
                                  flex: 3,
                                  child: TextField(
                                    keyboardType: TextInputType.number,
                                    controller: _carbs,
                                    style: TextStyle(fontSize: 15),
                                    decoration: InputDecoration(
                                        labelText: 'Amount',
                                        suffixText: 'g',
                                        counter: Offstage()),
                                    maxLength: 6,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        Card(
                          color: Color.fromRGBO(225, 212, 197, 1),
                          child: Padding(
                            padding:
                                EdgeInsets.symmetric(horizontal: 20, vertical: 6),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: <Widget>[
                                Expanded(
                                  flex: 3,
                                  child: Text(
                                    'Fat',
                                    style: TextStyle(fontSize: 15),
                                  ),
                                ),
                                Expanded(
                                  flex: 3,
                                  child: ToggleButtons(
                                    selectedColor: Colors.black,
                                    fillColor: Colors.black12,
                                    renderBorder: false,
                                    children: <Widget>[
                                      Padding(
                                        padding: const EdgeInsets.all(1),
                                        child: Text('<'),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.all(1),
                                        child: Text('>'),
                                      ),
                                    ],
                                    isSelected: _selectionsAmountFat,
                                    onPressed: (int index) {
                                      setState(() {
                                        //Sorgt für Statusänderung des geklickten Buttons
                                        _selectionsAmountFat[index] =
                                            !_selectionsAmountFat[index];

                                        if (_selectionsAmountFat[0] == true) {
                                          _selectionsAmountFat[1] = false;
                                        }
                                        if (_selectionsAmountFat[1] == true) {
                                          _selectionsAmountFat[0] = false;
                                        }
                                      });
                                    },
                                  ),
                                ),
                                Expanded(
                                  flex: 3,
                                  child: TextFormField(
                                    keyboardType: TextInputType.number,
                                    controller: _fat,
                                    style: TextStyle(fontSize: 15),
                                    decoration: InputDecoration(
                                      labelText: 'Amount',
                                      suffixText: 'g',
                                      counter: Offstage(),
                                    ),
                                    maxLength: 6,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  Card(
                    child: Padding(
                      padding:
                          const EdgeInsets.symmetric(horizontal: 18, vertical: 6),
                      child: TextButton(

                        onPressed: () async {
                          await getAllDataFromFirebase(); //Abwarten um alle Datensätze zu bekommen
                          getUserInputData();
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => searchResult()));
                        },
                        child: Text('Search'),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future getAllDataFromFirebase() async {
    //Auslesen der Datenbankinhalte für die einzelnen Variablen(Textfelder)
    await ref.once().then((DataSnapshot snapshot) {
      snapshot.value.forEach((key, values) {
        databaseKeys.add(key);
      });
    });
    //Befüllen der Databasevalue Liste
    for (int i = 0; i < databaseKeys.length; i++) {
      await ref
          .child(databaseKeys[i])
          .once()
          .then((DataSnapshot snapshot) async {
        await ref
            .child(databaseKeys[i])
            .child('name')
            .once()
            .then((DataSnapshot snapshot) {
          databaseValues.add('${snapshot.value}');
        });
        await ref
            .child(databaseKeys[i])
            .child('protein')
            .once()
            .then((DataSnapshot snapshot) {
          databaseValues.add('${snapshot.value}');
        });
        await ref
            .child(databaseKeys[i])
            .child('carbs')
            .once()
            .then((DataSnapshot snapshot) {
          databaseValues.add('${snapshot.value}');
        });
        await ref
            .child(databaseKeys[i])
            .child('fat')
            .once()
            .then((DataSnapshot snapshot) {
          databaseValues.add('${snapshot.value}');
        });
        await ref
            .child(databaseKeys[i])
            .child('calories')
            .once()
            .then((DataSnapshot snapshot) {
          databaseValues.add('${snapshot.value}');
        });
        await ref
            .child(databaseKeys[i])
            .child('meat')
            .once()
            .then((DataSnapshot snapshot) {
          databaseValues.add('${snapshot.value}');
        });
        await ref
            .child(databaseKeys[i])
            .child('vegan')
            .once()
            .then((DataSnapshot snapshot) {
          databaseValues.add('${snapshot.value}');
        });
        await ref
            .child(databaseKeys[i])
            .child('vegetarian')
            .once()
            .then((DataSnapshot snapshot) {
          databaseValues.add('${snapshot.value}');
        });
        await ref
            .child(databaseKeys[i])
            .child('glutenfree')
            .once()
            .then((DataSnapshot snapshot) {
          databaseValues.add('${snapshot.value}');
        });
        await ref
            .child(databaseKeys[i])
            .child('lactosefree')
            .once()
            .then((DataSnapshot snapshot) {
          databaseValues.add('${snapshot.value}');
        });
      });
    }
  }

  Future getUserInputData() async {
    name = _name.text.trim();
    meat = _selections[0];
    vegan = _selections[1];
    vegetarian = _selections[2];
    glutenfree = _selectionsfree[0];
    lactosefree = _selectionsfree[1];
    calories = int.tryParse(_calories.text.trim());
    protein = int.tryParse(_protein.text.trim());
    carbs = int.tryParse(_carbs.text.trim());
    fat = int.tryParse(_fat.text.trim());

    print('name: $name, meat: $meat, vegan: $vegan, vegetarian: $vegetarian, glutenfree: $glutenfree,'
        ' lactosefree: $lactosefree,calories: $calories, protein: $protein, carbs: $carbs, fat: $fat');

    if (_selectionsAmountCalories[0] == true) {
      caloriesLess = true;
      caloriesGreater = false;
    }
    if (_selectionsAmountCalories[1] == true) {
      caloriesLess = false;
      caloriesGreater = true;
    }
    if (_selectionsAmountProtein[0] == true) {
      proteinLess = true;
      proteinGreater = false;
    }
    if (_selectionsAmountProtein[1] == true) {
      proteinLess = false;
      proteinGreater = true;
    }
    if (_selectionsAmountCarbs[0] == true) {
      carbsLess = true;
      carbsGreater = false;
    }
    if (_selectionsAmountCarbs[1] == true) {
      carbsLess = false;
      carbsGreater = true;
    }
    if (_selectionsAmountFat[0] == true) {
      fatLess = true;
      fatGreater = false;
    }
    if (_selectionsAmountFat[1] == true) {
      fatLess = false;
      fatGreater = true;
    }
    compareData();
  }

  compareData() {
    //Überprüfung für Name
    if (name != null &&
        name != '' &&
        name.isEmpty != true &&
        name.trim().length != 0) {
      //Schleife nur für Name
      for (int i = 0; i < databaseValues.length; i = i + 10) {
        if ((databaseValues[i].toLowerCase()).contains(name.toLowerCase())) {
          nameList.add(databaseKeys[(i / 10).toInt()]);
        }
      }
    }
    //FÄLLE MEAT
    //Meat
    if (meat == true && glutenfree == false && lactosefree == false) {
      print("Listenzusammenstellung Meat");
      for (int i = 5; i < databaseValues.length; i = i + 10) {
        if (databaseValues[i] == 'true') {
          meatList.add(databaseKeys[((i * 10) / 100).toInt()]);
        }
      }
    }
    //Meat + Gluteenfree
    if (meat == true && glutenfree == true && lactosefree == false) {
      print("Listenzusammenstellung Meat+Gluten");
      List<int> zwischenwerte = [];
      for (int i = 5; i < databaseValues.length; i = i + 10) {
        if (databaseValues[i] == 'true') {
          zwischenwerte.add(i);
        }
      }
      for (int j = 0; j < zwischenwerte.length; j++) {
        int meatTreffer = zwischenwerte[j];
        if (databaseValues[meatTreffer + 3] == 'true') {
          meatGlutenList.add(databaseKeys[((meatTreffer * 10) / 100).toInt()]);
        }
      }
    }
    //Meat + Lactosefree
    if (meat == true && glutenfree == false && lactosefree == true) {
      print("Listenzusammenstellung Meat+Lactose");
      List<int> zwischenwerte = [];
      for (int i = 5; i < databaseValues.length; i = i + 10) {
        if (databaseValues[i] == 'true') {
          zwischenwerte.add(i);
        }
      }
      for (int j = 0; j < zwischenwerte.length; j++) {
        int meatTreffer = zwischenwerte[j];
        if (databaseValues[meatTreffer + 4] == 'true') {
          meatLactoseList.add(databaseKeys[((meatTreffer * 10) / 100).toInt()]);
        }
      }
    }
    //Meat + Gluteenfree + Lactosefree
    if (meat == true && glutenfree == true && lactosefree == true) {
      print("Listenzusammenstellung Meat+Gluten+Lactose");
      List<int> zwischenwerte = [];
      //Anzahl der Meat Treffer ermitteln
      for (int i = 5; i < databaseValues.length; i = i + 10) {
        if (databaseValues[i] == 'true') {
          zwischenwerte.add(i);
        }
      }
      //Schnittmenge der Meat und Gluten Treffer ermitteln
      for (int j = 0; j < zwischenwerte.length; j++) {
        int meatTreffer = zwischenwerte[j];
        if (databaseValues[meatTreffer + 3] != 'true') {
          zwischenwerte.removeAt(j);
          j--;
        }
      }
      //Schnittmenge der Meat, Gluten und Lactose Treffer ermitteln
      for (int y = 0; y < zwischenwerte.length; y++) {
        int meatAndGlutenTreffer = zwischenwerte[y];
        if (databaseValues[meatAndGlutenTreffer + 4] == 'true') {
          meatGlutenLactoseList
              .add(databaseKeys[((meatAndGlutenTreffer * 10) / 100).toInt()]);
        }
      }
    }
    //FÄLLE VEGAN
    //Vegan + Lactosefree
    if (vegan == true && glutenfree == false) {
      print("Listenzusammenstellung Vegan+Lactose");
      for (int i = 6; i < databaseValues.length; i = i + 10) {
        if (databaseValues[i] == 'true') {
          veganList.add(databaseKeys[((i * 10) / 100).toInt()]);
        }
      }
    }
    //Vegan + Lactosefree + Gluteenfree
    if (vegan == true && glutenfree == true) {
      print("Listenzusammenstellung Vegan+Lactose+Gluten");
      List<int> zwischenwerte = [];
      for (int i = 6; i < databaseValues.length; i = i + 10) {
        if (databaseValues[i] == 'true') {
          zwischenwerte.add(i);
        }
      }
      for (int j = 0; j < zwischenwerte.length; j++) {
        int veganTreffer = zwischenwerte[j];
        if (databaseValues[veganTreffer + 2] == 'true') {
          veganGlutenList
              .add(databaseKeys[((veganTreffer * 10) / 100).toInt()]);
        }
      }
    }
    //FÄLLE VEGETARIAN
    //Vegetarian
    if (vegetarian == true && glutenfree == false && lactosefree == false) {
      print("Listenzusammenstellung Vegetarian");
      for (int i = 7; i < databaseValues.length; i = i + 10) {
        if (databaseValues[i] == 'true') {
          vegetarianList.add(databaseKeys[((i * 10) / 100).toInt()]);
        }
      }
    }
    //Vegetarian + Glutenfree
    if (vegetarian == true && glutenfree == true && lactosefree == false) {
      print("Listenzusammenstellung Vegetarian+Gluten");
      List<int> zwischenwerte = [];
      for (int i = 7; i < databaseValues.length; i = i + 10) {
        if (databaseValues[i] == 'true') {
          zwischenwerte.add(i);
        }
      }
      for (int j = 0; j < zwischenwerte.length; j++) {
        int vegetarianTreffer = zwischenwerte[j];
        if (databaseValues[vegetarianTreffer + 1] == 'true') {
          vegetarianGlutenList
              .add(databaseKeys[((vegetarianTreffer * 10) / 100).toInt()]);
        }
      }
    }
    //Vegetarian + Lactosefree
    if (vegetarian == true && glutenfree == false && lactosefree == true) {
      print("Listenzusammenstellung Vegetarian+Lactose");
      List<int> zwischenwerte = [];
      for (int i = 7; i < databaseValues.length; i = i + 10) {
        if (databaseValues[i] == 'true') {
          zwischenwerte.add(i);
        }
      }
      for (int j = 0; j < zwischenwerte.length; j++) {
        int vegetarianTreffer = zwischenwerte[j];
        if (databaseValues[vegetarianTreffer + 2] == 'true') {
          vegetarianLactoseList
              .add(databaseKeys[((vegetarianTreffer * 10) / 100).toInt()]);
        }
      }
    }
    //Vegetarian + Glutenfree + Lactosefree
    if (vegetarian == true && glutenfree == true && lactosefree == true) {
      print("Listenzusammenstellung Vegetarian+Gluten+Lactose");
      List<int> zwischenwerte = [];
      //Anzahl der Vegetarian Treffer ermitteln
      for (int i = 7; i < databaseValues.length; i = i + 10) {
        if (databaseValues[i] == 'true') {
          zwischenwerte.add(i);
        }
      }
      //Schnittmenge der Vegetarian und Gluten Treffer ermitteln
      for (int j = 0; j < zwischenwerte.length; j++) {
        int vegetarianTreffer = zwischenwerte[j];
        if (databaseValues[vegetarianTreffer + 1] != 'true') {
          zwischenwerte.removeAt(j);
          j--;
        }
      }
      //Schnittmenge der Vegetarisch, Gluten und Lactose Treffer ermitteln
      for (int y = 0; y < zwischenwerte.length; y++) {
        int vegetarianAndGlutenTreffer = zwischenwerte[y];
        if (databaseValues[vegetarianAndGlutenTreffer + 2] == 'true') {
          vegetarianGlutenLactoseList.add(
              databaseKeys[((vegetarianAndGlutenTreffer * 10) / 100).toInt()]);
        }
      }
    }
    //Glutenfree
    if (glutenfree == true && lactosefree == false && meat == false && vegetarian == false && vegan == false) {
      print("Listenzusammenstellung Glutenfree");
      for (int i = 8; i < databaseValues.length; i = i + 10) {
        if (databaseValues[i] == 'true') {
          glutenList.add(databaseKeys[((i * 10) / 100).toInt()]);
        }
      }
    }
    //Glutenfree + Lactosefree
    if (glutenfree == true && lactosefree == true && meat == false && vegetarian == false && vegan == false) {
      print("Listenzusammenstellung Glutenfree+Lactose");
      List<int> zwischenwerte = [];
      for (int i = 8; i < databaseValues.length; i = i + 10) {
        if (databaseValues[i] == 'true') {
          zwischenwerte.add(i);
        }
      }
      for (int j = 0; j < zwischenwerte.length; j++) {
        int glutenTreffer = zwischenwerte[j];
        if (databaseValues[glutenTreffer + 1] == 'true') {
          glutenLactoseList
              .add(databaseKeys[((glutenTreffer * 10) / 100).toInt()]);
        }
      }
    }
    //Lactosefree
    if (glutenfree == false && lactosefree == true && meat == false && vegetarian == false && vegan == false) {
      print("Listenzusammenstellung Lactosefree");
      for (int i = 9; i < databaseValues.length; i = i + 10) {
        if (databaseValues[i] == 'true') {
          lactoseList.add(databaseKeys[((i * 10) / 100).toInt()]);
        }
      }
    }
    //Calories Check
    if (calories != null) {
      if (caloriesLess == true && caloriesGreater == false) {
        print("Listenzusammenstellung CaloriesLess");
        for (int i = 4; i < databaseValues.length; i = i + 10) {
          if (int.parse(databaseValues[i]) < calories) {
            caloriesLessList.add(databaseKeys[((i * 10) / 100).toInt()]);
          }
        }
      }
      if (caloriesLess == false && caloriesGreater == true) {
        print("Listenzusammenstellung CaloriesGreater");
        for (int i = 4; i < databaseValues.length; i = i + 10) {
          if (int.parse(databaseValues[i]) > calories) {
            caloriesGreaterList.add(databaseKeys[((i * 10) / 100).toInt()]);
          }
        }
      }
    }
    //Protein Check
    if (protein != null) {
      if (proteinLess == true && proteinGreater == false) {
        print("Listenzusammenstellung ProteinLess");
        for (int i = 1; i < databaseValues.length; i = i + 10) {
          if (int.parse(databaseValues[i]) < protein) {
            proteinLessList.add(databaseKeys[((i * 10) / 100).toInt()]);
          }
        }
      }
      if (proteinLess == false && proteinGreater == true) {
        print("Listenzusammenstellung ProteinGreater");
        for (int i = 1; i < databaseValues.length; i = i + 10) {
          if (int.parse(databaseValues[i]) > protein) {
            proteinGreaterList.add(databaseKeys[((i * 10) / 100).toInt()]);
          }
        }
      }
    }
    //Carbs Check
    if (carbs != null) {
      if (carbsLess == true && carbsGreater == false) {
        print("Listenzusammenstellung CarbsLess");
        for (int i = 2; i < databaseValues.length; i = i + 10) {
          if (int.parse(databaseValues[i]) < carbs) {
            carbsLessList.add(databaseKeys[((i * 10) / 100).toInt()]);
          }
        }
      }
      if (carbsLess == false && carbsGreater == true) {
        print("Listenzusammenstellung CarbsGreater");
        for (int i = 2; i < databaseValues.length; i = i + 10) {
          if (int.parse(databaseValues[i]) > carbs) {
            carbsGreaterList.add(databaseKeys[((i * 10) / 100).toInt()]);
          }
        }
      }
    }
    //Fat Check
    if (fat != null) {
      if (fatLess == true && fatGreater == false) {
        print("Listenzusammenstellung FatLess");
        for (int i = 3; i < databaseValues.length; i = i + 10) {
          if (int.parse(databaseValues[i]) < fat) {
            fatLessList.add(databaseKeys[((i * 10) / 100).toInt()]);
          }
        }
      }
      if (fatLess == false && fatGreater == true) {
        print("Listenzusammenstellung FatGreater");
        for (int i = 3; i < databaseValues.length; i = i + 10) {
          if (int.parse(databaseValues[i]) > fat) {
            fatGreaterList.add(databaseKeys[((i * 10) / 100).toInt()]);
          }
        }
      }
    }
    //Zusammenführung der Bedingungen um Schnittmenge zu ermitteln und anschließend Speichern in comparedData --> searchResult
    if (nameList.isEmpty == false) {
      print("Geht in NameList");
      if (meatList.isEmpty == false) {
        nameList.removeWhere((item) => !meatList.contains(item));
      }
      if (meatGlutenList.isEmpty == false) {
        nameList.removeWhere((item) => !meatGlutenList.contains(item));
      }
      if (meatLactoseList.isEmpty == false) {
        nameList.removeWhere((item) => !meatLactoseList.contains(item));
      }
      if (meatGlutenLactoseList.isEmpty == false) {
        nameList.removeWhere((item) => !meatGlutenLactoseList.contains(item));
      }
      if (veganList.isEmpty == false) {
        nameList.removeWhere((item) => !veganList.contains(item));
      }
      if (veganGlutenList.isEmpty == false) {
        nameList.removeWhere((item) => !veganGlutenList.contains(item));
      }
      if (vegetarianList.isEmpty == false) {
        nameList.removeWhere((item) => !vegetarianList.contains(item));
      }
      if (vegetarianGlutenList.isEmpty == false) {
        nameList.removeWhere((item) => !vegetarianGlutenList.contains(item));
      }
      if (vegetarianLactoseList.isEmpty == false) {
        nameList.removeWhere((item) => !vegetarianLactoseList.contains(item));
      }
      if (vegetarianGlutenLactoseList.isEmpty == false) {
        nameList
            .removeWhere((item) => !vegetarianGlutenLactoseList.contains(item));
      }
      if (glutenList.isEmpty == false) {
        nameList.removeWhere((item) => !glutenList.contains(item));
      }
      if (glutenLactoseList.isEmpty == false) {
        nameList.removeWhere((item) => !glutenLactoseList.contains(item));
      }
      if (lactoseList.isEmpty == false) {
        nameList.removeWhere((item) => !lactoseList.contains(item));
      }
      if (caloriesLessList.isEmpty == false) {
        nameList.removeWhere((item) => !caloriesLessList.contains(item));
      }
      if (caloriesGreaterList.isEmpty == false) {
        nameList.removeWhere((item) => !caloriesGreaterList.contains(item));
      }
      if (proteinLessList.isEmpty == false) {
        nameList.removeWhere((item) => !proteinLessList.contains(item));
      }
      if (proteinGreaterList.isEmpty == false) {
        nameList.removeWhere((item) => !proteinGreaterList.contains(item));
      }
      if (carbsLessList.isEmpty == false) {
        nameList.removeWhere((item) => !carbsLessList.contains(item));
      }
      if (carbsGreaterList.isEmpty == false) {
        nameList.removeWhere((item) => !carbsGreaterList.contains(item));
      }
      if (fatLessList.isEmpty == false) {
        nameList.removeWhere((item) => !fatLessList.contains(item));
      }
      if (fatGreaterList.isEmpty == false) {
        nameList.removeWhere((item) => !fatGreaterList.contains(item));
      }
      comparedData = nameList;
    } else if (meatList.isEmpty == false) {
      print("Geht in meatList");
      if (nameList.isEmpty == false) {
        meatList.removeWhere((item) => !nameList.contains(item));
      }
      if (meatGlutenList.isEmpty == false) {
        meatList.removeWhere((item) => !meatGlutenList.contains(item));
      }
      if (meatLactoseList.isEmpty == false) {
        meatList.removeWhere((item) => !meatLactoseList.contains(item));
      }
      if (meatGlutenLactoseList.isEmpty == false) {
        meatList.removeWhere((item) => !meatGlutenLactoseList.contains(item));
      }
      if (veganList.isEmpty == false) {
        meatList.removeWhere((item) => !veganList.contains(item));
      }
      if (veganGlutenList.isEmpty == false) {
        meatList.removeWhere((item) => !veganGlutenList.contains(item));
      }
      if (vegetarianList.isEmpty == false) {
        meatList.removeWhere((item) => !vegetarianList.contains(item));
      }
      if (vegetarianGlutenList.isEmpty == false) {
        meatList.removeWhere((item) => !vegetarianGlutenList.contains(item));
      }
      if (vegetarianLactoseList.isEmpty == false) {
        meatList.removeWhere((item) => !vegetarianLactoseList.contains(item));
      }
      if (vegetarianGlutenLactoseList.isEmpty == false) {
        meatList
            .removeWhere((item) => !vegetarianGlutenLactoseList.contains(item));
      }
      if (glutenList.isEmpty == false) {
        meatList.removeWhere((item) => !glutenList.contains(item));
      }
      if (glutenLactoseList.isEmpty == false) {
        meatList.removeWhere((item) => !glutenLactoseList.contains(item));
      }
      if (lactoseList.isEmpty == false) {
        meatList.removeWhere((item) => !lactoseList.contains(item));
      }
      if (caloriesLessList.isEmpty == false) {
        meatList.removeWhere((item) => !caloriesLessList.contains(item));
      }
      if (caloriesGreaterList.isEmpty == false) {
        meatList.removeWhere((item) => !caloriesGreaterList.contains(item));
      }
      if (proteinLessList.isEmpty == false) {
        meatList.removeWhere((item) => !proteinLessList.contains(item));
      }
      if (proteinGreaterList.isEmpty == false) {
        meatList.removeWhere((item) => !proteinGreaterList.contains(item));
      }
      if (carbsLessList.isEmpty == false) {
        meatList.removeWhere((item) => !carbsLessList.contains(item));
      }
      if (carbsGreaterList.isEmpty == false) {
        meatList.removeWhere((item) => !carbsGreaterList.contains(item));
      }
      if (fatLessList.isEmpty == false) {
        meatList.removeWhere((item) => !fatLessList.contains(item));
      }
      if (fatGreaterList.isEmpty == false) {
        meatList.removeWhere((item) => !fatGreaterList.contains(item));
      }
      comparedData = meatList;
    } else if (meatGlutenList.isEmpty == false) {
      print("Geht in meatGlutenList");
      if (nameList.isEmpty == false) {
        meatGlutenList.removeWhere((item) => !nameList.contains(item));
      }
      if (meatList.isEmpty == false) {
        meatGlutenList.removeWhere((item) => !meatList.contains(item));
      }
      if (meatLactoseList.isEmpty == false) {
        meatGlutenList.removeWhere((item) => !meatLactoseList.contains(item));
      }
      if (meatGlutenLactoseList.isEmpty == false) {
        meatGlutenList
            .removeWhere((item) => !meatGlutenLactoseList.contains(item));
      }
      if (veganList.isEmpty == false) {
        meatGlutenList.removeWhere((item) => !veganList.contains(item));
      }
      if (veganGlutenList.isEmpty == false) {
        meatGlutenList.removeWhere((item) => !veganGlutenList.contains(item));
      }
      if (vegetarianList.isEmpty == false) {
        meatGlutenList.removeWhere((item) => !vegetarianList.contains(item));
      }
      if (vegetarianGlutenList.isEmpty == false) {
        meatGlutenList
            .removeWhere((item) => !vegetarianGlutenList.contains(item));
      }
      if (vegetarianLactoseList.isEmpty == false) {
        meatGlutenList
            .removeWhere((item) => !vegetarianLactoseList.contains(item));
      }
      if (vegetarianGlutenLactoseList.isEmpty == false) {
        meatGlutenList
            .removeWhere((item) => !vegetarianGlutenLactoseList.contains(item));
      }
      if (glutenList.isEmpty == false) {
        meatGlutenList.removeWhere((item) => !glutenList.contains(item));
      }
      if (glutenLactoseList.isEmpty == false) {
        meatGlutenList.removeWhere((item) => !glutenLactoseList.contains(item));
      }
      if (lactoseList.isEmpty == false) {
        meatGlutenList.removeWhere((item) => !lactoseList.contains(item));
      }
      if (caloriesLessList.isEmpty == false) {
        meatGlutenList.removeWhere((item) => !caloriesLessList.contains(item));
      }
      if (caloriesGreaterList.isEmpty == false) {
        meatGlutenList
            .removeWhere((item) => !caloriesGreaterList.contains(item));
      }
      if (proteinLessList.isEmpty == false) {
        meatGlutenList.removeWhere((item) => !proteinLessList.contains(item));
      }
      if (proteinGreaterList.isEmpty == false) {
        meatGlutenList
            .removeWhere((item) => !proteinGreaterList.contains(item));
      }
      if (carbsLessList.isEmpty == false) {
        meatGlutenList.removeWhere((item) => !carbsLessList.contains(item));
      }
      if (carbsGreaterList.isEmpty == false) {
        meatGlutenList.removeWhere((item) => !carbsGreaterList.contains(item));
      }
      if (fatLessList.isEmpty == false) {
        meatGlutenList.removeWhere((item) => !fatLessList.contains(item));
      }
      if (fatGreaterList.isEmpty == false) {
        meatGlutenList.removeWhere((item) => !fatGreaterList.contains(item));
      }
      comparedData = meatGlutenList;
    } else if (meatLactoseList.isEmpty == false) {
      print("Geht in meatLactoseList");
      if (nameList.isEmpty == false) {
        meatLactoseList.removeWhere((item) => !nameList.contains(item));
      }
      if (meatList.isEmpty == false) {
        meatLactoseList.removeWhere((item) => !meatList.contains(item));
      }
      if (meatGlutenList.isEmpty == false) {
        meatLactoseList.removeWhere((item) => !meatGlutenList.contains(item));
      }
      if (meatGlutenLactoseList.isEmpty == false) {
        meatLactoseList
            .removeWhere((item) => !meatGlutenLactoseList.contains(item));
      }
      if (veganList.isEmpty == false) {
        meatLactoseList.removeWhere((item) => !veganList.contains(item));
      }
      if (veganGlutenList.isEmpty == false) {
        meatLactoseList.removeWhere((item) => !veganGlutenList.contains(item));
      }
      if (vegetarianList.isEmpty == false) {
        meatLactoseList.removeWhere((item) => !vegetarianList.contains(item));
      }
      if (vegetarianGlutenList.isEmpty == false) {
        meatLactoseList
            .removeWhere((item) => !vegetarianGlutenList.contains(item));
      }
      if (vegetarianLactoseList.isEmpty == false) {
        meatLactoseList
            .removeWhere((item) => !vegetarianLactoseList.contains(item));
      }
      if (vegetarianGlutenLactoseList.isEmpty == false) {
        meatLactoseList
            .removeWhere((item) => !vegetarianGlutenLactoseList.contains(item));
      }
      if (glutenList.isEmpty == false) {
        meatLactoseList.removeWhere((item) => !glutenList.contains(item));
      }
      if (glutenLactoseList.isEmpty == false) {
        meatLactoseList
            .removeWhere((item) => !glutenLactoseList.contains(item));
      }
      if (lactoseList.isEmpty == false) {
        meatLactoseList.removeWhere((item) => !lactoseList.contains(item));
      }
      if (caloriesLessList.isEmpty == false) {
        meatLactoseList.removeWhere((item) => !caloriesLessList.contains(item));
      }
      if (caloriesGreaterList.isEmpty == false) {
        meatLactoseList
            .removeWhere((item) => !caloriesGreaterList.contains(item));
      }
      if (proteinLessList.isEmpty == false) {
        meatLactoseList.removeWhere((item) => !proteinLessList.contains(item));
      }
      if (proteinGreaterList.isEmpty == false) {
        meatLactoseList
            .removeWhere((item) => !proteinGreaterList.contains(item));
      }
      if (carbsLessList.isEmpty == false) {
        meatLactoseList.removeWhere((item) => !carbsLessList.contains(item));
      }
      if (carbsGreaterList.isEmpty == false) {
        meatLactoseList.removeWhere((item) => !carbsGreaterList.contains(item));
      }
      if (fatLessList.isEmpty == false) {
        meatLactoseList.removeWhere((item) => !fatLessList.contains(item));
      }
      if (fatGreaterList.isEmpty == false) {
        meatLactoseList.removeWhere((item) => !fatGreaterList.contains(item));
      }
      comparedData = meatLactoseList;
    } else if (meatGlutenLactoseList.isEmpty == false) {
      print("Geht in meatGlutenLactoseList");
      if (nameList.isEmpty == false) {
        meatGlutenLactoseList.removeWhere((item) => !nameList.contains(item));
      }
      if (meatList.isEmpty == false) {
        meatGlutenLactoseList.removeWhere((item) => !meatList.contains(item));
      }
      if (meatGlutenList.isEmpty == false) {
        meatGlutenLactoseList
            .removeWhere((item) => !meatGlutenList.contains(item));
      }
      if (meatLactoseList.isEmpty == false) {
        meatGlutenLactoseList
            .removeWhere((item) => !meatLactoseList.contains(item));
      }
      if (veganList.isEmpty == false) {
        meatGlutenLactoseList.removeWhere((item) => !veganList.contains(item));
      }
      if (veganGlutenList.isEmpty == false) {
        meatGlutenLactoseList
            .removeWhere((item) => !veganGlutenList.contains(item));
      }
      if (vegetarianList.isEmpty == false) {
        meatGlutenLactoseList
            .removeWhere((item) => !vegetarianList.contains(item));
      }
      if (vegetarianGlutenList.isEmpty == false) {
        meatGlutenLactoseList
            .removeWhere((item) => !vegetarianGlutenList.contains(item));
      }
      if (vegetarianLactoseList.isEmpty == false) {
        meatGlutenLactoseList
            .removeWhere((item) => !vegetarianLactoseList.contains(item));
      }
      if (vegetarianGlutenLactoseList.isEmpty == false) {
        meatGlutenLactoseList
            .removeWhere((item) => !vegetarianGlutenLactoseList.contains(item));
      }
      if (glutenList.isEmpty == false) {
        meatGlutenLactoseList.removeWhere((item) => !glutenList.contains(item));
      }
      if (glutenLactoseList.isEmpty == false) {
        meatGlutenLactoseList
            .removeWhere((item) => !glutenLactoseList.contains(item));
      }
      if (lactoseList.isEmpty == false) {
        meatGlutenLactoseList
            .removeWhere((item) => !lactoseList.contains(item));
      }
      if (caloriesLessList.isEmpty == false) {
        meatGlutenLactoseList
            .removeWhere((item) => !caloriesLessList.contains(item));
      }
      if (caloriesGreaterList.isEmpty == false) {
        meatGlutenLactoseList
            .removeWhere((item) => !caloriesGreaterList.contains(item));
      }
      if (proteinLessList.isEmpty == false) {
        meatGlutenLactoseList
            .removeWhere((item) => !proteinLessList.contains(item));
      }
      if (proteinGreaterList.isEmpty == false) {
        meatGlutenLactoseList
            .removeWhere((item) => !proteinGreaterList.contains(item));
      }
      if (carbsLessList.isEmpty == false) {
        meatGlutenLactoseList
            .removeWhere((item) => !carbsLessList.contains(item));
      }
      if (carbsGreaterList.isEmpty == false) {
        meatGlutenLactoseList
            .removeWhere((item) => !carbsGreaterList.contains(item));
      }
      if (fatLessList.isEmpty == false) {
        meatGlutenLactoseList
            .removeWhere((item) => !fatLessList.contains(item));
      }
      if (fatGreaterList.isEmpty == false) {
        meatGlutenLactoseList
            .removeWhere((item) => !fatGreaterList.contains(item));
      }
      comparedData = meatGlutenLactoseList;
    } else if (veganList.isEmpty == false) {
      print("Geht in veganList");
      if (nameList.isEmpty == false) {
        veganList.removeWhere((item) => !nameList.contains(item));
      }
      if (meatList.isEmpty == false) {
        veganList.removeWhere((item) => !meatList.contains(item));
      }
      if (meatGlutenList.isEmpty == false) {
        veganList.removeWhere((item) => !meatGlutenList.contains(item));
      }
      if (meatLactoseList.isEmpty == false) {
        veganList.removeWhere((item) => !meatLactoseList.contains(item));
      }
      if (meatGlutenLactoseList.isEmpty == false) {
        veganList.removeWhere((item) => !meatGlutenLactoseList.contains(item));
      }
      if (veganGlutenList.isEmpty == false) {
        veganList.removeWhere((item) => !veganGlutenList.contains(item));
      }
      if (vegetarianList.isEmpty == false) {
        veganList.removeWhere((item) => !vegetarianList.contains(item));
      }
      if (vegetarianGlutenList.isEmpty == false) {
        veganList.removeWhere((item) => !vegetarianGlutenList.contains(item));
      }
      if (vegetarianLactoseList.isEmpty == false) {
        veganList.removeWhere((item) => !vegetarianLactoseList.contains(item));
      }
      if (vegetarianGlutenLactoseList.isEmpty == false) {
        veganList
            .removeWhere((item) => !vegetarianGlutenLactoseList.contains(item));
      }
      if (glutenList.isEmpty == false) {
        veganList.removeWhere((item) => !glutenList.contains(item));
      }
      if (glutenLactoseList.isEmpty == false) {
        veganList.removeWhere((item) => !glutenLactoseList.contains(item));
      }
      if (lactoseList.isEmpty == false) {
        veganList.removeWhere((item) => !lactoseList.contains(item));
      }
      if (caloriesLessList.isEmpty == false) {
        veganList.removeWhere((item) => !caloriesLessList.contains(item));
      }
      if (caloriesGreaterList.isEmpty == false) {
        veganList.removeWhere((item) => !caloriesGreaterList.contains(item));
      }
      if (proteinLessList.isEmpty == false) {
        veganList.removeWhere((item) => !proteinLessList.contains(item));
      }
      if (proteinGreaterList.isEmpty == false) {
        veganList.removeWhere((item) => !proteinGreaterList.contains(item));
      }
      if (carbsLessList.isEmpty == false) {
        veganList.removeWhere((item) => !carbsLessList.contains(item));
      }
      if (carbsGreaterList.isEmpty == false) {
        veganList.removeWhere((item) => !carbsGreaterList.contains(item));
      }
      if (fatLessList.isEmpty == false) {
        veganList.removeWhere((item) => !fatLessList.contains(item));
      }
      if (fatGreaterList.isEmpty == false) {
        veganList.removeWhere((item) => !fatGreaterList.contains(item));
      }
      comparedData = veganList;
    } else if (veganGlutenList.isEmpty == false) {
      print("Geht in veganGlutenList");
      if (nameList.isEmpty == false) {
        veganGlutenList.removeWhere((item) => !nameList.contains(item));
      }
      if (meatList.isEmpty == false) {
        veganGlutenList.removeWhere((item) => !meatList.contains(item));
      }
      if (meatGlutenList.isEmpty == false) {
        veganGlutenList.removeWhere((item) => !meatGlutenList.contains(item));
      }
      if (meatLactoseList.isEmpty == false) {
        veganGlutenList.removeWhere((item) => !meatLactoseList.contains(item));
      }
      if (meatGlutenLactoseList.isEmpty == false) {
        veganGlutenList
            .removeWhere((item) => !meatGlutenLactoseList.contains(item));
      }
      if (veganList.isEmpty == false) {
        veganGlutenList.removeWhere((item) => !veganList.contains(item));
      }
      if (vegetarianList.isEmpty == false) {
        veganGlutenList.removeWhere((item) => !vegetarianList.contains(item));
      }
      if (vegetarianGlutenList.isEmpty == false) {
        veganGlutenList
            .removeWhere((item) => !vegetarianGlutenList.contains(item));
      }
      if (vegetarianLactoseList.isEmpty == false) {
        veganGlutenList
            .removeWhere((item) => !vegetarianLactoseList.contains(item));
      }
      if (vegetarianGlutenLactoseList.isEmpty == false) {
        veganGlutenList
            .removeWhere((item) => !vegetarianGlutenLactoseList.contains(item));
      }
      if (glutenList.isEmpty == false) {
        veganGlutenList.removeWhere((item) => !glutenList.contains(item));
      }
      if (glutenLactoseList.isEmpty == false) {
        veganGlutenList
            .removeWhere((item) => !glutenLactoseList.contains(item));
      }
      if (lactoseList.isEmpty == false) {
        veganGlutenList.removeWhere((item) => !lactoseList.contains(item));
      }
      if (caloriesLessList.isEmpty == false) {
        veganGlutenList.removeWhere((item) => !caloriesLessList.contains(item));
      }
      if (caloriesGreaterList.isEmpty == false) {
        veganGlutenList
            .removeWhere((item) => !caloriesGreaterList.contains(item));
      }
      if (proteinLessList.isEmpty == false) {
        veganGlutenList.removeWhere((item) => !proteinLessList.contains(item));
      }
      if (proteinGreaterList.isEmpty == false) {
        veganGlutenList
            .removeWhere((item) => !proteinGreaterList.contains(item));
      }
      if (carbsLessList.isEmpty == false) {
        veganGlutenList.removeWhere((item) => !carbsLessList.contains(item));
      }
      if (carbsGreaterList.isEmpty == false) {
        veganGlutenList.removeWhere((item) => !carbsGreaterList.contains(item));
      }
      if (fatLessList.isEmpty == false) {
        veganGlutenList.removeWhere((item) => !fatLessList.contains(item));
      }
      if (fatGreaterList.isEmpty == false) {
        veganGlutenList.removeWhere((item) => !fatGreaterList.contains(item));
      }
      comparedData = veganGlutenList;
    } else if (vegetarianList.isEmpty == false) {
      print("Geht in vegetarianList");
      if (nameList.isEmpty == false) {
        vegetarianList.removeWhere((item) => !nameList.contains(item));
      }
      if (meatList.isEmpty == false) {
        vegetarianList.removeWhere((item) => !meatList.contains(item));
      }
      if (meatGlutenList.isEmpty == false) {
        vegetarianList.removeWhere((item) => !meatGlutenList.contains(item));
      }
      if (meatLactoseList.isEmpty == false) {
        vegetarianList.removeWhere((item) => !meatLactoseList.contains(item));
      }
      if (meatGlutenLactoseList.isEmpty == false) {
        vegetarianList
            .removeWhere((item) => !meatGlutenLactoseList.contains(item));
      }
      if (veganList.isEmpty == false) {
        vegetarianList.removeWhere((item) => !veganList.contains(item));
      }
      if (veganGlutenList.isEmpty == false) {
        vegetarianList.removeWhere((item) => !veganGlutenList.contains(item));
      }
      if (vegetarianGlutenList.isEmpty == false) {
        vegetarianList
            .removeWhere((item) => !vegetarianGlutenList.contains(item));
      }
      if (vegetarianLactoseList.isEmpty == false) {
        vegetarianList
            .removeWhere((item) => !vegetarianLactoseList.contains(item));
      }
      if (vegetarianGlutenLactoseList.isEmpty == false) {
        vegetarianList
            .removeWhere((item) => !vegetarianGlutenLactoseList.contains(item));
      }
      if (glutenList.isEmpty == false) {
        vegetarianList.removeWhere((item) => !glutenList.contains(item));
      }
      if (glutenLactoseList.isEmpty == false) {
        vegetarianList.removeWhere((item) => !glutenLactoseList.contains(item));
      }
      if (lactoseList.isEmpty == false) {
        vegetarianList.removeWhere((item) => !lactoseList.contains(item));
      }
      if (caloriesLessList.isEmpty == false) {
        vegetarianList.removeWhere((item) => !caloriesLessList.contains(item));
      }
      if (caloriesGreaterList.isEmpty == false) {
        vegetarianList
            .removeWhere((item) => !caloriesGreaterList.contains(item));
      }
      if (proteinLessList.isEmpty == false) {
        vegetarianList.removeWhere((item) => !proteinLessList.contains(item));
      }
      if (proteinGreaterList.isEmpty == false) {
        vegetarianList
            .removeWhere((item) => !proteinGreaterList.contains(item));
      }
      if (carbsLessList.isEmpty == false) {
        vegetarianList.removeWhere((item) => !carbsLessList.contains(item));
      }
      if (carbsGreaterList.isEmpty == false) {
        vegetarianList.removeWhere((item) => !carbsGreaterList.contains(item));
      }
      if (fatLessList.isEmpty == false) {
        vegetarianList.removeWhere((item) => !fatLessList.contains(item));
      }
      if (fatGreaterList.isEmpty == false) {
        vegetarianList.removeWhere((item) => !fatGreaterList.contains(item));
      }
      comparedData = vegetarianList;
    } else if (vegetarianGlutenList.isEmpty == false) {
      print("Geht in vegetarianGlutenList");
      if (nameList.isEmpty == false) {
        vegetarianGlutenList.removeWhere((item) => !nameList.contains(item));
      }
      if (meatList.isEmpty == false) {
        vegetarianGlutenList.removeWhere((item) => !meatList.contains(item));
      }
      if (meatGlutenList.isEmpty == false) {
        vegetarianGlutenList
            .removeWhere((item) => !meatGlutenList.contains(item));
      }
      if (meatLactoseList.isEmpty == false) {
        vegetarianGlutenList
            .removeWhere((item) => !meatLactoseList.contains(item));
      }
      if (meatGlutenLactoseList.isEmpty == false) {
        vegetarianGlutenList
            .removeWhere((item) => !meatGlutenLactoseList.contains(item));
      }
      if (veganList.isEmpty == false) {
        vegetarianGlutenList.removeWhere((item) => !veganList.contains(item));
      }
      if (veganGlutenList.isEmpty == false) {
        vegetarianGlutenList
            .removeWhere((item) => !veganGlutenList.contains(item));
      }
      if (vegetarianList.isEmpty == false) {
        vegetarianGlutenList
            .removeWhere((item) => !vegetarianList.contains(item));
      }
      if (vegetarianLactoseList.isEmpty == false) {
        vegetarianGlutenList
            .removeWhere((item) => !vegetarianLactoseList.contains(item));
      }
      if (vegetarianGlutenLactoseList.isEmpty == false) {
        vegetarianGlutenList
            .removeWhere((item) => !vegetarianGlutenLactoseList.contains(item));
      }
      if (glutenList.isEmpty == false) {
        vegetarianGlutenList.removeWhere((item) => !glutenList.contains(item));
      }
      if (glutenLactoseList.isEmpty == false) {
        vegetarianGlutenList
            .removeWhere((item) => !glutenLactoseList.contains(item));
      }
      if (lactoseList.isEmpty == false) {
        vegetarianGlutenList.removeWhere((item) => !lactoseList.contains(item));
      }
      if (caloriesLessList.isEmpty == false) {
        vegetarianGlutenList
            .removeWhere((item) => !caloriesLessList.contains(item));
      }
      if (caloriesGreaterList.isEmpty == false) {
        vegetarianGlutenList
            .removeWhere((item) => !caloriesGreaterList.contains(item));
      }
      if (proteinLessList.isEmpty == false) {
        vegetarianGlutenList
            .removeWhere((item) => !proteinLessList.contains(item));
      }
      if (proteinGreaterList.isEmpty == false) {
        vegetarianGlutenList
            .removeWhere((item) => !proteinGreaterList.contains(item));
      }
      if (carbsLessList.isEmpty == false) {
        vegetarianGlutenList
            .removeWhere((item) => !carbsLessList.contains(item));
      }
      if (carbsGreaterList.isEmpty == false) {
        vegetarianGlutenList
            .removeWhere((item) => !carbsGreaterList.contains(item));
      }
      if (fatLessList.isEmpty == false) {
        vegetarianGlutenList.removeWhere((item) => !fatLessList.contains(item));
      }
      if (fatGreaterList.isEmpty == false) {
        vegetarianGlutenList
            .removeWhere((item) => !fatGreaterList.contains(item));
      }
      comparedData = vegetarianGlutenList;
    } else if (vegetarianLactoseList.isEmpty == false) {
      print("Geht in vegetarianLactoseList");
      if (nameList.isEmpty == false) {
        vegetarianLactoseList.removeWhere((item) => !nameList.contains(item));
      }
      if (meatList.isEmpty == false) {
        vegetarianLactoseList.removeWhere((item) => !meatList.contains(item));
      }
      if (meatGlutenList.isEmpty == false) {
        vegetarianLactoseList
            .removeWhere((item) => !meatGlutenList.contains(item));
      }
      if (meatLactoseList.isEmpty == false) {
        vegetarianLactoseList
            .removeWhere((item) => !meatLactoseList.contains(item));
      }
      if (meatGlutenLactoseList.isEmpty == false) {
        vegetarianLactoseList
            .removeWhere((item) => !meatGlutenLactoseList.contains(item));
      }
      if (veganList.isEmpty == false) {
        vegetarianLactoseList.removeWhere((item) => !veganList.contains(item));
      }
      if (veganGlutenList.isEmpty == false) {
        vegetarianLactoseList
            .removeWhere((item) => !veganGlutenList.contains(item));
      }
      if (vegetarianList.isEmpty == false) {
        vegetarianLactoseList
            .removeWhere((item) => !vegetarianList.contains(item));
      }
      if (vegetarianGlutenList.isEmpty == false) {
        vegetarianLactoseList
            .removeWhere((item) => !vegetarianGlutenList.contains(item));
      }
      if (vegetarianGlutenLactoseList.isEmpty == false) {
        vegetarianLactoseList
            .removeWhere((item) => !vegetarianGlutenLactoseList.contains(item));
      }
      if (glutenList.isEmpty == false) {
        vegetarianLactoseList.removeWhere((item) => !glutenList.contains(item));
      }
      if (glutenLactoseList.isEmpty == false) {
        vegetarianLactoseList
            .removeWhere((item) => !glutenLactoseList.contains(item));
      }
      if (lactoseList.isEmpty == false) {
        vegetarianLactoseList
            .removeWhere((item) => !lactoseList.contains(item));
      }
      if (caloriesLessList.isEmpty == false) {
        vegetarianLactoseList
            .removeWhere((item) => !caloriesLessList.contains(item));
      }
      if (caloriesGreaterList.isEmpty == false) {
        vegetarianLactoseList
            .removeWhere((item) => !caloriesGreaterList.contains(item));
      }
      if (proteinLessList.isEmpty == false) {
        vegetarianLactoseList
            .removeWhere((item) => !proteinLessList.contains(item));
      }
      if (proteinGreaterList.isEmpty == false) {
        vegetarianLactoseList
            .removeWhere((item) => !proteinGreaterList.contains(item));
      }
      if (carbsLessList.isEmpty == false) {
        vegetarianLactoseList
            .removeWhere((item) => !carbsLessList.contains(item));
      }
      if (carbsGreaterList.isEmpty == false) {
        vegetarianLactoseList
            .removeWhere((item) => !carbsGreaterList.contains(item));
      }
      if (fatLessList.isEmpty == false) {
        vegetarianLactoseList
            .removeWhere((item) => !fatLessList.contains(item));
      }
      if (fatGreaterList.isEmpty == false) {
        vegetarianLactoseList
            .removeWhere((item) => !fatGreaterList.contains(item));
      }
      comparedData = vegetarianLactoseList;
    } else if (vegetarianGlutenLactoseList.isEmpty == false) {
      print("Geht in vegetarianGlutenLactoseList");
      if (nameList.isEmpty == false) {
        vegetarianGlutenLactoseList
            .removeWhere((item) => !nameList.contains(item));
      }
      if (meatList.isEmpty == false) {
        vegetarianGlutenLactoseList
            .removeWhere((item) => !meatList.contains(item));
      }
      if (meatGlutenList.isEmpty == false) {
        vegetarianGlutenLactoseList
            .removeWhere((item) => !meatGlutenList.contains(item));
      }
      if (meatLactoseList.isEmpty == false) {
        vegetarianGlutenLactoseList
            .removeWhere((item) => !meatLactoseList.contains(item));
      }
      if (meatGlutenLactoseList.isEmpty == false) {
        vegetarianGlutenLactoseList
            .removeWhere((item) => !meatGlutenLactoseList.contains(item));
      }
      if (veganList.isEmpty == false) {
        vegetarianGlutenLactoseList
            .removeWhere((item) => !veganList.contains(item));
      }
      if (veganGlutenList.isEmpty == false) {
        vegetarianGlutenLactoseList
            .removeWhere((item) => !veganGlutenList.contains(item));
      }
      if (vegetarianList.isEmpty == false) {
        vegetarianGlutenLactoseList
            .removeWhere((item) => !vegetarianList.contains(item));
      }
      if (vegetarianGlutenList.isEmpty == false) {
        vegetarianGlutenLactoseList
            .removeWhere((item) => !vegetarianGlutenList.contains(item));
      }
      if (vegetarianLactoseList.isEmpty == false) {
        vegetarianGlutenLactoseList
            .removeWhere((item) => !vegetarianLactoseList.contains(item));
      }
      if (glutenList.isEmpty == false) {
        vegetarianGlutenLactoseList
            .removeWhere((item) => !glutenList.contains(item));
      }
      if (glutenLactoseList.isEmpty == false) {
        vegetarianGlutenLactoseList
            .removeWhere((item) => !glutenLactoseList.contains(item));
      }
      if (lactoseList.isEmpty == false) {
        vegetarianGlutenLactoseList
            .removeWhere((item) => !lactoseList.contains(item));
      }
      if (caloriesLessList.isEmpty == false) {
        vegetarianGlutenLactoseList
            .removeWhere((item) => !caloriesLessList.contains(item));
      }
      if (caloriesGreaterList.isEmpty == false) {
        vegetarianGlutenLactoseList
            .removeWhere((item) => !caloriesGreaterList.contains(item));
      }
      if (proteinLessList.isEmpty == false) {
        vegetarianGlutenLactoseList
            .removeWhere((item) => !proteinLessList.contains(item));
      }
      if (proteinGreaterList.isEmpty == false) {
        vegetarianGlutenLactoseList
            .removeWhere((item) => !proteinGreaterList.contains(item));
      }
      if (carbsLessList.isEmpty == false) {
        vegetarianGlutenLactoseList
            .removeWhere((item) => !carbsLessList.contains(item));
      }
      if (carbsGreaterList.isEmpty == false) {
        vegetarianGlutenLactoseList
            .removeWhere((item) => !carbsGreaterList.contains(item));
      }
      if (fatLessList.isEmpty == false) {
        vegetarianGlutenLactoseList
            .removeWhere((item) => !fatLessList.contains(item));
      }
      if (fatGreaterList.isEmpty == false) {
        vegetarianGlutenLactoseList
            .removeWhere((item) => !fatGreaterList.contains(item));
      }
      comparedData = vegetarianGlutenLactoseList;
    } else if (glutenList.isEmpty == false) {
      print("Geht in glutenList");
      if (nameList.isEmpty == false) {
        glutenList.removeWhere((item) => !nameList.contains(item));
      }
      if (meatList.isEmpty == false) {
        glutenList.removeWhere((item) => !meatList.contains(item));
      }
      if (meatGlutenList.isEmpty == false) {
        glutenList.removeWhere((item) => !meatGlutenList.contains(item));
      }
      if (meatLactoseList.isEmpty == false) {
        glutenList.removeWhere((item) => !meatLactoseList.contains(item));
      }
      if (meatGlutenLactoseList.isEmpty == false) {
        glutenList.removeWhere((item) => !meatGlutenLactoseList.contains(item));
      }
      if (veganList.isEmpty == false) {
        glutenList.removeWhere((item) => !veganList.contains(item));
      }
      if (veganGlutenList.isEmpty == false) {
        glutenList.removeWhere((item) => !veganGlutenList.contains(item));
      }
      if (vegetarianList.isEmpty == false) {
        glutenList.removeWhere((item) => !vegetarianList.contains(item));
      }
      if (vegetarianGlutenList.isEmpty == false) {
        glutenList.removeWhere((item) => !vegetarianGlutenList.contains(item));
      }
      if (vegetarianLactoseList.isEmpty == false) {
        glutenList.removeWhere((item) => !vegetarianLactoseList.contains(item));
      }
      if (vegetarianGlutenLactoseList.isEmpty == false) {
        glutenList
            .removeWhere((item) => !vegetarianGlutenLactoseList.contains(item));
      }
      if (glutenLactoseList.isEmpty == false) {
        glutenList.removeWhere((item) => !glutenLactoseList.contains(item));
      }
      if (lactoseList.isEmpty == false) {
        glutenList.removeWhere((item) => !lactoseList.contains(item));
      }
      if (caloriesLessList.isEmpty == false) {
        glutenList.removeWhere((item) => !caloriesLessList.contains(item));
      }
      if (caloriesGreaterList.isEmpty == false) {
        glutenList.removeWhere((item) => !caloriesGreaterList.contains(item));
      }
      if (proteinLessList.isEmpty == false) {
        glutenList.removeWhere((item) => !proteinLessList.contains(item));
      }
      if (proteinGreaterList.isEmpty == false) {
        glutenList.removeWhere((item) => !proteinGreaterList.contains(item));
      }
      if (carbsLessList.isEmpty == false) {
        glutenList.removeWhere((item) => !carbsLessList.contains(item));
      }
      if (carbsGreaterList.isEmpty == false) {
        glutenList.removeWhere((item) => !carbsGreaterList.contains(item));
      }
      if (fatLessList.isEmpty == false) {
        glutenList.removeWhere((item) => !fatLessList.contains(item));
      }
      if (fatGreaterList.isEmpty == false) {
        glutenList.removeWhere((item) => !fatGreaterList.contains(item));
      }
      comparedData = glutenList;
    } else if (glutenLactoseList.isEmpty == false) {
      print("Geht in glutenLactoseList");
      if (nameList.isEmpty == false) {
        glutenLactoseList.removeWhere((item) => !nameList.contains(item));
      }
      if (meatList.isEmpty == false) {
        glutenLactoseList.removeWhere((item) => !meatList.contains(item));
      }
      if (meatGlutenList.isEmpty == false) {
        glutenLactoseList.removeWhere((item) => !meatGlutenList.contains(item));
      }
      if (meatLactoseList.isEmpty == false) {
        glutenLactoseList
            .removeWhere((item) => !meatLactoseList.contains(item));
      }
      if (meatGlutenLactoseList.isEmpty == false) {
        glutenLactoseList
            .removeWhere((item) => !meatGlutenLactoseList.contains(item));
      }
      if (veganList.isEmpty == false) {
        glutenLactoseList.removeWhere((item) => !veganList.contains(item));
      }
      if (veganGlutenList.isEmpty == false) {
        glutenLactoseList
            .removeWhere((item) => !veganGlutenList.contains(item));
      }
      if (vegetarianList.isEmpty == false) {
        glutenLactoseList.removeWhere((item) => !vegetarianList.contains(item));
      }
      if (vegetarianGlutenList.isEmpty == false) {
        glutenLactoseList
            .removeWhere((item) => !vegetarianGlutenList.contains(item));
      }
      if (vegetarianLactoseList.isEmpty == false) {
        glutenLactoseList
            .removeWhere((item) => !vegetarianLactoseList.contains(item));
      }
      if (vegetarianGlutenLactoseList.isEmpty == false) {
        glutenLactoseList
            .removeWhere((item) => !vegetarianGlutenLactoseList.contains(item));
      }
      if (glutenList.isEmpty == false) {
        glutenLactoseList.removeWhere((item) => !glutenList.contains(item));
      }
      if (lactoseList.isEmpty == false) {
        glutenLactoseList.removeWhere((item) => !lactoseList.contains(item));
      }
      if (caloriesLessList.isEmpty == false) {
        glutenLactoseList
            .removeWhere((item) => !caloriesLessList.contains(item));
      }
      if (caloriesGreaterList.isEmpty == false) {
        glutenLactoseList
            .removeWhere((item) => !caloriesGreaterList.contains(item));
      }
      if (proteinLessList.isEmpty == false) {
        glutenLactoseList
            .removeWhere((item) => !proteinLessList.contains(item));
      }
      if (proteinGreaterList.isEmpty == false) {
        glutenLactoseList
            .removeWhere((item) => !proteinGreaterList.contains(item));
      }
      if (carbsLessList.isEmpty == false) {
        glutenLactoseList.removeWhere((item) => !carbsLessList.contains(item));
      }
      if (carbsGreaterList.isEmpty == false) {
        glutenLactoseList
            .removeWhere((item) => !carbsGreaterList.contains(item));
      }
      if (fatLessList.isEmpty == false) {
        glutenLactoseList.removeWhere((item) => !fatLessList.contains(item));
      }
      if (fatGreaterList.isEmpty == false) {
        glutenLactoseList.removeWhere((item) => !fatGreaterList.contains(item));
      }
      comparedData = glutenLactoseList;
    } else if (lactoseList.isEmpty == false) {
      print("Geht in lactoseList");
      if (nameList.isEmpty == false) {
        lactoseList.removeWhere((item) => !nameList.contains(item));
      }
      if (meatList.isEmpty == false) {
        lactoseList.removeWhere((item) => !meatList.contains(item));
      }
      if (meatGlutenList.isEmpty == false) {
        lactoseList.removeWhere((item) => !meatGlutenList.contains(item));
      }
      if (meatLactoseList.isEmpty == false) {
        lactoseList.removeWhere((item) => !meatLactoseList.contains(item));
      }
      if (meatGlutenLactoseList.isEmpty == false) {
        lactoseList
            .removeWhere((item) => !meatGlutenLactoseList.contains(item));
      }
      if (veganList.isEmpty == false) {
        lactoseList.removeWhere((item) => !veganList.contains(item));
      }
      if (veganGlutenList.isEmpty == false) {
        lactoseList.removeWhere((item) => !veganGlutenList.contains(item));
      }
      if (vegetarianList.isEmpty == false) {
        lactoseList.removeWhere((item) => !vegetarianList.contains(item));
      }
      if (vegetarianGlutenList.isEmpty == false) {
        lactoseList.removeWhere((item) => !vegetarianGlutenList.contains(item));
      }
      if (vegetarianLactoseList.isEmpty == false) {
        lactoseList
            .removeWhere((item) => !vegetarianLactoseList.contains(item));
      }
      if (vegetarianGlutenLactoseList.isEmpty == false) {
        lactoseList
            .removeWhere((item) => !vegetarianGlutenLactoseList.contains(item));
      }
      if (glutenList.isEmpty == false) {
        lactoseList.removeWhere((item) => !glutenList.contains(item));
      }
      if (glutenLactoseList.isEmpty == false) {
        lactoseList.removeWhere((item) => !glutenLactoseList.contains(item));
      }
      if (caloriesLessList.isEmpty == false) {
        lactoseList.removeWhere((item) => !caloriesLessList.contains(item));
      }
      if (caloriesGreaterList.isEmpty == false) {
        lactoseList.removeWhere((item) => !caloriesGreaterList.contains(item));
      }
      if (proteinLessList.isEmpty == false) {
        lactoseList.removeWhere((item) => !proteinLessList.contains(item));
      }
      if (proteinGreaterList.isEmpty == false) {
        lactoseList.removeWhere((item) => !proteinGreaterList.contains(item));
      }
      if (carbsLessList.isEmpty == false) {
        lactoseList.removeWhere((item) => !carbsLessList.contains(item));
      }
      if (carbsGreaterList.isEmpty == false) {
        lactoseList.removeWhere((item) => !carbsGreaterList.contains(item));
      }
      if (fatLessList.isEmpty == false) {
        lactoseList.removeWhere((item) => !fatLessList.contains(item));
      }
      if (fatGreaterList.isEmpty == false) {
        lactoseList.removeWhere((item) => !fatGreaterList.contains(item));
      }
      comparedData = lactoseList;
    } else if (caloriesLessList.isEmpty == false) {
      print("Geht in caloriesLessList");
    if (nameList.isEmpty == false) {
        caloriesLessList.removeWhere((item) => !nameList.contains(item));
      }
      if (meatList.isEmpty == false) {
        caloriesLessList.removeWhere((item) => !meatList.contains(item));
      }
      if (meatGlutenList.isEmpty == false) {
        caloriesLessList.removeWhere((item) => !meatGlutenList.contains(item));
      }
      if (meatLactoseList.isEmpty == false) {
        caloriesLessList.removeWhere((item) => !meatLactoseList.contains(item));
      }
      if (meatGlutenLactoseList.isEmpty == false) {
        caloriesLessList
            .removeWhere((item) => !meatGlutenLactoseList.contains(item));
      }
      if (veganList.isEmpty == false) {
        caloriesLessList.removeWhere((item) => !veganList.contains(item));
      }
      if (veganGlutenList.isEmpty == false) {
        caloriesLessList.removeWhere((item) => !veganGlutenList.contains(item));
      }
      if (vegetarianList.isEmpty == false) {
        caloriesLessList.removeWhere((item) => !vegetarianList.contains(item));
      }
      if (vegetarianGlutenList.isEmpty == false) {
        caloriesLessList
            .removeWhere((item) => !vegetarianGlutenList.contains(item));
      }
      if (vegetarianLactoseList.isEmpty == false) {
        caloriesLessList
            .removeWhere((item) => !vegetarianLactoseList.contains(item));
      }
      if (vegetarianGlutenLactoseList.isEmpty == false) {
        caloriesLessList
            .removeWhere((item) => !vegetarianGlutenLactoseList.contains(item));
      }
      if (glutenList.isEmpty == false) {
        caloriesLessList.removeWhere((item) => !glutenList.contains(item));
      }
      if (glutenLactoseList.isEmpty == false) {
        caloriesLessList
            .removeWhere((item) => !glutenLactoseList.contains(item));
      }
      if (lactoseList.isEmpty == false) {
        caloriesLessList.removeWhere((item) => !lactoseList.contains(item));
      }
      if (caloriesGreaterList.isEmpty == false) {
        caloriesLessList
            .removeWhere((item) => !caloriesGreaterList.contains(item));
      }
      if (proteinLessList.isEmpty == false) {
        caloriesLessList.removeWhere((item) => !proteinLessList.contains(item));
      }
      if (proteinGreaterList.isEmpty == false) {
        caloriesLessList
            .removeWhere((item) => !proteinGreaterList.contains(item));
      }
      if (carbsLessList.isEmpty == false) {
        caloriesLessList.removeWhere((item) => !carbsLessList.contains(item));
      }
      if (carbsGreaterList.isEmpty == false) {
        caloriesLessList
            .removeWhere((item) => !carbsGreaterList.contains(item));
      }
      if (fatLessList.isEmpty == false) {
        caloriesLessList.removeWhere((item) => !fatLessList.contains(item));
      }
      if (fatGreaterList.isEmpty == false) {
        caloriesLessList.removeWhere((item) => !fatGreaterList.contains(item));
      }
      comparedData = caloriesLessList;
    } else if (caloriesGreaterList.isEmpty == false) {
      print("Geht in caloriesGreaterList");
      if (nameList.isEmpty == false) {
        caloriesGreaterList.removeWhere((item) => !nameList.contains(item));
      }
      if (meatList.isEmpty == false) {
        caloriesGreaterList.removeWhere((item) => !meatList.contains(item));
      }
      if (meatGlutenList.isEmpty == false) {
        caloriesGreaterList
            .removeWhere((item) => !meatGlutenList.contains(item));
      }
      if (meatLactoseList.isEmpty == false) {
        caloriesGreaterList
            .removeWhere((item) => !meatLactoseList.contains(item));
      }
      if (meatGlutenLactoseList.isEmpty == false) {
        caloriesGreaterList
            .removeWhere((item) => !meatGlutenLactoseList.contains(item));
      }
      if (veganList.isEmpty == false) {
        caloriesGreaterList.removeWhere((item) => !veganList.contains(item));
      }
      if (veganGlutenList.isEmpty == false) {
        caloriesGreaterList
            .removeWhere((item) => !veganGlutenList.contains(item));
      }
      if (vegetarianList.isEmpty == false) {
        caloriesGreaterList
            .removeWhere((item) => !vegetarianList.contains(item));
      }
      if (vegetarianGlutenList.isEmpty == false) {
        caloriesGreaterList
            .removeWhere((item) => !vegetarianGlutenList.contains(item));
      }
      if (vegetarianLactoseList.isEmpty == false) {
        caloriesGreaterList
            .removeWhere((item) => !vegetarianLactoseList.contains(item));
      }
      if (vegetarianGlutenLactoseList.isEmpty == false) {
        caloriesGreaterList
            .removeWhere((item) => !vegetarianGlutenLactoseList.contains(item));
      }
      if (glutenList.isEmpty == false) {
        caloriesGreaterList.removeWhere((item) => !glutenList.contains(item));
      }
      if (glutenLactoseList.isEmpty == false) {
        caloriesGreaterList
            .removeWhere((item) => !glutenLactoseList.contains(item));
      }
      if (lactoseList.isEmpty == false) {
        caloriesGreaterList.removeWhere((item) => !lactoseList.contains(item));
      }
      if (caloriesLessList.isEmpty == false) {
        caloriesGreaterList
            .removeWhere((item) => !caloriesLessList.contains(item));
      }
      if (proteinLessList.isEmpty == false) {
        caloriesGreaterList
            .removeWhere((item) => !proteinLessList.contains(item));
      }
      if (proteinGreaterList.isEmpty == false) {
        caloriesGreaterList
            .removeWhere((item) => !proteinGreaterList.contains(item));
      }
      if (carbsLessList.isEmpty == false) {
        caloriesGreaterList
            .removeWhere((item) => !carbsLessList.contains(item));
      }
      if (carbsGreaterList.isEmpty == false) {
        caloriesGreaterList
            .removeWhere((item) => !carbsGreaterList.contains(item));
      }
      if (fatLessList.isEmpty == false) {
        caloriesGreaterList.removeWhere((item) => !fatLessList.contains(item));
      }
      if (fatGreaterList.isEmpty == false) {
        caloriesGreaterList
            .removeWhere((item) => !fatGreaterList.contains(item));
      }
      comparedData = caloriesGreaterList;
    } else if (proteinLessList.isEmpty == false) {
      print("Geht in proteinLessList");
      if (nameList.isEmpty == false) {
        proteinLessList.removeWhere((item) => !nameList.contains(item));
      }
      if (meatList.isEmpty == false) {
        proteinLessList.removeWhere((item) => !meatList.contains(item));
      }
      if (meatGlutenList.isEmpty == false) {
        proteinLessList.removeWhere((item) => !meatGlutenList.contains(item));
      }
      if (meatLactoseList.isEmpty == false) {
        proteinLessList.removeWhere((item) => !meatLactoseList.contains(item));
      }
      if (meatGlutenLactoseList.isEmpty == false) {
        proteinLessList
            .removeWhere((item) => !meatGlutenLactoseList.contains(item));
      }
      if (veganList.isEmpty == false) {
        proteinLessList.removeWhere((item) => !veganList.contains(item));
      }
      if (veganGlutenList.isEmpty == false) {
        proteinLessList.removeWhere((item) => !veganGlutenList.contains(item));
      }
      if (vegetarianList.isEmpty == false) {
        proteinLessList.removeWhere((item) => !vegetarianList.contains(item));
      }
      if (vegetarianGlutenList.isEmpty == false) {
        proteinLessList
            .removeWhere((item) => !vegetarianGlutenList.contains(item));
      }
      if (vegetarianLactoseList.isEmpty == false) {
        proteinLessList
            .removeWhere((item) => !vegetarianLactoseList.contains(item));
      }
      if (vegetarianGlutenLactoseList.isEmpty == false) {
        proteinLessList
            .removeWhere((item) => !vegetarianGlutenLactoseList.contains(item));
      }
      if (glutenList.isEmpty == false) {
        proteinLessList.removeWhere((item) => !glutenList.contains(item));
      }
      if (glutenLactoseList.isEmpty == false) {
        proteinLessList
            .removeWhere((item) => !glutenLactoseList.contains(item));
      }
      if (lactoseList.isEmpty == false) {
        proteinLessList.removeWhere((item) => !lactoseList.contains(item));
      }
      if (caloriesLessList.isEmpty == false) {
        proteinLessList.removeWhere((item) => !caloriesLessList.contains(item));
      }
      if (caloriesGreaterList.isEmpty == false) {
        proteinLessList
            .removeWhere((item) => !caloriesGreaterList.contains(item));
      }
      if (proteinGreaterList.isEmpty == false) {
        proteinLessList
            .removeWhere((item) => !proteinGreaterList.contains(item));
      }
      if (carbsLessList.isEmpty == false) {
        proteinLessList.removeWhere((item) => !carbsLessList.contains(item));
      }
      if (carbsGreaterList.isEmpty == false) {
        proteinLessList.removeWhere((item) => !carbsGreaterList.contains(item));
      }
      if (fatLessList.isEmpty == false) {
        proteinLessList.removeWhere((item) => !fatLessList.contains(item));
      }
      if (fatGreaterList.isEmpty == false) {
        proteinLessList.removeWhere((item) => !fatGreaterList.contains(item));
      }
      comparedData = proteinLessList;
    } else if (proteinGreaterList.isEmpty == false) {
      print("Geht in proteinGreaterList");
      if (nameList.isEmpty == false) {
        proteinGreaterList.removeWhere((item) => !nameList.contains(item));
      }
      if (meatList.isEmpty == false) {
        proteinGreaterList.removeWhere((item) => !meatList.contains(item));
      }
      if (meatGlutenList.isEmpty == false) {
        proteinGreaterList
            .removeWhere((item) => !meatGlutenList.contains(item));
      }
      if (meatLactoseList.isEmpty == false) {
        proteinGreaterList
            .removeWhere((item) => !meatLactoseList.contains(item));
      }
      if (meatGlutenLactoseList.isEmpty == false) {
        proteinGreaterList
            .removeWhere((item) => !meatGlutenLactoseList.contains(item));
      }
      if (veganList.isEmpty == false) {
        proteinGreaterList.removeWhere((item) => !veganList.contains(item));
      }
      if (veganGlutenList.isEmpty == false) {
        proteinGreaterList
            .removeWhere((item) => !veganGlutenList.contains(item));
      }
      if (vegetarianList.isEmpty == false) {
        proteinGreaterList
            .removeWhere((item) => !vegetarianList.contains(item));
      }
      if (vegetarianGlutenList.isEmpty == false) {
        proteinGreaterList
            .removeWhere((item) => !vegetarianGlutenList.contains(item));
      }
      if (vegetarianLactoseList.isEmpty == false) {
        proteinGreaterList
            .removeWhere((item) => !vegetarianLactoseList.contains(item));
      }
      if (vegetarianGlutenLactoseList.isEmpty == false) {
        proteinGreaterList
            .removeWhere((item) => !vegetarianGlutenLactoseList.contains(item));
      }
      if (glutenList.isEmpty == false) {
        proteinGreaterList.removeWhere((item) => !glutenList.contains(item));
      }
      if (glutenLactoseList.isEmpty == false) {
        proteinGreaterList
            .removeWhere((item) => !glutenLactoseList.contains(item));
      }
      if (lactoseList.isEmpty == false) {
        proteinGreaterList.removeWhere((item) => !lactoseList.contains(item));
      }
      if (caloriesLessList.isEmpty == false) {
        proteinGreaterList
            .removeWhere((item) => !caloriesLessList.contains(item));
      }
      if (caloriesGreaterList.isEmpty == false) {
        proteinGreaterList
            .removeWhere((item) => !caloriesGreaterList.contains(item));
      }
      if (proteinLessList.isEmpty == false) {
        proteinGreaterList
            .removeWhere((item) => !proteinLessList.contains(item));
      }
      if (carbsLessList.isEmpty == false) {
        proteinGreaterList.removeWhere((item) => !carbsLessList.contains(item));
      }
      if (carbsGreaterList.isEmpty == false) {
        proteinGreaterList
            .removeWhere((item) => !carbsGreaterList.contains(item));
      }
      if (fatLessList.isEmpty == false) {
        proteinGreaterList.removeWhere((item) => !fatLessList.contains(item));
      }
      if (fatGreaterList.isEmpty == false) {
        proteinGreaterList
            .removeWhere((item) => !fatGreaterList.contains(item));
      }
      comparedData = proteinGreaterList;
    } else if (carbsLessList.isEmpty == false) {
      print("Geht in carbsLessList");
      if (nameList.isEmpty == false) {
        carbsLessList.removeWhere((item) => !nameList.contains(item));
      }
      if (meatList.isEmpty == false) {
        carbsLessList.removeWhere((item) => !meatList.contains(item));
      }
      if (meatGlutenList.isEmpty == false) {
        carbsLessList.removeWhere((item) => !meatGlutenList.contains(item));
      }
      if (meatLactoseList.isEmpty == false) {
        carbsLessList.removeWhere((item) => !meatLactoseList.contains(item));
      }
      if (meatGlutenLactoseList.isEmpty == false) {
        carbsLessList
            .removeWhere((item) => !meatGlutenLactoseList.contains(item));
      }
      if (veganList.isEmpty == false) {
        carbsLessList.removeWhere((item) => !veganList.contains(item));
      }
      if (veganGlutenList.isEmpty == false) {
        carbsLessList.removeWhere((item) => !veganGlutenList.contains(item));
      }
      if (vegetarianList.isEmpty == false) {
        carbsLessList.removeWhere((item) => !vegetarianList.contains(item));
      }
      if (vegetarianGlutenList.isEmpty == false) {
        carbsLessList
            .removeWhere((item) => !vegetarianGlutenList.contains(item));
      }
      if (vegetarianLactoseList.isEmpty == false) {
        carbsLessList
            .removeWhere((item) => !vegetarianLactoseList.contains(item));
      }
      if (vegetarianGlutenLactoseList.isEmpty == false) {
        carbsLessList
            .removeWhere((item) => !vegetarianGlutenLactoseList.contains(item));
      }
      if (glutenList.isEmpty == false) {
        carbsLessList.removeWhere((item) => !glutenList.contains(item));
      }
      if (glutenLactoseList.isEmpty == false) {
        carbsLessList.removeWhere((item) => !glutenLactoseList.contains(item));
      }
      if (lactoseList.isEmpty == false) {
        carbsLessList.removeWhere((item) => !lactoseList.contains(item));
      }
      if (caloriesLessList.isEmpty == false) {
        carbsLessList.removeWhere((item) => !caloriesLessList.contains(item));
      }
      if (caloriesGreaterList.isEmpty == false) {
        carbsLessList
            .removeWhere((item) => !caloriesGreaterList.contains(item));
      }
      if (proteinLessList.isEmpty == false) {
        carbsLessList.removeWhere((item) => !proteinLessList.contains(item));
      }
      if (proteinGreaterList.isEmpty == false) {
        carbsLessList.removeWhere((item) => !proteinGreaterList.contains(item));
      }
      if (carbsGreaterList.isEmpty == false) {
        carbsLessList.removeWhere((item) => !carbsGreaterList.contains(item));
      }
      if (fatLessList.isEmpty == false) {
        carbsLessList.removeWhere((item) => !fatLessList.contains(item));
      }
      if (fatGreaterList.isEmpty == false) {
        carbsLessList.removeWhere((item) => !fatGreaterList.contains(item));
      }
      comparedData = carbsLessList;
    } else if (carbsGreaterList.isEmpty == false) {
      print("Geht in carbsGreaterList");
      if (nameList.isEmpty == false) {
        carbsGreaterList.removeWhere((item) => !nameList.contains(item));
      }
      if (meatList.isEmpty == false) {
        carbsGreaterList.removeWhere((item) => !meatList.contains(item));
      }
      if (meatGlutenList.isEmpty == false) {
        carbsGreaterList.removeWhere((item) => !meatGlutenList.contains(item));
      }
      if (meatLactoseList.isEmpty == false) {
        carbsGreaterList.removeWhere((item) => !meatLactoseList.contains(item));
      }
      if (meatGlutenLactoseList.isEmpty == false) {
        carbsGreaterList
            .removeWhere((item) => !meatGlutenLactoseList.contains(item));
      }
      if (veganList.isEmpty == false) {
        carbsGreaterList.removeWhere((item) => !veganList.contains(item));
      }
      if (veganGlutenList.isEmpty == false) {
        carbsGreaterList.removeWhere((item) => !veganGlutenList.contains(item));
      }
      if (vegetarianList.isEmpty == false) {
        carbsGreaterList.removeWhere((item) => !vegetarianList.contains(item));
      }
      if (vegetarianGlutenList.isEmpty == false) {
        carbsGreaterList
            .removeWhere((item) => !vegetarianGlutenList.contains(item));
      }
      if (vegetarianLactoseList.isEmpty == false) {
        carbsGreaterList
            .removeWhere((item) => !vegetarianLactoseList.contains(item));
      }
      if (vegetarianGlutenLactoseList.isEmpty == false) {
        carbsGreaterList
            .removeWhere((item) => !vegetarianGlutenLactoseList.contains(item));
      }
      if (glutenList.isEmpty == false) {
        carbsGreaterList.removeWhere((item) => !glutenList.contains(item));
      }
      if (glutenLactoseList.isEmpty == false) {
        carbsGreaterList
            .removeWhere((item) => !glutenLactoseList.contains(item));
      }
      if (lactoseList.isEmpty == false) {
        carbsGreaterList.removeWhere((item) => !lactoseList.contains(item));
      }
      if (caloriesLessList.isEmpty == false) {
        carbsGreaterList
            .removeWhere((item) => !caloriesLessList.contains(item));
      }
      if (caloriesGreaterList.isEmpty == false) {
        carbsGreaterList
            .removeWhere((item) => !caloriesGreaterList.contains(item));
      }
      if (proteinLessList.isEmpty == false) {
        carbsGreaterList.removeWhere((item) => !proteinLessList.contains(item));
      }
      if (proteinGreaterList.isEmpty == false) {
        carbsGreaterList
            .removeWhere((item) => !proteinGreaterList.contains(item));
      }
      if (carbsLessList.isEmpty == false) {
        carbsGreaterList.removeWhere((item) => !carbsLessList.contains(item));
      }
      if (fatLessList.isEmpty == false) {
        carbsGreaterList.removeWhere((item) => !fatLessList.contains(item));
      }
      if (fatGreaterList.isEmpty == false) {
        carbsGreaterList.removeWhere((item) => !fatGreaterList.contains(item));
      }
      comparedData = carbsGreaterList;
    } else if (fatLessList.isEmpty == false) {
      print("Geht in fatLessList");
      if (nameList.isEmpty == false) {
        fatLessList.removeWhere((item) => !nameList.contains(item));
      }
      if (meatList.isEmpty == false) {
        fatLessList.removeWhere((item) => !meatList.contains(item));
      }
      if (meatGlutenList.isEmpty == false) {
        fatLessList.removeWhere((item) => !meatGlutenList.contains(item));
      }
      if (meatLactoseList.isEmpty == false) {
        fatLessList.removeWhere((item) => !meatLactoseList.contains(item));
      }
      if (meatGlutenLactoseList.isEmpty == false) {
        fatLessList
            .removeWhere((item) => !meatGlutenLactoseList.contains(item));
      }
      if (veganList.isEmpty == false) {
        fatLessList.removeWhere((item) => !veganList.contains(item));
      }
      if (veganGlutenList.isEmpty == false) {
        fatLessList.removeWhere((item) => !veganGlutenList.contains(item));
      }
      if (vegetarianList.isEmpty == false) {
        fatLessList.removeWhere((item) => !vegetarianList.contains(item));
      }
      if (vegetarianGlutenList.isEmpty == false) {
        fatLessList.removeWhere((item) => !vegetarianGlutenList.contains(item));
      }
      if (vegetarianLactoseList.isEmpty == false) {
        fatLessList
            .removeWhere((item) => !vegetarianLactoseList.contains(item));
      }
      if (vegetarianGlutenLactoseList.isEmpty == false) {
        fatLessList
            .removeWhere((item) => !vegetarianGlutenLactoseList.contains(item));
      }
      if (glutenList.isEmpty == false) {
        fatLessList.removeWhere((item) => !glutenList.contains(item));
      }
      if (glutenLactoseList.isEmpty == false) {
        fatLessList.removeWhere((item) => !glutenLactoseList.contains(item));
      }
      if (lactoseList.isEmpty == false) {
        fatLessList.removeWhere((item) => !lactoseList.contains(item));
      }
      if (caloriesLessList.isEmpty == false) {
        fatLessList.removeWhere((item) => !caloriesLessList.contains(item));
      }
      if (caloriesGreaterList.isEmpty == false) {
        fatLessList.removeWhere((item) => !caloriesGreaterList.contains(item));
      }
      if (proteinLessList.isEmpty == false) {
        fatLessList.removeWhere((item) => !proteinLessList.contains(item));
      }
      if (proteinGreaterList.isEmpty == false) {
        fatLessList.removeWhere((item) => !proteinGreaterList.contains(item));
      }
      if (carbsLessList.isEmpty == false) {
        fatLessList.removeWhere((item) => !carbsLessList.contains(item));
      }
      if (carbsGreaterList.isEmpty == false) {
        fatLessList.removeWhere((item) => !carbsGreaterList.contains(item));
      }
      if (fatGreaterList.isEmpty == false) {
        fatLessList.removeWhere((item) => !fatGreaterList.contains(item));
      }
      comparedData = fatLessList;
    } else if (fatGreaterList.isEmpty == false) {
      print("Geht in fatGreaterList");
      if (nameList.isEmpty == false) {
        fatGreaterList.removeWhere((item) => !nameList.contains(item));
      }
      if (meatList.isEmpty == false) {
        fatGreaterList.removeWhere((item) => !meatList.contains(item));
      }
      if (meatGlutenList.isEmpty == false) {
        fatGreaterList.removeWhere((item) => !meatGlutenList.contains(item));
      }
      if (meatLactoseList.isEmpty == false) {
        fatGreaterList.removeWhere((item) => !meatLactoseList.contains(item));
      }
      if (meatGlutenLactoseList.isEmpty == false) {
        fatGreaterList
            .removeWhere((item) => !meatGlutenLactoseList.contains(item));
      }
      if (veganList.isEmpty == false) {
        fatGreaterList.removeWhere((item) => !veganList.contains(item));
      }
      if (veganGlutenList.isEmpty == false) {
        fatGreaterList.removeWhere((item) => !veganGlutenList.contains(item));
      }
      if (vegetarianList.isEmpty == false) {
        fatGreaterList.removeWhere((item) => !vegetarianList.contains(item));
      }
      if (vegetarianGlutenList.isEmpty == false) {
        fatGreaterList
            .removeWhere((item) => !vegetarianGlutenList.contains(item));
      }
      if (vegetarianLactoseList.isEmpty == false) {
        fatGreaterList
            .removeWhere((item) => !vegetarianLactoseList.contains(item));
      }
      if (vegetarianGlutenLactoseList.isEmpty == false) {
        fatGreaterList
            .removeWhere((item) => !vegetarianGlutenLactoseList.contains(item));
      }
      if (glutenList.isEmpty == false) {
        fatGreaterList.removeWhere((item) => !glutenList.contains(item));
      }
      if (glutenLactoseList.isEmpty == false) {
        fatGreaterList.removeWhere((item) => !glutenLactoseList.contains(item));
      }
      if (lactoseList.isEmpty == false) {
        fatGreaterList.removeWhere((item) => !lactoseList.contains(item));
      }
      if (caloriesLessList.isEmpty == false) {
        fatGreaterList.removeWhere((item) => !caloriesLessList.contains(item));
      }
      if (caloriesGreaterList.isEmpty == false) {
        fatGreaterList
            .removeWhere((item) => !caloriesGreaterList.contains(item));
      }
      if (proteinLessList.isEmpty == false) {
        fatGreaterList.removeWhere((item) => !proteinLessList.contains(item));
      }
      if (proteinGreaterList.isEmpty == false) {
        fatGreaterList
            .removeWhere((item) => !proteinGreaterList.contains(item));
      }
      if (carbsLessList.isEmpty == false) {
        fatGreaterList.removeWhere((item) => !carbsLessList.contains(item));
      }
      if (carbsGreaterList.isEmpty == false) {
        fatGreaterList.removeWhere((item) => !carbsGreaterList.contains(item));
      }
      if (fatLessList.isEmpty == false) {
        fatGreaterList.removeWhere((item) => !fatLessList.contains(item));
      }
      comparedData = fatGreaterList;
    } else if ((name == null ||
            name == '' ||
            name.isEmpty == true ||
            name.trim().length == 0) &&
        meat == false &&
        vegan == false &&
        vegetarian == false &&
        glutenfree == false &&
        lactosefree == false &&
        calories == null &&
        protein == null &&
        carbs == null &&
        fat == null) {
      print("Geht in AlleDatensätzeList");
      comparedData = databaseKeys;
    }

    print("_______Compared Data_______");
    print(comparedData);

    boxSearchResult.put('searchResults', comparedData);
  }

  Future<bool> _onBackPress() {
    Navigator.push(
        context, MaterialPageRoute(builder: (context) => homepage()));
  }
}
