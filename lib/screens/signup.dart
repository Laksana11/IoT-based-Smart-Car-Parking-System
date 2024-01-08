import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../reusable_widgets/reusable_widgets.dart';

class Signup extends StatefulWidget {
  const Signup({Key? key}) : super(key: key);

  @override
  State<Signup> createState() => _SignupState();
}

class _SignupState extends State<Signup> {
  TextEditingController _userNameTextController = TextEditingController();
  TextEditingController _passwordTextController = TextEditingController();
  TextEditingController _confirmPasswordTextController =
      TextEditingController();
  TextEditingController _emailTextController = TextEditingController();

  bool _isPasswordVisible = false;
  bool _isPasswordMatch = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          "Create new user",
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
      ),
      body: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        decoration: BoxDecoration(
          color: Colors.black,
        ),
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.fromLTRB(
              20,
              MediaQuery.of(context).size.height * 0.1,
              20,
              0,
            ),
            child: Column(
              children: <Widget>[
                reusableTextField("Enter Username", Icons.person_outline, false,
                    _userNameTextController),
                const SizedBox(height: 20),
                reusableTextField("Enter Email Id", Icons.mail_outline, false,
                    _emailTextController),
                const SizedBox(height: 20),
                reusableTextField(
                  "Enter Password",
                  Icons.lock_outlined,
                  !_isPasswordVisible,
                  _passwordTextController,
                  suffixIcon: IconButton(
                    icon: Icon(
                      _isPasswordVisible
                          ? Icons.visibility_off
                          : Icons.visibility,
                      color: Colors.white70,
                    ),
                    onPressed: () {
                      setState(() {
                        _isPasswordVisible = !_isPasswordVisible;
                      });
                    },
                  ),
                ),
                const SizedBox(height: 20),
                reusableTextField(
                  "Enter Password again",
                  Icons.lock_outlined,
                  !_isPasswordVisible,
                  _confirmPasswordTextController,
                  suffixIcon: IconButton(
                    icon: Icon(
                      _isPasswordVisible
                          ? Icons.visibility_off
                          : Icons.visibility,
                      color: Colors.white70,
                    ),
                    onPressed: () {
                      setState(() {
                        _isPasswordVisible = !_isPasswordVisible;
                      });
                    },
                  ),
                ),
                if (!_isPasswordMatch)
                  const SizedBox(
                    height: 20,
                    child: Text(
                      "Passwords do not match",
                      style: TextStyle(color: Colors.red),
                    ),
                  ),
                const SizedBox(height: 20),
                signInSignUpButton(context, 'Create User', () {
                  if (_userNameTextController.text.isEmpty ||
                      _emailTextController.text.isEmpty ||
                      _passwordTextController.text.isEmpty ||
                      _confirmPasswordTextController.text.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Please fill all fields')),
                    );
                    return;
                  } else if (_passwordTextController.text !=
                      _confirmPasswordTextController.text) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Passwords do not match')),
                    );
                    return;
                  }

                  FirebaseAuth.instance
                      .createUserWithEmailAndPassword(
                    email: _emailTextController.text,
                    password: _passwordTextController.text,
                  )
                      .then((value) {
                    // PushToken();
                    // pushToken = await FirebaseMessaging.instance.getToken();
                    String? uid = value.user?.uid;
                    String? email = value.user?.email;
                    String? username = _userNameTextController.text;
                    //Save the user data to the firestore db
                    CollectionReference usersCollection =
                        FirebaseFirestore.instance.collection('users');
                    usersCollection.doc(uid).set({
                      'username': username,
                      'email': email,
                    }).then((_) {
                      print("Created New account");
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                            content: Text('Account created successfully!')),
                      );
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => Signup()),
                      );
                    }).onError((error, stackTrace) {
                      print("Error ${error.toString()}");
                    });
                  });
                }),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
