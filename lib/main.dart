import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:ue1_basisprojekt/db/authentication.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';
import 'package:ue1_basisprojekt/db/character.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:ue1_basisprojekt/screens/home.dart';
import 'package:ue1_basisprojekt/screens/signIn.dart';
import 'package:flex_color_scheme/flex_color_scheme.dart';

Future<void> main() async {
  //final appDocumentDir = await path_provider.getApplicationDocumentsDirectory();
  //Hive.init(appDocumentDir.path);
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  Hive.registerAdapter(CharacterAdapter());
  await Hive.openBox('currentEmail');
  await Hive.openBox('ingredients');
  await Hive.openBox('pushkey');
  await Hive.openBox('searchResults');
  await Hive.openBox('pushkeySearchResult');
  await Hive.openBox('pushkeyHome');
  await Hive.openBox('favoriteRecipecodes');
  await Hive.openBox('pushkeyFavorites');
  await Hive.openBox('signUpError');
  await Hive.openBox('signInError');
  await Hive.openBox('allCreatedRecipes');
  await Hive.openBox('pushkeyAllCreatedRecipes');
  await Hive.openBox('lastButtonClicked');

  await Firebase.initializeApp();
const FlexSchemeColor mySchemaLight = FlexSchemeColor(
    primary: Color.fromRGBO(207, 185, 151, 1),
    primaryVariant: Color.fromRGBO(235, 222, 207, 1),
    secondary: Color.fromRGBO(221, 199, 160, 1),
    secondaryVariant: Color.fromRGBO(221, 199, 160, 1),
  error: Colors.red,
);

  runApp(
    MultiProvider(
      providers: [Provider<authentication>(
        create: (_) => authentication(FirebaseAuth.instance),
      ),

        StreamProvider(create: (context) => context.read<authentication>().authStateChanges,),
      ],
    child: MaterialApp(
      title: 'foodgenius',
      theme: FlexThemeData.light(colors:mySchemaLight, scaffoldBackground: Color.fromRGBO(255, 242, 227, 1), appBarBackground: Color.fromRGBO(225, 212, 197, 1), ),
      // The Mandy red, dark theme.
      //darkTheme: FlexThemeData.dark(colors:mySchemaLight.toDark(),
      //),
      // Use dark or light theme based on system setting.
      //: ThemeMode.system,
      debugShowCheckedModeBanner: false,
      home: authenticationWrapper(),
      //home: login(),
    ),
    ));
  }


  //Prüfung ob bereits eingeloggt, wenn nicht return zum login
  class authenticationWrapper extends StatelessWidget {
    const authenticationWrapper({
      Key key,
    }) : super(key: key);

    Widget build(BuildContext context) {
      final firebaseUser = context.watch<User>();
      print("---------------USER---------------");
      print(firebaseUser);
      print("-----------------------------------");

      if(firebaseUser != null) {

        return homepage();
      }
        return login();
    }


}
