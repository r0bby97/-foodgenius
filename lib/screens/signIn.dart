import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:ue1_basisprojekt/db/authentication.dart';
import 'package:ue1_basisprojekt/screens/signUp.dart';
import 'package:provider/provider.dart';

class login extends StatefulWidget {
  const login({Key key}) : super(key: key);

  @override
  _login createState() => _login();
}

class _login extends State<login> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  var signInError = Hive.box('signInError');
  String error;

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        onWillPop: _onBackPress,
        child: Scaffold(
      body: Stack(
        children: <Widget>[
          Container(
            height: double.infinity,
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(
                horizontal: 40.0,
                vertical: 100.0,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
              Container(height: 200,
              child: Image(
              image: AssetImage("assets/images/AppLogo.png"),
                //"android/app/src/main/res/mipmap-xxxhdpi/ic_launcher.png"
              fit: BoxFit.fitWidth,
              alignment: Alignment.topCenter,
                  ),
                ),
                  // Text('Login',
                  //   style: TextStyle(fontSize: 25),),
                  SizedBox(
                    height: 30.0,
                  ),
                  _buildEmailTF(),
                  SizedBox(
                    height: 30.0,
                  ),
                  _buildPasswordTF(),
                  // _bulidForgotPassword(),
                  _buildSignInButton(),
                  _buildSignUpButton(),
                ],
              ),
            ),
          ),
        ],
      ),
    ),
    );
  }

  Future<bool> _onBackPress() {
    return showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text("Do you really want to exit the app?"),
          actions: <Widget>[
            TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: Text('No')),
            TextButton(
                onPressed: () => exit(0),
                // Navigator.pop(context, true),
                child: Text('Yes')),
          ],
        ));
  }

  Widget _buildEmailTF() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text('Email'),
        Container(
          alignment: Alignment.centerLeft,
          child: TextField(
            keyboardType: TextInputType.emailAddress,
            controller: emailController,
            textInputAction: TextInputAction.next,
            decoration: InputDecoration(
                prefixIcon: Icon(Icons.email), hintText: 'Enter your Email'),
          ),
        ),
      ],
    );
  }

  Widget _buildPasswordTF() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text('Password'),
        Container(
          alignment: Alignment.centerLeft,
          child: TextField(
            obscureText: true,
            textInputAction: TextInputAction.done,
            onEditingComplete: () async {
              await context.read<authentication>().signIn(email: emailController.text, password: passwordController.text);
              if(signInError.get('signInError') == null){
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    backgroundColor: Colors.green,
                    content: Text(
                      'Logged in successfully.',
                      style: TextStyle(
                        color: Colors.white,
                      ),
                    ),
                  ),);
              }else{
                error = signInError.get('signInError');
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    backgroundColor: Colors.red,
                    content: Text(
                      '$error',
                      style: TextStyle(
                        color: Colors.white,
                      ),
                    ),
                  ),);

                signInError.clear();
              }
            },
            controller: passwordController,
            decoration: InputDecoration(
                prefixIcon: Icon(
                  Icons.lock,
                ),
                hintText: 'Enter your Password'),
          ),
        ),
      ],
    );
  }

  Widget _buildSignInButton() {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 25.0),
      width: double.infinity,
      child: RaisedButton(
        elevation: 5.0,
        onPressed: () async {
            await context.read<authentication>().signIn(email: emailController.text, password: passwordController.text);
            if(signInError.get('signInError') == null){
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  backgroundColor: Colors.green,
                  content: Text(
                    'Logged in successfully.',
                    style: TextStyle(
                      color: Colors.white,
                    ),
                  ),
                ),);
            }else{
              error = signInError.get('signInError');
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  backgroundColor: Colors.red,
                  content: Text(
                    '$error',
                    style: TextStyle(
                      color: Colors.white,
                    ),
                  ),
                ),);

              signInError.clear();
            }
          },

        padding: EdgeInsets.all(15.0),
        child: Text('LOGIN'),
      ),
    );
  }

  Widget _buildSignUpButton() {
    return GestureDetector(
      onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (context) => SignUp()));
        },
      child: RichText(
        text: TextSpan(
          children: [
            TextSpan(text: 'I don"t have an account? ', style: TextStyle(
          color: Color.fromRGBO(50, 50, 50, 1)),
            ),
            TextSpan(
              text: 'Create Account',
              style: TextStyle(
                color: Color.fromRGBO(177, 155, 121, 1),
                  fontWeight:
                  FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
