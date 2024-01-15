import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:ue1_basisprojekt/db/authentication.dart';
import 'package:provider/provider.dart';
import 'package:ue1_basisprojekt/screens/signIn.dart';
import 'package:ue1_basisprojekt/screens/home.dart';

import '../main.dart';

class SignUp extends StatefulWidget {
  const SignUp({Key key}) : super(key: key);

  @override
  _signUp createState() => _signUp();
}

class _signUp extends State<SignUp> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController passwordConfirmController =
      TextEditingController();
  String _name, _email;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  var signUpError = Hive.box('signUpError');
  String error;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: <Widget>[
          Container(
            height: double.infinity,
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(
                horizontal: 40.0,
                vertical: 100.0,
              ),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Container(
                      height: 200,
                      child: Image(
                        image: AssetImage("assets/images/AppLogo.png"),
                        //"android/app/src/main/res/mipmap-xxxhdpi/ic_launcher.png"
                        fit: BoxFit.fitWidth,
                        alignment: Alignment.topCenter,
                      ),
                    ),
                    // Text('Create Account',
                    // style: TextStyle(fontSize: 25),),
                    SizedBox(
                      height: 30.0,
                    ),
                    _buildEmailTF(),
                    SizedBox(
                      height: 30.0,
                    ),
                    _buildPasswordTF(),
                    SizedBox(
                      height: 30.0,
                    ),
                    _buildConfrimPasswordTF(),
                    _buildSignUpButton(),
                    _buildSignInButton(),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmailTF() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text('Email'),
        Container(
          alignment: Alignment.centerLeft,
          child: TextFormField(
            keyboardType: TextInputType.emailAddress,
            controller: emailController,
            textInputAction: TextInputAction.next,
            validator: (value) {
              if (value.isEmpty) {
                return "Please enter your Email";
              }
              if (!RegExp("^[a-zA-Z0-9+_.-]+@[a-zA-Z0-9+_.-]+.[a-z]")
                  .hasMatch(value)) {
                return "Please enter valid Email";
              }
              if (emailController.text.contains(".de") ||
                  emailController.text.contains(".net") ||
                  emailController.text.contains(".com") ||
                  emailController.text.contains(".org") ||
                  emailController.text.contains(".ru") ||
                  emailController.text.contains(".ir") ||
                  emailController.text.contains(".in") ||
                  emailController.text.contains(".uk") ||
                  emailController.text.contains(".au") ||
                  emailController.text.contains(".ua") ||
                  emailController.text.contains(".tk") ||
                  emailController.text.contains(".cn") ||
                  emailController.text.contains(".nl") ||
                  emailController.text.contains(".icu") ||
                  emailController.text.contains(".xyz") ||
                  emailController.text.contains(".top") ||
                  emailController.text.contains(".site") ||
                  emailController.text.contains(".online") ||
                  emailController.text.contains(".info") ||
                  emailController.text.contains(".swiss") ||
                  emailController.text.contains(".at")) {
                return null;
              }
              return "Please enter valid Email";
            },
            decoration: InputDecoration(
                prefixIcon: Icon(Icons.email), hintText: 'Enter your Email'),
            onSaved: (String email) {
              _email = email;
            },
          ),
        ),
      ],
    );
  }

  Widget _buildPasswordTF() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text('Enter Password'),
        Container(
          alignment: Alignment.centerLeft,
          child: TextFormField(
            obscureText: true,
            textInputAction: TextInputAction.next,
            controller: passwordController,
            decoration: InputDecoration(
                prefixIcon: Icon(
                  Icons.lock,
                ),
                hintText: 'Enter your password.',
                errorMaxLines: 2),
            validator: (value) {
              RegExp regex = RegExp(r'^(?=.*?[a-zA-Z])(?=.*?[0-9]).{8,}$');
              if (value.isEmpty) {
                return "Please enter password.";
              }
              if (!regex.hasMatch(value)) {
                return "Password must be at least 8 characters long and include a number.";
              }
              return null;
            },
          ),
        ),
      ],
    );
  }

  Widget _buildConfrimPasswordTF() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text('Confirm Password'),
        Container(
          alignment: Alignment.centerLeft,
          child: TextFormField(
            obscureText: true,
            textInputAction: TextInputAction.done,
            onEditingComplete: () async {
              if (_formKey.currentState.validate()) {
                await context.read<authentication>().signUp(
                    email: emailController.text,
                    password: passwordController.text);
                if (signUpError.get('signUpError') == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      backgroundColor: Colors.green,
                      content: Text(
                        'You created your account.',
                        style: TextStyle(
                          color: Colors.white,
                        ),
                      ),
                    ),
                  );
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => authenticationWrapper()));
                } else {
                  error = signUpError.get('signUpError');

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      backgroundColor: Colors.red,
                      content: Text(
                        '$error',
                        style: TextStyle(
                          color: Colors.white,
                        ),
                      ),
                    ),
                  );

                  signUpError.clear();
                }
              } else {
                print("Unsuccessfull");
              }
            },
            controller: passwordConfirmController,
            decoration: InputDecoration(
                prefixIcon: Icon(
                  Icons.lock,
                ),
                hintText: 'Enter your Password'),
            validator: (value) {
              if (value.isEmpty) {
                return "Please enter the same Password";
              }
              if (passwordController.text != passwordConfirmController.text) {
                return "Passwords do not match";
              }
              return null;
            },
          ),
        ),
      ],
    );
  }

  Widget _buildSignUpButton() {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 25.0),
      width: double.infinity,
      child: RaisedButton(
        elevation: 5.0,
        onPressed: () async {
          if (_formKey.currentState.validate()) {
            await context.read<authentication>().signUp(
                email: emailController.text, password: passwordController.text);
            if (signUpError.get('signUpError') == null) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  backgroundColor: Colors.green,
                  content: Text(
                    'You created your account.',
                    style: TextStyle(
                      color: Colors.white,
                    ),
                  ),
                ),
              );
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => authenticationWrapper()));
            } else {
              error = signUpError.get('signUpError');

              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  backgroundColor: Colors.red,
                  content: Text(
                    '$error',
                    style: TextStyle(
                      color: Colors.white,
                    ),
                  ),
                ),
              );

              signUpError.clear();
            }
          } else {
            print("Unsuccessfull");
          }
        },
        padding: EdgeInsets.all(15.0),
        child: Text('Create Account'),
      ),
    );
  }

  Widget _buildSignInButton() {
    return GestureDetector(
      onTap: () {
        Navigator.push(
            context, MaterialPageRoute(builder: (context) => login()));
      },
      child: RichText(
        text: TextSpan(
          children: [
            TextSpan(
              text: 'I already have an Account.',
              style: TextStyle(color: Color.fromRGBO(50, 50, 50, 1)),
            ),
            TextSpan(
              text: ' Login',
              style: TextStyle(
                color: Color.fromRGBO(177, 155, 121, 1),
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
