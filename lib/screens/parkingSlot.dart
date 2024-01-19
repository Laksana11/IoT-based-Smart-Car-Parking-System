import 'dart:async';

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../utils/sharedPrefencesUtil.dart';

class Parking extends StatefulWidget {
  const Parking({Key? key}) : super(key: key);

  @override
  State<Parking> createState() => _Parking();
}

class _Parking extends State<Parking> {
  final firestoreInstance = FirebaseFirestore.instance;
  late var state = '';
  final DatabaseReference databaseReference =
      FirebaseDatabase.instance.reference();

  DatabaseReference slot =
      FirebaseDatabase.instance.reference().child("parkingSlot");

  void initState() {
    super.initState();
    slot.onValue.listen((event) {
      fetchSlots();
      setState(() {});
    });
  }

  Future<String?> fetchSlots() async {
    final userId = await SharedPreferencesUtil.getUser() ?? '';
    String? slotName;

    try {
      DatabaseReference reference =
          FirebaseDatabase.instance.reference().child("parkingSlot");
      DataSnapshot snapshot = await reference.get();

      if (snapshot.value != null && snapshot.value is Map) {
        Map<dynamic, dynamic>? lockersData = snapshot.value as Map?;
        // Iterate through the lockers and access their data
        lockersData!.forEach((slotKey, slotValue) {
          String availability = slotValue['availability'];
          String user = slotValue['user'];
          print('User: $user');
          print('Slot Key: $slotKey');
          print('Availability: $availability');

          if (user == userId) {
            slotName = slotKey;
          }
        });
      } else {
        print('No data found under the "slots" node');
      }
    } catch (error) {
      print("Error: $error");
    }
    return slotName;
  }

  Future<void> openCloseBarrier(String operation) async {
    try {
      await databaseReference.child('barrier').update({
        'state': '$operation',
      });
    } catch (e) {
      print('Error opening barrier: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Center(
        child: Container(
          width: MediaQuery.of(context).size.width - 50,
          height: 100,
          color: Colors.white10,
          child: FutureBuilder<String?>(
            future: fetchSlots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return CircularProgressIndicator();
              } else if (snapshot.hasError) {
                return Text('Error: ${snapshot.error}');
              } else if (snapshot.hasData) {
                final slotName = snapshot.data;

                return Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Your parking space is $slotName.',
                        style: TextStyle(
                            color: Colors.white70,
                            fontSize: 15,
                            fontWeight: FontWeight.bold)),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Color(0xff9b1616),
                            ),
                            onPressed: () {
                              print("$slotName is available");
                              openCloseBarrier("opened");
                            },
                            child: Text('Open'),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Color(0xff9b1616),
                            ),
                            onPressed: () {
                              print("$slotName is not available");
                              openCloseBarrier("closed");
                            },
                            child: Text('Close'),
                          ),
                        ),
                      ],
                    ),
                  ],
                );
              } else {
                return Center(
                  child: Text('You do not have any parking slot yet.',
                      style: TextStyle(
                          color: Colors.white70,
                          fontSize: 15,
                          fontWeight: FontWeight.bold)),
                );
              }
            },
          ),
        ),
      ),
    );
  }
}
