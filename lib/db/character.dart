import 'package:flutter/material.dart';
import 'dart:developer';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';

part 'character.g.dart';

@HiveType(typeId: 1)
class Character {

  @HiveField(0)
  final String name;

  @HiveField(1)
  final String gender;

  @HiveField(2)
  final List<String> aliases; // Können mehrer Alias-Namen besitzen, daher List.

  @HiveField(3)
  final String culture;

  @HiveField(4)
  final String born;

  @HiveField(5)
  final String died;


  // normaler Constructor
  Character({
    @required this.name,
    @required this.gender,
    @required this.aliases,
    @required this.culture,
    @required this.born,
    @required this.died,
  });
}
