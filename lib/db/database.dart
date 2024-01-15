import 'package:flutter/material.dart';
import 'package:ue1_basisprojekt/db/character.dart';
import 'package:hive/hive.dart';
import 'dart:developer';

//The class shall be responsible to store the GoT characters loaded from the API in a database
class Database {
  //The method shall load all stored GoT characters and return them as array
  //TODO: Die Charaktere aus einer richtigen Datenbank laden.
  List<Character> get storedCharacters {
    final List<Character> characters = Hive.box<Character>('api_data').values.toList();
    return characters;
  }

  //The method is to store a list of GoT characters in a database
  Future<void> save({@required List<Character> characters}) async {
    int count = 0;
    if (characters != null && characters.isNotEmpty) {
      //TODO: `characters` in einer richtigen Datenbank speichern.
      var box = Hive.box<Character>('api_data');
      List<Character> newList = [];
      int length = characters.length;
      int exists = 0;

      for (int i = 0; i<length; i++){
        int newListLength = newList.length;
        for (int j = 0; j<newListLength; j++) {
          if (newList[j].name == characters[i].name) {
            exists++;
          }
        }
        if (exists == 0) {
          box.put(characters[i].name, characters[i]);
          count++;
        }
        exists = 0;
      }
    }
    print("Speichere " + count.toString() + " Charakter.");
    //print("Boxlängen: ");
  }
}
