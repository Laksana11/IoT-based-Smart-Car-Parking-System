import 'package:car_park/screens/signup.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../reusable_widgets/reusable_widgets.dart';
import 'forgot_pw.dart';
import 'home.dart';



class Login extends StatefulWidget {
  const Login({Key? key}) : super(key: key);

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  TextEditingController _passwordTextController = TextEditingController();
  TextEditingController _emailTextController = TextEditingController();
  List<TextInputFormatter> passwordInputFormatter = [];
  List<TextInputFormatter> emailInputFormatter = [
    FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z0-9@._-]')),
  ];

  String _errorMessage = '';

  SharedPreferences? _prefs;
  bool _isMounted = false;

  @override
  void initState() {
    super.initState();
    _isMounted = true;
  }

  @override
  void dispose() {
    super.dispose();
    _isMounted = false;
  }



  Future<void> setUser(String uid) async {
    if (_prefs == null) {
      _prefs = await SharedPreferences.getInstance();
    }
    _prefs?.setString('uid', uid);
  }


  @override
  Widget build(BuildContext context) {
    void navigateToRoleScreen() {
      Navigator.push(
          context, MaterialPageRoute(builder: (context) => Home()));
    }

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: Container(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
            decoration: BoxDecoration(
              color: Color(0xff22a6b3)
            ),
            child: SingleChildScrollView(
                child: Padding(
                    padding: EdgeInsets.fromLTRB(
                        20, MediaQuery.of(context).size.height * 0.2, 20, 0),
                    child: Column(
                      children: <Widget>[
                        Container(
                          child: CircleAvatar(
                            radius: 150.0,
                            backgroundImage:
                            AssetImage('assets/images/car images.jpg'),
                          ),
                        ),
                        SizedBox(
                          height: 30,
                        ),
                        reusableTextField(
                          "Enter your Email",
                          Icons.email_outlined,
                          false,
                          _emailTextController,
                        ),
                        SizedBox(
                          height: 30,
                        ),
                        reusableTextField(
                            "Enter your Password",
                            Icons.lock_outline,
                            true,
                            _passwordTextController),
                        if (_errorMessage
                            .isNotEmpty) // Only show the error message when it's not empty
                          Text(
                            _errorMessage,
                            style: TextStyle(color: Color(0xff22a6b3)),
                          ),
                        GestureDetector(
                          onTap: () {
                            Navigator.push(context,
                                MaterialPageRoute(builder: (context) {
                                  return ForgotPasswordPage();
                                }));
                          },
                          child: Text(
                            'Forgot Password',
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                        SizedBox(
                          height: 20,
                        ),
                        signInSignUpButton(context, 'Sign In', () async {
                          try {
                            var userCredential = await FirebaseAuth.instance
                                .signInWithEmailAndPassword(
                              email: _emailTextController.text,
                              password: _passwordTextController.text,
                            );

                            String? uid = userCredential.user?.uid;
                            setUser(uid!);
                            FirebaseFirestore _firestore =
                                FirebaseFirestore.instance;
                            DocumentSnapshot userSnapshot = await _firestore
                                .collection('users')
                                .doc(uid)
                                .get();

                            navigateToRoleScreen();
                            _emailTextController.clear();
                            _passwordTextController.clear();
                          } catch (e) {
                            print("Error: $e");
                            if (_isMounted) {
                              setState(() {
                                _errorMessage = 'Invalid email or password';
                              });
                            }
                          }
                        }),
                        Container(
                          margin: EdgeInsets.only(top: 10),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              Text(
                                'Don\'t have an account? ',
                                style: TextStyle(color: Colors.white),
                              ),
                              GestureDetector(
                                onTap: () {
                                  Navigator.push(context, MaterialPageRoute(builder: (context) => Signup()));
                                },
                                child: Text(
                                  'Create an account',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],

                    )))),
      ),
    );
  }
}
