import 'package:flutter/material.dart';
import 'package:ue1_basisprojekt/db/character.dart';

class CharacterDetailScreen extends StatelessWidget {
  final Character character;

  const CharacterDetailScreen({Key key, @required this.character }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(character.name)),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: ListView(
            children: [
              _buildTextRow('Gender', character.gender),
              SizedBox(height: 8),
              _buildTextRow('Aliases', character.aliases.join(',\n')),
              SizedBox(height: 8),
              _buildTextRow('Culture', character.culture),
              SizedBox(height: 8),
              _buildTextRow('Born', character.born),
              SizedBox(height: 8),
              _buildTextRow('Died', character.died),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextRow(String key, String value) {
    return Row(
      children: [
        Text(
          key,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 17,
          ),
        ),
        SizedBox(width: 8),
        Expanded(
          child: Text(
            value,
            style: TextStyle(fontSize: 17),
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.end,
          ),
        ),
      ],
    );
  }
}
