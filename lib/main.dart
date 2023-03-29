import 'package:flutter/material.dart';
import 'package:we_chat/pages/hompage.dart';
import 'package:we_chat/pages/login.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:uuid/uuid.dart';
import 'model/FirebaseHelper.dart';
import 'model/users.dart';
var uuid = Uuid();
void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  User? currentUser = FirebaseAuth.instance.currentUser;
  if(currentUser != null) {
    // Logged In
    users? thisUserModel = await FirebaseHelper.getUserModelById(currentUser.uid);
    if(thisUserModel != null) {
      runApp(MyAppLoggedIn(userModel: thisUserModel, firebaseUser: currentUser));
    }
    else {
      runApp(MyApp());
    }
  }
  else {
    // Not logged in
    runApp(MyApp());
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Login(),
    );
  }
}
class MyAppLoggedIn extends StatelessWidget {
  final users userModel;
  final User firebaseUser;

  const MyAppLoggedIn({Key? key, required this.userModel, required this.firebaseUser}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Hompage(user: userModel, firebaseUser: firebaseUser),
    );
  }
}

