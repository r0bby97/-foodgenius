import 'package:firebase_auth/firebase_auth.dart';
import 'package:hive/hive.dart';

class authentication {
  final FirebaseAuth firebaseAuth;
  String errorMessage;
  var signUpError = Hive.box('signUpError');
  var signInError = Hive.box('signInError');

  authentication(this.firebaseAuth);

  Stream<User> get authStateChanges => firebaseAuth.authStateChanges();


  Future<String> signIn({String email, String password}) async {
    try {
      var box = Hive.box('currentEmail');
      box.put('currentEmail', email);

      await firebaseAuth.signInWithEmailAndPassword(
          email: email, password: password);
      return "Signed in";
    } on FirebaseAuthException catch (error) {
      errorMessage = "Wrong E-Mail or Password.";
      signInError.put('signInError', errorMessage);
    }
  }

  Future<String> signUp({String email, String password}) async {
    try {
      await firebaseAuth.createUserWithEmailAndPassword(
          email: email, password: password);
      signOut();
      return "Signed up";
    }
    on FirebaseAuthException catch (error) {
          errorMessage = "E-Mail already used. Go to Login.";
          signUpError.put('signUpError', errorMessage);
    }
  }

  Future<String> signOut({String email, String password}) async {
      await firebaseAuth.signOut();
  }
}