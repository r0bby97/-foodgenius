import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:form_field_validator/form_field_validator.dart';
import 'package:ue1_basisprojekt/screens/recipe.dart';

class create extends StatefulWidget {
  const create({Key key}) : super(key: key);

  @override
  State createState() => _createState();
}

class _createState extends State<create> {
  final databaseReference =
      FirebaseDatabase.instance.reference().child('recipes/');
  final storage = FirebaseStorage.instance;

  var box = Hive.box('currentEmail');
  var boxPushKey = Hive.box('pushkey');
  var boxCurrentEmail = Hive.box('currentEmail');
  var boxAllCreatedRecipes = Hive.box('allCreatedRecipes');

  String currentLoggedInUserEmail = '';
  List<String> allCreatedRecipesList = [];

  GlobalKey<FormState> _nameKey = GlobalKey<FormState>();
  GlobalKey<FormState> _proteinKey = GlobalKey<FormState>();
  GlobalKey<FormState> _carbsKey = GlobalKey<FormState>();
  GlobalKey<FormState> _fatKey = GlobalKey<FormState>();
  GlobalKey<FormState> _stepsKey = GlobalKey<FormState>();
  GlobalKey<FormState> _ingredientKey = GlobalKey<FormState>();
  GlobalKey<FormState> _ingredientAmountKey = GlobalKey<FormState>();

  TextEditingController _name = TextEditingController();
  TextEditingController _protein = TextEditingController();
  TextEditingController _carbs = TextEditingController();
  TextEditingController _fat = TextEditingController();
  TextEditingController _steps = TextEditingController();
  TextEditingController _ingredientName = TextEditingController();
  TextEditingController _ingredientAmount = TextEditingController();
  String _amount, _ingredient;

  List<bool> _selections = List.generate(
      3, (_) => false); //Liste für Auswahl: Meat, Vegan, Vegetarian
  List<bool> _selectionsfree = List.generate(
      2, (_) => false); //Liste für Auswahl: Glutenfree, Lactosefree
  List<Widget> _cardList = [];
  List<String> ingredientList = [];
  String ingredients = '';
  String unit = 'g';
  var recipeCode = "";

  bool _selecteditem = false;

  double protein = 0.0;
  double carbs = 0.0;
  double fat = 0.0;

  final ImagePicker picker = ImagePicker();
  XFile image;
  String imageUrl;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create a recipe'),
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(20.0),
          child: new SingleChildScrollView(
            child: new Column(
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 15, vertical: 16),
                  child: Form(
                    key: _nameKey,
                    child: TextFormField(
                      validator: RequiredValidator(errorText: "Enter the name"),
                      controller: _name,
                      textInputAction: TextInputAction.done,
                      decoration: const InputDecoration(
                        border: UnderlineInputBorder(),
                        labelText: 'Enter the name',
                      ),
                      maxLength: 30,
                    ),
                  ),
                ),

