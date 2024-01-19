// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';
//
// import '../utils/sharedPrefencesUtil.dart';
//
// class Availability extends StatefulWidget {
//   const Availability({Key? key}) : super(key: key);
//
//   @override
//   State<Availability> createState() => _Availability();
// }
//
// class _Availability extends State<Availability> {
//   String result = "";
//   String currentDate = DateTime.now().toString().split(' ')[0];
//   bool? isAvailable;
//   Future<void> handleButtonPress(String attendanceType) async {
//     String userId = await SharedPreferencesUtil.getUser() ?? '';
//
//     if (userId.isNotEmpty) {
//       CollectionReference usersCollection =
//           FirebaseFirestore.instance.collection('users');
//       DocumentReference userDoc = usersCollection.doc(userId);
//       userDoc.get().then((userSnapshot) async {
//         String email = userSnapshot.get('email');
//         String username = userSnapshot.get('username');
//
//         print('email:$email');
//         print('Username name :$username');
//         DocumentReference attendanceDoc =
//             userDoc.collection('attendance').doc();
//         DocumentSnapshot attendanceData = await attendanceDoc.get();
//
//         await attendanceDoc.set({
//           'date': currentDate,
//           'availability': isAvailable ? "Yes" : "No",
//           'attendance_data': attendanceData,
//         }, SetOptions(merge: true)).then((_) {
//           print('Attendance document created/updated successfully');
//         }).catchError((error) {
//           print('Failed to create/update attendance document: $error');
//         });
//         ;
//       });
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       debugShowCheckedModeBanner: false,
//       theme: ThemeData(
//         brightness: Brightness.light,
//         scaffoldBackgroundColor: Color(0xff22a6b3),
//       ),
//     );
//   }
// }
