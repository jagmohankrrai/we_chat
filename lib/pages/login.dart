import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:we_chat/model/users.dart';
import 'package:we_chat/pages/signup.dart';
import 'package:we_chat/pages/hompage.dart';
import 'package:we_chat/pages/completeprofile.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../model/uihelp.dart';
class Login extends StatefulWidget {
  const Login({Key? key}) : super(key: key);

  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {
  TextEditingController emailcontroller = new TextEditingController();
  TextEditingController passwordcontroller = new TextEditingController();
  void Checkvalues()
  {
    String email=emailcontroller.text.trim();
    String pass=passwordcontroller.text.trim();
    if(email =="" || pass=="")
    {
      UIHelper.showAlertDialog(context, "Incomplete Data", "Please fill all the fields");
    }
    else
    {
      login(email, pass);
    }
  }
  void login( String email,String pass) async{
    UserCredential? credential;
    try{
      credential=await FirebaseAuth.instance.createUserWithEmailAndPassword(email: email, password: pass);

    }on FirebaseAuthException catch(ex){
      Navigator.pop(context);

      // Show Alert Dialog
      UIHelper.showAlertDialog(context, "An error occured", ex.message.toString());
    }
    if(credential!=null)
    {
      String uid=credential.user!.uid;
      DocumentSnapshot userData=await FirebaseFirestore.instance.collection('users').doc(uid).get();
      users newuser=users.fromMap(userData.data()as Map<String, dynamic>);
      print("new user created");
      Navigator.popUntil(context, (route) => route.isFirst);
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
            builder: (context) {
              return Hompage(user: newuser, firebaseUser: credential!.user!);
            }
        ),
      );
    }
  }
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Container(
            padding: EdgeInsets.symmetric(
              horizontal: 30,
            ),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  Text("Chat  App",style: GoogleFonts.poppins(fontStyle: FontStyle.italic,fontSize: 30), ),
                  SizedBox(width: 30,),
                  TextField(
                    controller: emailcontroller,
                    decoration: InputDecoration(
                      labelText :"E-mail",
                    ),
                  ),
                  SizedBox(width: 10,),
                  TextField(
                    controller: passwordcontroller,
                    obscureText: true,
                    decoration: InputDecoration(
                      labelText :"Password",

                    ),
                  ),
                  SizedBox(height: 30,),
                  CupertinoButton(color:Color(0xff2C3E50),child: Text("Log In",style: GoogleFonts.lato(fontStyle: FontStyle.italic,fontSize: 16),), onPressed: (){
                    Checkvalues();
                  },)
                ],
              ),
            ),
          ),
        ),
      ),
      bottomNavigationBar: Container(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("Don't have a Account",style: GoogleFonts.lato(fontStyle: FontStyle.italic,fontSize: 16), ),
            CupertinoButton(child: Text("Sign Up",style: GoogleFonts.lato(fontStyle: FontStyle.italic,fontSize: 16),), onPressed: (){
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context){
                  return signup();
                }),
              );
            },)

          ],
        ),
      ),
    );
  }
}