                // Anzeigen eines ausgewählten Bildes aus der Galerie
                (imageUrl != null)
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(30.0),
                        child: Image.file(
                          File(imageUrl),
                          height: 300,
                        ))
                    : Placeholder(
                        fallbackHeight: 0.0,
                        fallbackWidth: double.infinity,
                        color: Colors.transparent,
                      ),
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 15, vertical: 16),
                  child: FloatingActionButton(
                    heroTag: "btn1",
                    onPressed: () => showPicker(context),
                    child: Icon(Icons.camera_alt),
                  ),
                ),
                SizedBox(
                  height: 10.0,
                ),

                Card(
                  color: Color.fromRGBO(225, 212, 197, 1),
                  child: Column(
                    children: [
                      // Padding(
                      //   padding: const EdgeInsets.all(15.0),
                      //   child: Text('Add the ingredients',
                      //       style: TextStyle(fontSize: 15)),
                      // ),
                      Padding(
                        padding: EdgeInsets.only(left: 15, right: 15, top: 15),
                        child: Form(
                          key: _ingredientKey,
                          child: TextFormField(
                            controller: _ingredientName,
                            textInputAction: TextInputAction.next,
                            validator: (unit) {
                              if (unit.isEmpty) {
                                return "Please enter the ingredient";
                              }
                              return null;
                            },
                            decoration: const InputDecoration(
                              border: UnderlineInputBorder(),
                              labelText: 'Name of the ingredient',
                            ),
                            onSaved: (String ingredient) {
                              _ingredient = ingredient;
                            },
                            maxLength: 50,
                          ),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.only(
                          left: 15,
                          right: 15,
                        ),
                        child: Container(
                          child: Row(
                            children: <Widget>[
                              Flexible(
                                flex: 8,
                                child: Form(
                                  key: _ingredientAmountKey,
                                  child: TextFormField(
                                    controller: _ingredientAmount,
                                    textInputAction: TextInputAction.done,
                                    onEditingComplete: () {
                                      if (_ingredientKey.currentState
                                              .validate() &&
                                          _ingredientAmountKey.currentState
                                              .validate()) {
                                        _addCardWidget();
                                        _ingredientName.clear();
                                        _ingredientAmount.clear();

                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          SnackBar(
                                            backgroundColor: Colors.green,
                                            content: Text(
                                              'You added an ingredient.',
                                              style: TextStyle(
                                                color: Colors.white,
                                              ),
                                            ),
                                          ),
                                        );
                                      }
                                    },
                                    validator: (unit) {
                                      if (unit.isEmpty) {
                                        return "Please enter the amount";
                                      }
                                      return null;
                                    },
                                    keyboardType: TextInputType.number,
                                    decoration: const InputDecoration(
                                      border: UnderlineInputBorder(),
                                      labelText: 'Amount',
                                    ),
                                    onSaved: (String amount) {
                                      _amount =
                                          amount.trim().replaceAll(' ', '');
                                    },
                                    maxLength: 6,
                                  ),
                                ),
                              ),
                              Flexible(
                                flex: 2,
                                child: DropdownButton(
                                    value: unit,
                                    underline: SizedBox(),
                                    items: [
                                      DropdownMenuItem(
                                        child: Text("g"),
                                        value: 'g',
                                      ),
                                      DropdownMenuItem(
                                        child: Text("ml"),
                                        value: 'ml',
                                      ),
                                    ],
                                    onChanged: (value) {
                                      setState(() {
                                        unit = value;
                                      });
                                    }),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 15, vertical: 15),
                        child: FloatingActionButton(
                          heroTag: "btn2",
                          onPressed: () async {
                            if (_ingredientKey.currentState.validate() &&
                                _ingredientAmountKey.currentState.validate()) {
                              _addCardWidget();
                              _ingredientName.clear();
                              _ingredientAmount.clear();

                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  backgroundColor: Colors.green,
                                  content: Text(
                                    'You added an ingredient.',
                                    style: TextStyle(
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              );
                            }
                          },
                          tooltip: 'Add',
                          child: Icon(Icons.add),
                        ),
                      ),
                    ],
                  ),
                ),

                (_cardList.length >= 1)
                    ? Padding(
                        padding: const EdgeInsets.only(top: 25.0),
                        child:
                            Text('Ingredients', style: TextStyle(fontSize: 20)),
                      )
                    : Container(child: Text(' ')),

                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 15),
                  child: Row(
                    children: <Widget>[
                      Flexible(
                          flex: 8,
                          child: ListView.builder(
                              physics: NeverScrollableScrollPhysics(),
                              shrinkWrap: true,
                              scrollDirection: Axis.vertical,
                              itemCount: _cardList.length,
                              itemBuilder: (context, index) {
                                return _cardList[index];
                              })),
                      Expanded(
                        flex: 2,
                        child: SingleChildScrollView(
                            child: ListView.builder(
                                shrinkWrap: true,
                                physics: NeverScrollableScrollPhysics(),
                                itemCount: _cardList.length,
                                itemBuilder: (context, index) {
                                  return Container(
                                    height: 80,
                                    alignment: Alignment.centerRight,
                                    child: IconButton(
                                        icon: Icon(Icons.delete),
                                        onPressed: () {
                                          setState(() {
                                            _cardList.removeAt(index);
                                            ingredientList.removeAt(index);
                                            ScaffoldMessenger.of(context).showSnackBar(
                                              SnackBar(
                                                backgroundColor: Colors.red,
                                                content: Text(
                                                  'Ingredient deleted.',
                                                  style: TextStyle(
                                                    color: Colors.white,
                                                  ),
                                                ),
                                              ),);
                                          });
                                        }),
                                  );
                                })),
                      ),
                      //),
                    ],
                  ),
                ),

                Padding(
                  padding: EdgeInsets.only(top: 10),
                  child: ToggleButtons(
                    selectedColor: Colors.black,
                    renderBorder: false,
                    fillColor: Colors.black12,
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.only(
                          right: 25,
                          left: 25,
                          top: 15,
                          bottom: 15,
                        ),
                        child: Text('Meat'),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(
                          right: 25,
                          left: 25,
                          top: 15,
                          bottom: 15,
                        ),
                        child: Text('Vegan'),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(
                          right: 25,
                          left: 25,
                          top: 15,
                          bottom: 15,
                        ),
                        child: Text('Vegetarian'),
                      ),
                    ],
                    isSelected: _selections,
                    onPressed: (int index) {
                      setState(() {
                        //Durch ändern des Statuses vom aktuellen Index, wird nicht der alte Status geändert(-> geht sonst immer in Meat rein)
                        _selections[0] = false;
                        _selections[1] = false;
                        _selections[2] = false;
                        _selecteditem = false;

                        //Sorgt für Statusänderung des geklickten Buttons
                        _selections[index] = !_selections[index];

                        //Meat
                        if (_selections[0] == true) {
                          _selections[1] = false; //Vegan
                          _selections[2] = false; //Vegetarian
                          setState(() {
                            _selecteditem = true;
                          });
                        }
                        //Vegan
                        if (_selections[1] == true) {
                          _selections[0] = false; //Meat
                          _selectionsfree[1] = true; //Lactose (andere Liste)
                          _selections[2] = false; //Vegetarian
                          setState(() {
                            _selecteditem = true;
                          });
                        }
                        //Vegetarisch
                        if (_selections[2] == true) {
                          _selections[0] = false; //Meat
                          _selections[1] = false; //Vegan
                          setState(() {
                            _selecteditem = true;
                          });
                        }
                      });
                    },
                  ),
                ),

                Padding(
                  padding: EdgeInsets.only(top: 10, bottom: 16),
                  child: ToggleButtons(
                    selectedColor: Colors.black,
                    renderBorder: false,
                    fillColor: Colors.black12,
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.only(
                          right: 25,
                          left: 25,
                          top: 15,
                          bottom: 15,
                        ),
                        child: Text('Gluten free'),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(
                          right: 25,
                          left: 25,
                          top: 15,
                          bottom: 15,
                        ),
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
                      Form(
                        key: _proteinKey,
                        child: TextFormField(
                          onChanged: (textProtein) {
                            setState(() {
                              protein = double.parse(_protein.text
                                      .trim()
                                      .replaceAll(' ', '')) *
                                  4.1;
                            });
                          },
                          validator: RequiredValidator(
                              errorText: "Enter the amount of protein."),
                          keyboardType: TextInputType.number,
                          controller: _protein,
                          textInputAction: TextInputAction.next,
                          decoration: InputDecoration(
                            labelText: 'Protein',
                            suffixText: 'g',
                          ),
                          maxLength: 6,
                        ),
                      ),
                      Form(
                        key: _carbsKey,
                        child: TextFormField(
                          onChanged: (textCarbs) {
                            setState(() {
                              carbs = double.parse(
                                      _carbs.text.trim().replaceAll(' ', '')) *
                                  4.1;
                            });
                          },
                          validator: RequiredValidator(
                              errorText: "Enter the amount of carbs."),
                          keyboardType: TextInputType.number,
                          controller: _carbs,
                          textInputAction: TextInputAction.next,
                          decoration: InputDecoration(
                            labelText: 'Carbs',
                            suffixText: 'g',
                          ),
                          maxLength: 6,
                        ),
                      ),
                      Form(
                        key: _fatKey,
                        child: TextFormField(
                          onChanged: (textFat) {
                            setState(() {
                              fat = double.parse(
                                      _fat.text.trim().replaceAll(' ', '')) *
                                  9.3;
                            });
                          },
                          validator: RequiredValidator(
                              errorText: "Enter the amount of fat."),
                          keyboardType: TextInputType.number,
                          controller: _fat,
                          textInputAction: TextInputAction.next,
                          decoration: InputDecoration(
                            labelText: 'Fat',
                            suffixText: 'g',
                          ),
                          maxLength: 6,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 15.0, bottom: 15),
                        child: Card(
                          color: Color.fromRGBO(225, 212, 197, 1),
                          child: Padding(
                            padding: const EdgeInsets.all(15.0),
                            child: Container(
                              alignment: Alignment.center,
                              child: Text(
                                "Calories: " +
                                    (protein + carbs + fat).toInt().toString() +
                                    " kcal",
                                style: TextStyle(),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
                  child: SingleChildScrollView(
                    child: Form(
                      key: _stepsKey,
                      child: IntrinsicHeight(
                        child: TextFormField(
                          validator:
                              RequiredValidator(errorText: 'Enter the Steps'),
                          controller: _steps,
                          decoration: InputDecoration(
                            border: OutlineInputBorder(),
                            labelText: 'Steps',
                          ),
                          maxLength: 2000,
                          maxLines: null,
                        ),
                      ),
                    ),
                  ),
                ),

                Card(
                  child: Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 18, vertical: 6),
                    child: TextButton(
                      onPressed: () async {
                        if (_nameKey.currentState.validate() &&
                            _proteinKey.currentState.validate() &&
                            _carbsKey.currentState.validate() &&
                            _fatKey.currentState.validate() &&
                            _stepsKey.currentState.validate() &&
                            _cardList.length >= 2 &&
                            _selecteditem == true &&
                            imageUrl != null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              backgroundColor: Colors.green,
                              content: Text(
                                'You created a recipie.',
                                style: TextStyle(
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          );
                          await saveRecipes(); //Aufruf zur Speicherung der Eingaben
                          await getLastKey();
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => recipe()));
                        } else {
                          if (_cardList.length < 2) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                backgroundColor: Colors.red,
                                content: Text(
                                  'Enter two or more ingredients',
                                  style: TextStyle(
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            );
                          }
                        }
                        if (_selecteditem == false) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              backgroundColor: Colors.red,
                              content: Text(
                                'Choose between Meat, Vegan, Vegetarian.',
                                style: TextStyle(
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          );
                        }
                        if (imageUrl == null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              backgroundColor: Colors.red,
                              content: Text(
                                'Insert a photo.',
                                style: TextStyle(
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          );
                        }
                      },
                      child: Text('Save'),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  //Speichern eines Rezeptes
  Future saveRecipes() async {
    saveIngredients();

    String currentEmail = box.get('currentEmail');

    //Bild hochladen in Firebase (Storage)
    var file = File(image.path);
    var snapshot = await storage
        .ref()
        .child('recipesImages/' +
            image.path.substring(image.path.lastIndexOf('/') + 1))
        .putFile(file);

    //Image URL in Variable gespeichert für späteres speichern im Rezeptdatensatz
    String imageurl = await snapshot.ref.getDownloadURL();

    //Auslesen der Benutzereingaben für Rezeptdatensatz
    String name = _name.text;
    String protein = _protein.text.trim().replaceAll(' ', '');
    String carbs = _carbs.text.trim().replaceAll(' ', '');
    String fat = _fat.text.trim().replaceAll(' ', '');
    String steps = _steps.text;

    int proteinNumber = int.parse(_protein.text.trim().replaceAll(' ', ''));
    int carbsNumber = int.parse(_carbs.text.trim().replaceAll(' ', ''));
    int fatNumber = int.parse(_fat.text.trim().replaceAll(' ', ''));
    double caloriesNumber =
        proteinNumber * 4.1 + carbsNumber * 4.1 + fatNumber * 9.3;
    String calories = caloriesNumber.round().toString();

    String meat = _selections[0].toString();
    String vegan = _selections[1].toString();
    String vegetarian = _selections[2].toString();
    String glutenfree = _selectionsfree[0].toString();
    String lactosefree = _selectionsfree[1].toString();

    //Zusammenfassung der Rezeptinahlte in JSON Format
    Map<String, String> recipes = {
      'email': currentEmail,
      'name': name,
      'protein': protein,
      'carbs': carbs,
      'fat': fat,
      'calories': calories,
      'steps': steps,
      'meat': meat,
      'vegetarian': vegetarian,
      'vegan': vegan,
      'glutenfree': glutenfree,
      'lactosefree': lactosefree,
      'imageurl': imageurl,
      'ingredients': ingredients
    };

    //Hochladen des Rezeptes in die Realtime Database (als JSON Format)
    await databaseReference.push().set(recipes);
  }

  Future getLastKey() async {
    //Push Key aus Firebase erhalten des letzen Rezepteintrags
    await databaseReference.once().then((DataSnapshot snapshot) {
      snapshot.value.forEach((key, values) {
        recipeCode = key;
      });
      boxPushKey.put('pushkey', recipeCode);

      // Liste erstellen, um alle Erstellten Rezepte auf der Seite allCreatedRecipes anzuzeigen.
      currentLoggedInUserEmail = boxCurrentEmail.get('currentEmail');
      if (boxAllCreatedRecipes.get('$currentLoggedInUserEmail') != null) {
        allCreatedRecipesList =
            boxAllCreatedRecipes.get('$currentLoggedInUserEmail');
        allCreatedRecipesList.add(recipeCode);
        boxAllCreatedRecipes.put(
            '$currentLoggedInUserEmail', allCreatedRecipesList);
      } else {
        allCreatedRecipesList.add(recipeCode);
        boxAllCreatedRecipes.put(
            '$currentLoggedInUserEmail', allCreatedRecipesList);
      }
    });
  }

  //Auswählen eines Bildes aus der Gallery des Handys
  selectCamera() async {
    image =
        await picker.pickImage(source: ImageSource.camera, imageQuality: 20);

    if (image != null) {
      setState(() {
        imageUrl = image.path;
      });
    } else {
      print('No Path Received');
    }
  }

  selectGallery() async {
    image =
        await picker.pickImage(source: ImageSource.gallery, imageQuality: 20);

    if (image != null) {
      setState(() {
        imageUrl = image.path;
      });
    } else {
      print('No Path Received');
    }
  }

  void showPicker(context) {
    showModalBottomSheet(
        context: context,
        builder: (BuildContext bc) {
          return SafeArea(
            child: Container(
              child: new Wrap(
                children: <Widget>[
                  new ListTile(
                      leading: new Icon(Icons.photo_library),
                      title: new Text('Gallery'),
                      onTap: () {
                        selectGallery();
                        Navigator.of(context).pop();
                      }),
                  new ListTile(
                    leading: new Icon(Icons.photo_camera),
                    title: new Text('Camera'),
                    onTap: () {
                      selectCamera();
                      Navigator.of(context).pop();
                    },
                  ),
                ],
              ),
            ),
          );
        });
  }

  //Methode zum erstellen der Ingredient Einträge (Widgets)
  Widget _card() {
    String ingredientAmount = _ingredientAmount.text.trim().replaceAll(' ', '');
    String ingredientName = _ingredientName.text;
    ingredientList.add('$ingredientAmount' +
        unit +
        ' ' +
        '$ingredientName' +
        '\n'); //Muss noch auswählbar sein und angepasst werden (g, ml, usw...)

    return Card(
      color: Color.fromRGBO(225, 212, 197, 1),
      child: Center(
        child: ListTile(
          title: Text(_ingredientName.text),
          subtitle: Text(_ingredientAmount.text.trim().replaceAll(' ', '') +
              unit.toString()),
        ),
      ),
    );
  }

  //Ingredient Liste wird aufgefüllt
  void _addCardWidget() {
    setState(() {
      _cardList.add(_card());
    });
  }

  saveIngredients() {
    for (int i = 0; i < ingredientList.length; i++) {
      ingredients = ingredients + ingredientList[i];
    }
  }
}
