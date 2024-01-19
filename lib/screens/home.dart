import 'dart:math';

import 'package:car_park/screens/parkingSlot.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

import '../utils/sharedPrefencesUtil.dart';
import 'checkAvailabiility.dart';

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  String slotName = "";
  void assignLockerToCurrentUser() async {
    // Initialize Firebase if you haven't already
    await Firebase.initializeApp();
    String userId = await SharedPreferencesUtil.getUser() ?? '';

    // Reference to your Firebase Realtime Database
    DatabaseReference databaseReference = FirebaseDatabase.instance.reference();

    // Query the database to find available lockers
    DatabaseEvent event = await databaseReference
        .child('parkingSlot')
        .orderByChild('availability')
        .equalTo('yes')
        .once();

    // Check if the event contains any data
    if (event.snapshot.value != null) {
      // Safely cast the Object? to Map<dynamic, dynamic>
      Map<dynamic, dynamic> slots =
          event.snapshot.value as Map<dynamic, dynamic>;

      // Convert the Map to a List of locker keys and cast them to String
      List<String> availableLockerKeys = slots.keys.cast<String>().toList();

      // Select a random locker from the available ones
      Random random = Random();
      int randomIndex = random.nextInt(availableLockerKeys.length);
      String randomSlotKey = availableLockerKeys[randomIndex];

      // Get the reference to the selected locker
      DatabaseReference selectedSlotRef =
          databaseReference.child('parkingSlot').child(randomSlotKey);

      // Assign the locker to the current user (replace 'currentUser' with the actual user identifier)
      // Replace with your user identifier
      await selectedSlotRef.update({'user': userId, 'availability': 'no'});

      print('Assigned slot $randomSlotKey to user $userId');
    } else {
      print('Sorry no any available slots there');
    }
  }

  void releaseLockerIfUserIsOut() async {
    // Initialize Firebase if you haven't already
    String userId = await SharedPreferencesUtil.getUser() ?? '';

    await Firebase.initializeApp();
    DatabaseReference databaseReference = FirebaseDatabase.instance.reference();

    DatabaseReference reference =
        FirebaseDatabase.instance.reference().child('parkingSlot');
    DataSnapshot snapshot = await reference.get();

    if (snapshot.value != null && snapshot.value is Map) {
      Map<dynamic, dynamic>? SlotsData = snapshot.value as Map?;

      // Iterate through the lockers and access their data
      SlotsData!.forEach((slotKey, slotValue) async {
        String user = slotValue['user'];
        if (user == userId) {
          slotName = slotKey;
        }
        DatabaseReference lockerRef = reference.child(slotName!);
        await lockerRef.update({'user': '', 'availability': 'yes'});
        // Check if the value is not null and is a Map
      });
    }
  }

  Future<void> handleButtonPress(String onClick) async {
    if (onClick == 'Requesting') {
      assignLockerToCurrentUser();
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.light,
        scaffoldBackgroundColor: Color(0xff22a6b3),
      ),
      home: Scaffold(
        appBar: AppBar(
          leading: CircleAvatar(
            radius: 150.0,
            backgroundImage: AssetImage('assets/images/car images.jpg'),
          ),
          // title: Text("JK Fitness"),
          backgroundColor: Colors.black,
          actions: [],
        ),
        body: Align(
          alignment: Alignment.center,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Container(
              height: 300.0,
              width: 500.0,
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.all(Radius.circular(10)),
                boxShadow: [
                  BoxShadow(
                    color: Color(0xff130f40).withOpacity(0.7),
                    offset: new Offset(-10.0, 10.0),
                    blurRadius: 20.0,
                    spreadRadius: 3.0,
                  )
                ],
              ),
              child: Center(
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 8.0, top: 70.0),
                      child: Container(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color(0xff9b1616),
                          ),
                          child: Text(
                            "Request For Parking",
                            style: TextStyle(
                              fontSize: 20,
                            ),
                          ),
                          onPressed: () {
                            handleButtonPress("Requesting");
                          },
                        ),
                      ),
                    ),
                    SizedBox(height: 20),
                    Parking(),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
