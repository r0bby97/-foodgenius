// The class is responsible to load the GoT characters from the GoTAPI (on https://anapioficeandfire.com/)
import 'dart:async';
import 'dart:convert';
import 'package:hive/hive.dart';
import 'package:ue1_basisprojekt/db/character.dart';
import 'package:http/http.dart' as http;
import 'package:ue1_basisprojekt/db/database.dart';

class API {
  // Note: the documentation for the API can be found here: https://anapioficeandfire.com/Documentation
  String _charactersRouteTeil1 = "https://www.anapioficeandfire.com/api/characters?page=";
  String _charactersRouteTeil2 = "&pageSize=100";

  // Loads the list of GoT characters
  Future<List<Character>> fetchRemoteGoTCharacters() async {
    // TODO: Load GoT characters from the _charactersRoute and return them.
    // For the API calls we recommend to use the 'http' package

    List<Character> characterList = [];

    for (int pageCounter = 1; characterList.length<200; pageCounter++) {
      print(_charactersRouteTeil1 + pageCounter.toString() + _charactersRouteTeil2);
      var response = await http.get(Uri.parse(_charactersRouteTeil1 + pageCounter.toString() + _charactersRouteTeil2));
      var jsonResponse = jsonDecode(response.body);

      if (response.statusCode != 200) {
        throw "Error While Retrieving Data from API";
      }

      for (var char in jsonResponse) {
        if (char['name'] != '' && char['name'] != null &&
            char['gender'] != '' && char['gender'] != null &&
            List.from(char['aliases']).toString().length > 2 && List.from(char['aliases']) != null) { //>2 da die Leeren eine länge von 2 haben
          Character character = Character(
            name: char['name'],
            gender: char['gender'],
            aliases: List.from(char['aliases']),
            culture: char['culture'],
            born: char['born'],
            died: char['died'],
          );
          characterList.add(character);
        }
      }
    }
    Database().save(characters: characterList);
    return Database().storedCharacters;
  }
}