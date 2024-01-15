import 'package:flutter/material.dart';
import 'package:ue1_basisprojekt/db/character.dart';
import 'package:ue1_basisprojekt/db/database.dart';
import 'package:ue1_basisprojekt/networking/api.dart';
import 'package:ue1_basisprojekt/screens/character_detail_screen.dart';

class CharactersListScreen extends StatefulWidget {
  @override
  _CharactersListScreenState createState() => _CharactersListScreenState();
}

class _CharactersListScreenState extends State<CharactersListScreen> {
  List<Character> characters;
  List searchRequest = [];
  bool currentlySearching = false;

  @override
  void initState() {
    // first the characters are loaded from the database and displayed
    characters = Database().storedCharacters;
    searchRequest = Database().storedCharacters;
    print("Gespeicherte Charactere zu Beginn: " + characters.length.toString() + ".");

    // Prüft, ob bereits 100 Character gespeichert sind, wenn nicht werden sie aus der API geladen.
    if (characters.length < 100) {

      // then the characters are loaded from the API and displayed as soon as they are there
      API().fetchRemoteGoTCharacters().then((characters) {
        setState(() {
          // the setState method re-renders the UI
          this.characters = characters;
          this.searchRequest = characters;
        });
      });
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        //title: Text('Game of Thrones Characters'),
        title: !currentlySearching ? Text('Game of Thrones Characters') :TextField(
          onChanged: (input){searchCharacters(input);},
          style: TextStyle(color: Colors.white),
          decoration: InputDecoration(
            icon: Icon(Icons.search, color: Colors.white),
            hintText: "Search your character...",
            hintStyle: TextStyle(color:Colors.white),
          ),
        ),
        actions: <Widget>[
          currentlySearching ?
          IconButton(
            icon: Icon(Icons.cancel),
            onPressed:() {
              setState(() {
                this.currentlySearching = false;
                searchRequest = characters;
              });
            },
          ):
          IconButton(
            icon: Icon(Icons.search),
            onPressed:() {
              setState(() {
                this.currentlySearching = true;
              });
            },
          ),
        ],
      ),
      body: SafeArea(
        child: ListView.separated(
          itemBuilder: (context, index) => _buildCharacterListTile(index),
          separatorBuilder: (_, __) => Divider(),
          //itemCount: characters.length,
          itemCount: searchRequest.length,
        ),
      ),
    );
  }

  Widget _buildCharacterListTile(int index) {
    final Character character = searchRequest[index];
    //final Character character = characters[index];
    return ListTile(
      title: Text(
        character.name,
        style: TextStyle(fontSize: 17),
      ),
      trailing: Icon(Icons.arrow_right_rounded),
      onTap: () {
        //TODO: open the CharacterDetailScreen with the character
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => CharacterDetailScreen(character: searchRequest[index])),
        );
      },
    );
  }

  // Suche mit der Searchbar die aktuelle Eingabe.
  void searchCharacters(input) {
    setState(() {
      searchRequest = characters.where((display) => display.name.toLowerCase().contains(input.toLowerCase())).toList();
    });
  }

}

