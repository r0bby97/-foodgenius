 //imports

import 'package:firebase_database/firebase_database.dart';

class Recipes{

  DatabaseReference recipeID;
  String name;
  //image photo;
  int carbs;
  int protein;
  int fat;
  int specification;
  String ingredients;
  String steps;

  Recipes(this.name,
          //this.photo,
          this.carbs,
          this.protein,
          this.fat,
          this.specification,
          this.ingredients,
          this.steps);

  //Eindeutige Zuweisung eines Rezeptes über die ID
  void setID(DatabaseReference id){
    this.recipeID = id;
  }

  //Eingabe zu JSON File für Übergabe in die Firebase Datenbank
  Map<String, dynamic> toJson(){
    return{
      'name': this.name,
    //'photo': this.photo,
      'carbs': this.carbs,
      'protein': this.protein,
      'fat': this.fat,
      'specification': this.specification,
      'ingredients': this.ingredients,
      'steps': this.steps
    };
  }


}